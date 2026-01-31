const express = require('express');
const router = express.Router();
const recommendationController = require('../controllers/recommendationController');

// GET /api/recommendations/:userId
router.get('/:userId', recommendationController.getAiRecommendations);

module.exports = router;