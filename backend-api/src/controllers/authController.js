const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// REGISTER
exports.register = async (req, res) => {
    console.log("REGISTER CONTROLLER HIT!"); 
    try {
        const { name, email, password, role, location, expertise } = req.body;

        // Check if user exists
        let user = await User.findOne({ email });
        if (user) return res.status(400).json({ msg: 'User already exists' });

        // Hash Password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Create User (Adding empty default values to prevent future nulls)
        user = new User({
            name,
            email,
            password: hashedPassword,
            role: role || 'student',
            location: location || '',
            expertise: expertise || '',
            phone: '',
            about: '',
            profileImage: ''
        });

        await user.save();
        
        // Create Token
        const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1d' });
        
        // ✅ FIX: Send ALL user data back to Flutter, including the email!
        res.json({ 
            token, 
            user: { 
                _id: user._id, 
                name: user.name, 
                email: user.email, 
                role: user.role,
                location: user.location,
                expertise: user.expertise,
                phone: user.phone,
                about: user.about,
                profileImage: user.profileImage
            } 
        });

    } catch (err) {
        console.error("Register Error:", err.message);
        res.status(500).json({ error: err.message });
    }
};

// LOGIN
exports.login = async (req, res) => {
    console.log("LOGIN CONTROLLER HIT!");
    try {
        // ✅ FIX 1: Expect 'role' from the frontend login request
        const { email, password, role } = req.body;

        // Check User
        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ msg: 'User not found' });

        // ✅ FIX 2: The Security Bouncer
        // If the frontend says "I am logging into the student app" but the database says "You are a tutor", block them!
        if (role && user.role !== role) {
            return res.status(403).json({ 
                msg: `Access denied. You are registered as a ${user.role}, not a ${role}.` 
            });
        }

        // Check Password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ msg: 'Invalid credentials' });

        // Create Token
        const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1d' });

        res.json({ 
            token, 
            user: { 
                _id: user._id, 
                name: user.name, 
                email: user.email, 
                role: user.role,
                location: user.location,
                expertise: user.expertise,
                phone: user.phone,
                about: user.about,
                profileImage: user.profileImage
            } 
        });

    } catch (err) {
        console.error("Login Error:", err.message);
        res.status(500).json({ error: err.message });
    }
};