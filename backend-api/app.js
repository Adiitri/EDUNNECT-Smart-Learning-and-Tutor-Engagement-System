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


const recommendationRoutes = require('./src/routes/recommendationRoutes'); // ADD THIS


const chatRoutes = require('./src/routes/chatRoutes'); // ADDED THIS

// USE ROUTES  <-- ADD THIS
app.use('/api/auth', authRoutes);

app.use('/api/admin', require('./src/routes/admin'));
app.use('/api/recommendations', recommendationRoutes);
app.use('/api/tutors',tutorRoutes);
app.use('/api/chat', chatRoutes); // ADDED THIS

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

    socket.on('send_message', async (data) => {
        try {
            // Only broadcast if the message is actually saved
            await chatController.saveSocketMessage(data);

            io.to(data.bookingId.toString()).emit('receive_message', {
                text: data.text,
                senderId: data.senderId,
                timestamp: new Date()
            });
        } catch (error) {
            console.error("Socket Error:", error.message);
            // Optionally: socket.emit('error', 'Message failed to send');
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