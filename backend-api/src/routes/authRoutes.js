const express = require('express');
const router = express.Router();

// 1. IMPORT THE BRAIN (Your Secure Controller)
// Make sure this path points to your actual controller file
const authController = require('../controllers/authController');

// 2. CONNECT ROUTES TO CONTROLLER FUNCTIONS
// When someone goes to /register, let the Controller handle it!
router.post('/register', authController.register);

// When someone goes to /login, let the Controller handle it!
router.post('/login', authController.login);

module.exports = router;