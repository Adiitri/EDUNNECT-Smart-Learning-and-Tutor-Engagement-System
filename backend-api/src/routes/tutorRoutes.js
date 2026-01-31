const express = require('express');
const router = express.Router();
const tutorController = require('../controllers/tutorController');

// URL: /api/tutors/nearby?lat=12.97&lng=77.59
router.get('/nearby', tutorController.getNearbyTutors);

module.exports = router;