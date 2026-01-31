const mongoose = require('mongoose');

const BookingSchema = new mongoose.Schema({
  studentName: { type: String, required: true },
  tutorName: { type: String, required: true },
  tutorId: { type: String, required: true },
  date: { type: Date, default: Date.now },
  status: { type: String, default: 'Pending' } // Pending, Confirmed, Cancelled
});

module.exports = mongoose.model('Booking', BookingSchema);