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
    
    // Other profile fields
    expertise: { type: String, default: '' },
    phone: { type: String, default: '' },
    about: { type: String, default: '' },
    profileImage: { type: String, default: '' },
    classGrade: { type: String, default: '' }, // For students

    // locationText is the human-readable string (city/address) used in the UI
    locationText: { type: String, default: '' },

    // location is a GeoJSON point used for geospatial queries
    location: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: {
            type: [Number], // [lng, lat]
            default: [0, 0]
        }
    },

    createdAt: {
        type: Date,
        default: Date.now
    }
});

// create 2dsphere index so that $near queries work
UserSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('User', UserSchema);