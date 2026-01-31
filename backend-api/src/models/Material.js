const mongoose = require('mongoose');

const MaterialSchema = new mongoose.Schema({
    tutor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    title: { type: String, required: true },
    fileUrl: { type: String, required: true }, // We will save the file path here
    subject: { type: String, required: true },
    uploadedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Material', MaterialSchema);