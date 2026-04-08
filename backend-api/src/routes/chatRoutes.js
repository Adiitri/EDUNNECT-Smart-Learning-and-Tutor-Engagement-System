const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const chatController = require('../controllers/chatController');

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, path.join(__dirname, '../../uploads'));
    },
    filename: (req, file, cb) => {
        const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1E9)}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 50 * 1024 * 1024 }, // 50MB limit
    fileFilter: (req, file, cb) => {
        // Allow images and documents
        const allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain'];
        if (allowedMimes.includes(file.mimetype) || file.mimetype.startsWith('image/') || file.mimetype.startsWith('application/')) {
            cb(null, true);
        } else {
            cb(new Error('Invalid file type'));
        }
    }
});

// --- STUDENT SIDE ---
// Student calls this to see all tutors they have a 'Confirmed' booking with
router.get('/tutors/:studentName', chatController.getConfirmedTutors);

// --- TUTOR SIDE ---
// Tutor calls this to see all students they have a 'Confirmed' booking with
router.get('/students/:tutorId', chatController.getConfirmedStudents);

// --- SHARED ---
// Both call this to load old messages when entering a chat room
router.get('/history/:bookingId', chatController.getChatHistory);

// Get unseen message count
router.get('/unseen/:bookingId', chatController.getUnseenCount);

// Mark messages as read
router.post('/mark-read/:bookingId', chatController.markAsRead);

// File upload endpoint
router.post('/upload', upload.single('file'), chatController.uploadFile);

module.exports = router;