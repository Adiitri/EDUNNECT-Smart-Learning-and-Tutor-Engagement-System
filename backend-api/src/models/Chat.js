const mongoose = require('mongoose');

const ChatSchema = new mongoose.Schema({
    room: { type: String, required: true }, // Unique ID for the conversation
    sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    message: { type: String, required: true },
    timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Chat', ChatSchema);