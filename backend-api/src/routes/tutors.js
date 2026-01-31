const router = require('express').Router();
const Tutor = require('../models/Tutor'); 
const Booking = require('../models/Booking'); 

// 1. GET ALL TUTORS
router.get('/', async (req, res) => {
    try {
        const tutors = await Tutor.find(); 
        res.json(tutors);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// 2. BOOK A SESSION
router.post('/book', async (req, res) => {
    const { tutorId, tutorName, studentName } = req.body;

    try {
        const newBooking = new Booking({
            tutorId,
            tutorName,
            studentName: studentName || "Demo Student"
        });

        const savedBooking = await newBooking.save();
        res.json({ message: "Booking successful!", booking: savedBooking });
    } catch (err) {
        res.status(500).json({ message: "Booking failed", error: err.message });
    }
});

// 3. GET TUTOR REQUESTS
router.get('/requests/:tutorName', async (req, res) => {
    try {
        const bookings = await Booking.find({ tutorName: req.params.tutorName });
        res.json(bookings);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// 4. UPDATE BOOKING STATUS
router.patch('/booking/:id', async (req, res) => {
    try {
        const { status } = req.body;
        const updatedBooking = await Booking.findByIdAndUpdate(
            req.params.id, 
            { status: status }, 
            { new: true }
        );
        res.json(updatedBooking);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;