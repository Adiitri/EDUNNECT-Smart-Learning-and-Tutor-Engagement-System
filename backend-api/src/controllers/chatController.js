const Chat = require('../models/Chat');
const Booking = require('../models/Booking');

// 1. Fetch all tutors where this student has a 'Confirmed' status
exports.getConfirmedTutors = async (req, res) => {
    try {
        const { studentName } = req.params; 

        const confirmedBookings = await Booking.find({ 
            studentName: studentName, 
            status: 'Confirmed' 
        });

        res.status(200).json(confirmedBookings || []);
    } catch (error) {
        res.status(500).json({ message: "Error fetching confirmed tutors", error: error.message });
    }
};

// --- FOR TUTORS (ADD THIS) ---
// Fetch all students where this tutor has a 'Confirmed' status
exports.getConfirmedStudents = async (req, res) => {
    try {
        const { tutorId } = req.params; // We use tutorId because names might not be unique

        const confirmedBookings = await Booking.find({ 
            tutorId: tutorId, 
            status: 'Confirmed' 
        });

        res.status(200).json(confirmedBookings || []);
    } catch (error) {
        res.status(500).json({ message: "Error fetching confirmed students", error: error.message });
    }
};

// 2. Fetch history for a specific booking ID
exports.getChatHistory = async (req, res) => {
    try {
        const { bookingId } = req.params;
        const booking = await Booking.findById(bookingId);
        
        if (!booking || booking.status.toLowerCase() !== 'confirmed') {
            return res.status(403).json({ message: "Chat is only available for confirmed bookings" });
        }

        const messages = await Chat.find({ room: bookingId }).sort({ timestamp: 1 });
        res.status(200).json(messages);
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};

// 3. Save message (Used by Socket.io in app.js)
exports.saveSocketMessage = async (data) => {
    try {
        const newMessage = new Chat({
            room: data.bookingId,
            sender: data.senderId,
            message: data.text
        });
        return await newMessage.save();
    } catch (error) {
        console.error("Save error:", error);
    }
};