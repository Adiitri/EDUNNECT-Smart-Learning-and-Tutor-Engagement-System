const User = require('../models/User');

// GET NEARBY TUTORS
exports.getNearbyTutors = async (req, res) => {
    try {
        const { lat, lng, dist } = req.query; // Get latitude, longitude from App

        const distanceInMeters = (dist || 5) * 1000; // Default 5km

        const raw = await User.find({
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

        // normalize returned documents to resemble existing Tutor objects
        const tutors = raw.map(u => ({
            _id: u._id,
            name: u.name,
            subject: u.expertise || '',
            expertise: u.expertise || '',
            location: u.locationText || '',
            rating: u.rating || '',
            latitude: u.location?.coordinates?.[1] || null,
            longitude: u.location?.coordinates?.[0] || null
        }));

        res.json(tutors);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};