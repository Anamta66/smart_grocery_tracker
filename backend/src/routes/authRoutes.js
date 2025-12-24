/**
 * ============================================
 * Authentication Routes
 * ============================================
 * Handles user authentication and authorization
 * 
 * Routes:
 * - POST /register - Register new user
 * - POST /login - User login
 * - POST /logout - User logout
 * - GET /me - Get current user
 * - PUT /update-password - Update password
 * - POST /forgot-password - Request password reset
 * - POST /reset-password - Reset password
 * ============================================
 */

const express = require('express');
const router = express.Router();

// Controllers
const {
  register,
  login,
  logout,
  getMe,
  updatePassword,
  forgotPassword,
  resetPassword
} = require('../controllers/authController');

// Middleware
const { protect } = require('../middleware/authMiddleware');
const { authLimiter } = require('../middleware/rateLimitMiddleware');
const {
  validateRegister,
  validateLogin,
  validateEmail,
  validatePasswordReset,
  validateUpdatePassword
} = require('../middleware/validationMiddleware');

// ============================================
// PUBLIC ROUTES
// ============================================

/**
 * @route   POST /api/v1/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', authLimiter, validateRegister, register);

/**
 * @route   POST /api/v1/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post('/login', authLimiter, validateLogin, login);

/**
 * @route   POST /api/v1/auth/forgot-password
 * @desc    Request password reset
 * @access  Public
 */
router. post('/forgot-password', authLimiter, validateEmail, forgotPassword);

/**
 * @route   POST /api/v1/auth/reset-password
 * @desc    Reset password using token
 * @access  Public
 */
router.post('/reset-password', validatePasswordReset, resetPassword);

// ============================================
// PROTECTED ROUTES
// ============================================

/**
 * @route   GET /api/v1/auth/me
 * @desc    Get current logged-in user
 * @access  Private
 */
router.get('/me', protect, getMe);

/**
 * @route   POST /api/v1/auth/logout
 * @desc    Logout user
 * @access  Private
 */
router.post('/logout', protect, logout);

/**
 * @route   PUT /api/v1/auth/update-password
 * @desc    Update user password
 * @access  Private
 */
router.put('/update-password', protect, validateUpdatePassword, updatePassword);

module.exports = router;