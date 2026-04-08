const mongoose = require('mongoose');

const ChatSchema = new mongoose.Schema({
    room: { type: String, required: true }, // Unique ID for the conversation
    sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    message: { type: String, required: true },
    fileUrl: { type: String, default: null }, // URL to uploaded file
    fileName: { type: String, default: null }, // Original file name
    fileType: { type: String, default: 'text', enum: ['text', 'image', 'file'] }, // Type of message
    isRead: { type: Boolean, default: false }, // Track if message has been read
    timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Chat', ChatSchema);