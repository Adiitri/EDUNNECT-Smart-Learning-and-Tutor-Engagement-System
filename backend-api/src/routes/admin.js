const router = require('express').Router();
const User = require('../models/User');

// 1. GET ALL USERS (Students & Tutors)
router.get('/users', async (req, res) => {
    try {
        // Fetch everyone except the admin themselves
        const users = await User.find({ role: { $ne: 'admin' } }).select('-password');
        res.json(users);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// 2. DELETE USER (Ban Hammer 🔨)
router.delete('/users/:id', async (req, res) => {
    try {
        await User.findByIdAndDelete(req.params.id);
        res.json({ message: "User has been banned/deleted." });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;