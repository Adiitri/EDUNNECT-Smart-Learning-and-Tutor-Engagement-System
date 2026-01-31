const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }, // In a real app, we would encrypt this!
  role: { type: String, default: "student" } // student or tutor
});

module.exports = mongoose.model('User', UserSchema);