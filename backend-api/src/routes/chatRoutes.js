const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');

// --- STUDENT SIDE ---
// Student calls this to see all tutors they have a 'Confirmed' booking with
router.get('/tutors/:studentName', chatController.getConfirmedTutors);

// --- TUTOR SIDE ---
// Tutor calls this to see all students they have a 'Confirmed' booking with
router.get('/students/:tutorId', chatController.getConfirmedStudents);

// --- SHARED ---
// Both call this to load old messages when entering a chat room
router.get('/history/:bookingId', chatController.getChatHistory);

module.exports = router;