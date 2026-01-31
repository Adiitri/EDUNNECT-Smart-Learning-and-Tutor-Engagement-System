const mongoose = require('mongoose');

const TutorSchema = new mongoose.Schema({
  name: { type: String, required: true },
  subject: { type: String, required: true },
  rating: { type: String, default: "4.5" },
  location: { type: String, required: true },
  bio: { type: String, default: "Experienced tutor verified by Edunnect." }
});

module.exports = mongoose.model('Tutor', TutorSchema);