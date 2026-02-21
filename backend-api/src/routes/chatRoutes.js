const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');

// For the tutor list screen
router.get('/tutors/:studentName', chatController.getConfirmedTutors);

// For loading history when opening a chat
router.get('/history/:bookingId', chatController.getChatHistory);

module.exports = router;