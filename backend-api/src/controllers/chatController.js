const Chat = require('../models/Chat');
const Booking = require('../models/Booking');

// 1. Fetch confirmed tutors for student
exports.getConfirmedTutors = async (req, res) => {
    try {
        const { studentName } = req.params; 
        // Use a case-insensitive search for status to be safe
        const confirmedBookings = await Booking.find({ 
            studentName: studentName, 
            status: { $regex: /^confirmed$/i } 
        }).lean();

        res.status(200).json(confirmedBookings);
    } catch (error) {
        res.status(500).json({ message: "Error", error: error.message });
    }
};

// --- ADDED THIS MISSING FUNCTION ---
// 2. Fetch confirmed students for tutor
exports.getConfirmedStudents = async (req, res) => {
    try {
        const { tutorId } = req.params; 
        const confirmedBookings = await Booking.find({ 
            tutorId: tutorId, 
            status: 'Confirmed' 
        }).lean();
        res.status(200).json(confirmedBookings);
    } catch (error) {
        res.status(500).json({ message: "Error fetching confirmed students", error: error.message });
    }
};

// 3. Fetch history
exports.getChatHistory = async (req, res) => {
    try {
        const { bookingId } = req.params;
        const booking = await Booking.findById(bookingId);
        
        if (!booking || booking.status?.toLowerCase() !== 'confirmed') {
            return res.status(403).json({ message: "Chat is only available for confirmed bookings" });
        }

        const messages = await Chat.find({ room: bookingId }).sort({ timestamp: 1 });
        res.status(200).json(messages);
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};

// 4. Save message (Socket.io helper)
exports.saveSocketMessage = async (data) => {
    try {
        if(!data.bookingId || !data.text) return; 

        const newMessage = new Chat({
            room: data.bookingId, 
            sender: data.senderId,
            message: data.text,
            timestamp: new Date()
        });
        return await newMessage.save();
    } catch (error) {
        console.error("Save error in Socket Controller:", error);
    }
};