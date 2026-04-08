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

// 4. File Upload Handler
exports.uploadFile = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: "No file uploaded" });
        }

        const { bookingId, senderId, fileType } = req.body;

        if (!bookingId || !senderId) {
            return res.status(400).json({ message: "Missing required fields" });
        }

        // Verify the booking exists and is confirmed
        const booking = await Booking.findById(bookingId);
        if (!booking || booking.status?.toLowerCase() !== 'confirmed') {
            return res.status(403).json({ message: "Chat is only available for confirmed bookings" });
        }

        // Generate file URL (you can modify this based on your file storage strategy)
        // For now, we'll use a simple path. In production, use cloud storage like AWS S3
        const fileName = req.file.originalname;
        const fileUrl = `http://localhost:5000/uploads/${req.file.filename}`;

        // Save file message to database
        const newMessage = new Chat({
            room: bookingId,
            sender: senderId,
            message: fileName,
            fileUrl: fileUrl,
            fileName: fileName,
            fileType: fileType || 'file',
            timestamp: new Date()
        });

        await newMessage.save();

        res.status(200).json({
            message: "File uploaded successfully",
            fileName: fileName,
            fileUrl: fileUrl,
            fileType: fileType
        });

    } catch (error) {
        console.error("File upload error:", error);
        res.status(500).json({ message: "File upload failed", error: error.message });
    }
};

// 5. Save message (Socket.io helper)
exports.saveSocketMessage = async (data) => {
    try {
        if(!data.bookingId || !data.text) return; 

        const newMessage = new Chat({
            room: data.bookingId, 
            sender: data.senderId,
            message: data.text,
            fileUrl: data.fileUrl || null,
            fileName: data.fileName || null,
            fileType: data.fileType || 'text',
            isRead: false,
            timestamp: new Date()
        });
        return await newMessage.save();
    } catch (error) {
        console.error("Save error in Socket Controller:", error);
    }
};

// 6. Get unseen message count for a booking
exports.getUnseenCount = async (req, res) => {
    try {
        const { bookingId } = req.params;
        
        const messages = await Chat.find({ 
            room: bookingId, 
            isRead: false 
        });
        
        res.status(200).json({ 
            unseenCount: messages.length 
        });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};

// 7. Mark all messages in a booking as read
exports.markAsRead = async (req, res) => {
    try {
        const { bookingId } = req.params;
        
        await Chat.updateMany(
            { room: bookingId },
            { isRead: true }
        );
        
        res.status(200).json({ message: "Messages marked as read" });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};