/**
 * ============================================
 * User Routes
 * ============================================
 * Handles user profile and preferences
 * 
 * Routes:
 * - GET /profile - Get user profile
 * - PUT /profile - Update user profile
 * - DELETE /account - Delete user account
 * - PUT /preferences - Update preferences
 * - GET / - Get all users (Admin)
 * ============================================
 */

const express = require('express');
const router = express.Router();

// Controllers
const {
  getProfile,
  updateProfile,
  deleteAccount,
  updatePreferences,
  getAllUsers
} = require('../controllers/userController');

// Middleware
const { protect, authorize } = require('../middleware/authMiddleware');
const { apiLimiter } = require('../middleware/rateLimitMiddleware');

// Apply rate limiting to all routes
router. use(apiLimiter);

// ============================================
// PROTECTED ROUTES
// ============================================

/**
 * @route   GET /api/v1/users/profile
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/profile', protect, getProfile);

/**
 * @route   PUT /api/v1/users/profile
 * @desc    Update user profile
 * @access  Private
 */
router. put('/profile', protect, updateProfile);

/**
 * @route   DELETE /api/v1/users/account
 * @desc    Delete user account
 * @access  Private
 */
router.delete('/account', protect, deleteAccount);

/**
 * @route   PUT /api/v1/users/preferences
 * @desc    Update user preferences
 * @access  Private
 */
router.put('/preferences', protect, updatePreferences);

// ============================================
// ADMIN ROUTES
// ============================================

/**
 * @route   GET /api/v1/users
 * @desc    Get all users
 * @access  Private/Admin
 */
router.get('/', protect, authorize('admin'), getAllUsers);

module.exports = router;