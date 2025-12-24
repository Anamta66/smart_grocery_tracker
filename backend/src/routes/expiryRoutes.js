/**
 * ============================================
 * Expiry Routes
 * ============================================
 * Handles expiry tracking and alerts
 * 
 * Routes:
 * - GET /expiring-soon - Items expiring soon
 * - GET /expired - Expired items
 * - GET /check/: id - Check expiry status
 * - GET /summary - Expiry summary
 * - POST /notify - Send expiry notifications
 * ============================================
 */

const express = require('express');
const router = express.Router();

// Controllers
const {
  getExpiringSoon,
  getExpiredItems,
  checkExpiryStatus,
  getExpirySummary,
  sendExpiryNotifications
} = require('../controllers/expiryController');

// Middleware
const { protect } = require('../middleware/authMiddleware');
const { apiLimiter } = require('../middleware/rateLimitMiddleware');
const { validateMongoId } = require('../middleware/validationMiddleware');

// Apply protection and rate limiting
router. use(protect);
router.use(apiLimiter);

// ============================================
// EXPIRY ROUTES
// ============================================

/**
 * @route   GET /api/v1/expiry/expiring-soon
 * @desc    Get items expiring within specified days
 * @access  Private
 * @query   days (default: 7)
 */
router.get('/expiring-soon', getExpiringSoon);

/**
 * @route   GET /api/v1/expiry/expired
 * @desc    Get all expired items
 * @access  Private
 */
router.get('/expired', getExpiredItems);

/**
 * @route   GET /api/v1/expiry/summary
 * @desc    Get expiry summary/dashboard
 * @access  Private
 */
router.get('/summary', getExpirySummary);

/**
 * @route   POST /api/v1/expiry/notify
 * @desc    Send expiry notifications
 * @access  Private
 */
router.post('/notify', sendExpiryNotifications);

/**
 * @route   GET /api/v1/expiry/check/:id
 * @desc    Check expiry status for specific item
 * @access  Private
 */
router.get('/check/:id', validateMongoId, checkExpiryStatus);

module.exports = router;