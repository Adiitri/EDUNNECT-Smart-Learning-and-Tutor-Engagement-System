const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// -----------------------------------------
// 1. REGISTER CONTROLLER
// -----------------------------------------
exports.register = async (req, res) => {
    console.log("REGISTER CONTROLLER HIT!"); 
    try {
        const { name, email, password, role, location, expertise, latitude, longitude } = req.body;

        // Check if user exists
        let user = await User.findOne({ email });
        if (user) return res.status(400).json({ msg: 'User already exists' });

        // Hash Password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Build the new user object
        const userObj = {
            name,
            email,
            password: hashedPassword,
            role: role || 'student',
            expertise: expertise || '',
            phone: '',
            about: '',
            profileImage: '',
            classGrade: '' // Added for students
        };
        if (location) {
            userObj.locationText = location;
        }
        if (latitude != null && longitude != null) {
            userObj.location = {
                type: 'Point',
                coordinates: [parseFloat(longitude), parseFloat(latitude)]
            };
        }

        // Create User
        user = new User(userObj);
        await user.save();
        
        // If registering as a tutor, also create a Tutor profile so search works immediately
        if (user.role === 'tutor') {
            try {
                await require('../models/Tutor').findOneAndUpdate(
                    { email: user.email },
                    {
                        name: user.name,
                        subject: expertise || '',
                        location: location || '',
                        geo: latitude != null && longitude != null ? { type: 'Point', coordinates: [parseFloat(longitude), parseFloat(latitude)] } : undefined
                    },
                    { upsert: true, new: true }
                );
            } catch (inner) {
                console.error("Failed to create tutor profile during register:", inner.message);
            }
        }

        // Create Token
        const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1d' });
        
        // Send ALL user data back to Flutter
        res.json({ 
            token, 
            user: { 
                _id: user._id, 
                name: user.name, 
                email: user.email, 
                role: user.role,
                location: user.locationText || '',
                expertise: user.expertise,
                phone: user.phone,
                about: user.about,
                profileImage: user.profileImage,
                classGrade: user.classGrade,
                latitude: user.location?.coordinates?.[1] || null,
                longitude: user.location?.coordinates?.[0] || null
            } 
        });

    } catch (err) {
        console.error("Register Error:", err.message);
        res.status(500).json({ error: err.message });
    }
};

// -----------------------------------------
// 2. LOGIN CONTROLLER
// -----------------------------------------
exports.login = async (req, res) => {
    console.log("LOGIN CONTROLLER HIT!");
    try {
        // Expect 'role' from the frontend login request
        const { email, password, role } = req.body;

        // Check User
        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ msg: 'User not found' });

        // The Security Bouncer
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

        // Send ALL user data back to Flutter
        res.json({ 
            token, 
            user: { 
                _id: user._id, 
                name: user.name, 
                email: user.email, 
                role: user.role,
                location: user.locationText || '',
                expertise: user.expertise,
                phone: user.phone,
                about: user.about,
                profileImage: user.profileImage,
                classGrade: user.classGrade,
                latitude: user.location?.coordinates?.[1] || null,
                longitude: user.location?.coordinates?.[0] || null
            }
        });
    } catch (err) {
        console.error("Login Error:", err.message);
        res.status(500).json({ error: err.message });
    }
};

// -----------------------------------------
// 3. UPDATE PROFILE CONTROLLER
// -----------------------------------------
exports.updateProfile = async (req, res) => {
    console.log("UPDATE PROFILE HIT!");
    try {
        const { userId, phone, location, about, expertise, classGrade, latitude, longitude } = req.body;

        // Build update object dynamically
        const updateObj = {
            phone: phone || '',
            about: about || '',
            expertise: expertise || '',
            classGrade: classGrade || ''
        };

        // store the human-readable location separately for display
        if (location) {
            updateObj.locationText = location;
        }

        // if coordinates are provided, update GeoJSON point
        if (latitude != null && longitude != null) {
            updateObj.location = {
                type: 'Point',
                coordinates: [parseFloat(longitude), parseFloat(latitude)]
            };
        }

        // Update the user
        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { $set: updateObj },
            { new: true }
        );

        if (!updatedUser) return res.status(404).json({ msg: "User not found" });

        // If this user is a tutor, sync relevant fields to the Tutor profile
        if (updatedUser.role === 'tutor') {
            try {
                const tutorUpdate = {
                    name: updatedUser.name,
                    location: location || updatedUser.locationText || '',
                    // store expertise as subject if available
                    subject: expertise || updatedUser.expertise || '',
                };
                if (latitude != null && longitude != null) {
                    tutorUpdate.geo = {
                        type: 'Point',
                        coordinates: [parseFloat(longitude), parseFloat(latitude)]
                    };
                }
                // using email as a stable key (Tutor model may have email due to seeding)
                await require('../models/Tutor').findOneAndUpdate(
                    { email: updatedUser.email },
                    tutorUpdate,
                    { upsert: true, new: true }
                );
            } catch (innerErr) {
                console.error("Failed to sync tutor profile:", innerErr.message);
            }
        }

        // Return user data in the same format as login endpoint for consistency
        res.json({ 
            msg: "Profile updated successfully", 
            user: { 
                _id: updatedUser._id, 
                name: updatedUser.name, 
                email: updatedUser.email, 
                role: updatedUser.role,
                location: updatedUser.locationText || '',
                expertise: updatedUser.expertise,
                phone: updatedUser.phone,
                about: updatedUser.about,
                profileImage: updatedUser.profileImage,
                classGrade: updatedUser.classGrade,
                latitude: updatedUser.location?.coordinates?.[1] || null,
                longitude: updatedUser.location?.coordinates?.[0] || null
            } 
        });
    } catch (err) {
        console.error("Update Profile Error:", err.message);
        res.status(500).json({ error: err.message });
    }
};