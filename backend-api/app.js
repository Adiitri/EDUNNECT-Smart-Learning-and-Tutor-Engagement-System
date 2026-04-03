const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const connectDB = require('./src/config/db');
require('dotenv').config();


const chatController = require('./src/controllers/chatController')

// Initialize App
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*", 
        methods: ["GET", "POST"]
    }
});

// Middleware
app.use(cors());
app.use(express.json());

// Connect to Database
connectDB();

// IMPORT ROUTES  <-- ADD THIS
const authRoutes = require('./src/routes/authRoutes');
const tutorRoutes = require('./src/routes/tutors');
const tutorGeoRoutes = require('./src/routes/tutorRoutes'); // handles /nearby search

const recommendationRoutes = require('./src/routes/recommendationRoutes'); // ADD THIS

const chatRoutes = require('./src/routes/chatRoutes'); // ADDED THIS

// USE ROUTES  <-- ADD THIS
app.use('/api/auth', authRoutes);

app.use('/api/admin', require('./src/routes/admin'));
app.use('/api/recommendations', recommendationRoutes);
app.use('/api/tutors', tutorRoutes);
// geolocation helpers share the same base path
app.use('/api/tutors', tutorGeoRoutes);
app.use('/api/chat', chatRoutes); // ADDED THIS

// Optional fallback endpoint for non-socket send trigger (helps unreliable socket conditions)
app.post('/api/chat/send', async (req, res) => {
    const { bookingId, senderId, text } = req.body;
    if (!bookingId || !senderId || !text) {
        return res.status(400).json({ status: 'error', message: 'bookingId, senderId, and text are required' });
    }

    try {
        const saved = await chatController.saveSocketMessage({ bookingId, senderId, text });
        if (!saved) {
            return res.status(500).json({ status: 'error', message: 'Failed to save message' });
        }

        io.to(bookingId.toString()).emit('receive_message', {
            text,
            senderId,
            timestamp: new Date(),
        });

        return res.status(200).json({ status: 'ok' });
    } catch (error) {
        console.error('HTTP chat send error:', error);
        return res.status(500).json({ status: 'error', message: error.message });
    }
});

// Basic Test Route
app.get('/', (req, res) => {
    res.send('Edunnect Backend is Running ');
});

io.on('connection', (socket) => {
    console.log(`User connected: ${socket.id}`);

    socket.on('join_chat', (bookingId) => {
        if (bookingId) {
            socket.join(bookingId.toString()); // Force string to avoid mismatch
            console.log(`User joined room: ${bookingId}`);
        }
    });

    socket.on('send_message', async (data, callback) => {
        try {
            if (!data || !data.bookingId || !data.senderId || !data.text) {
                const err = "Invalid chat payload";
                console.error("Socket Error:", err, data);
                if (callback != null) callback({ status: 'error', message: err });
                return;
            }

            const saved = await chatController.saveSocketMessage(data);
            if (!saved) {
                const err = "Failed to save chat message";
                console.error("Socket Error:", err, data);
                if (callback != null) callback({ status: 'error', message: err });
                return;
            }

            io.to(data.bookingId.toString()).emit('receive_message', {
                text: data.text,
                senderId: data.senderId,
                timestamp: new Date()
            });

            if (callback != null) callback({ status: 'ok' });
        } catch (error) {
            console.error("Socket Error:", error.message, data);
            if (callback != null) callback({ status: 'error', message: error.message });
        }
    });

    socket.on('disconnect', () => {
        console.log('User disconnected');
    });
});
// Start Server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});