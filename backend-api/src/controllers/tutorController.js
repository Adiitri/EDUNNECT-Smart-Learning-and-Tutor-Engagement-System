const User = require('../models/User');

// GET NEARBY TUTORS
exports.getNearbyTutors = async (req, res) => {
    try {
        const { lat, lng, dist } = req.query; // Get latitude, longitude from App

        const distanceInMeters = (dist || 5) * 1000; // Default 5km

        const tutors = await User.find({
            role: 'tutor',
            location: {
                $near: {
                    $geometry: {
                        type: "Point",
                        coordinates: [parseFloat(lng), parseFloat(lat)] // MongoDB uses [Long, Lat]
                    },
                    $maxDistance: distanceInMeters
                }
            }
        }).select('-password'); // Don't send passwords back

        res.json(tutors);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};