const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    role: {
        type: String,
        default: 'student',
        enum: ['student', 'tutor', 'admin'] // Keeps the roles locked down securely
    },
    
    // ✅ NEW: We must explicitly tell Mongoose these fields exist!
    location: { type: String, default: '' },
    expertise: { type: String, default: '' },
    phone: { type: String, default: '' },
    about: { type: String, default: '' },
    profileImage: { type: String, default: '' },
    classGrade: { type: String, default: '' }, // For students
    
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('User', UserSchema);