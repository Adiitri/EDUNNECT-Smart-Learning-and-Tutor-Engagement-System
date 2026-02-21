const Chat = require('../models/Chat');
const Booking = require('../models/Booking');

// NEW: Fetch all tutors with whom the student has a 'Confirmed' booking
exports.getConfirmedTutors = async (req, res) => {
    try {
        const { studentName } = req.params; 

        // Find bookings for this student that are confirmed
        const confirmedBookings = await Booking.find({ 
            studentName: studentName, 
            status: 'Confirmed' 
        });

        if (!confirmedBookings || confirmedBookings.length === 0) {
            return res.status(200).json([]); // Return empty list if no tutors found
        }

        res.status(200).json(confirmedBookings);
    } catch (error) {
        res.status(500).json({ message: "Error fetching confirmed tutors", error: error.message });
    }
};

// Fetch history for a specific booking (Your existing code)
exports.getChatHistory = async (req, res) => {
    try {
        const { bookingId } = req.params;
        const booking = await Booking.findById(bookingId);
        
        if (!booking) {
            return res.status(404).json({ message: "Booking not found" });
        }

        if (booking.status.toLowerCase() !== 'confirmed') {
            return res.status(403).json({ message: "Chat is only available for confirmed bookings" });
        }

        const messages = await Chat.find({ room: bookingId }).sort({ timestamp: 1 });
        res.status(200).json(messages);
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};

// Logic to save message for Socket.io (Your existing code)
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