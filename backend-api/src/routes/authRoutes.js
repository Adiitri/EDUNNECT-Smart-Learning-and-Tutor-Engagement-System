const router = require('express').Router();
const User = require('../models/User');

// 1. REGISTER (Sign Up)
router.post('/register', async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "User already exists" });
        }

        // Create new user
        const newUser = new User({ name, email, password });
        await newUser.save();

        res.json({ message: "User registered successfully!", user: newUser });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// 2. LOGIN (Sign In)
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find user by email
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        // Check password (simple check for now)
        if (user.password !== password) {
            return res.status(400).json({ message: "Invalid password" });
        }

        // Success!
        res.json({ 
            message: "Login Successful", 
            user: { id: user._id, name: user.name, email: user.email } 
        });

    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;