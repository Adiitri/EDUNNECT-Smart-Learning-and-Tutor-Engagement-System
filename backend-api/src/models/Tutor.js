const mongoose = require('mongoose');

const TutorSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  subject: { type: String, required: true },
  rating: { type: String, default: "4.5" },
  location: { type: String, required: true },
  // geo field to support location-based search
  geo: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      default: [0, 0]
    }
  },
  bio: { type: String, default: "Experienced tutor verified by Edunnect." }
});

TutorSchema.index({ geo: '2dsphere' });

module.exports = mongoose.model('Tutor', TutorSchema);