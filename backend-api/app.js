const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const connectDB = require('./src/config/db');
require('dotenv').config();

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
const tutorRoutes = require('./src/routes/tutorRoutes');

const recommendationRoutes = require('./src/routes/recommendationRoutes'); // ADD THIS

// USE ROUTES  <-- ADD THIS
app.use('/api/auth', authRoutes);
app.use('/api/tutors', require('./src/routes/tutors'));
app.use('/api/tutors', tutorRoutes);
app.use('/api/admin', require('./src/routes/admin'));
app.use('/api/recommendations', recommendationRoutes);

// Basic Test Route
app.get('/', (req, res) => {
    res.send('Edunnect Backend is Running ');
});

// Start Server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});