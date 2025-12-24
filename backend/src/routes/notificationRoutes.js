/**
 * ============================================
 * Notification Routes
 * ============================================
 * Handles user notifications
 * 
 * Routes: 
 * - GET / - Get all notifications
 * - POST / - Create notification
 * - GET /unread-count - Get unread count
 * - PATCH /read-all - Mark all as read
 * - GET /type/:type - Get by type
 * - GET /:id - Get single notification
 * - PATCH /:id/read - Mark as read
 * - DELETE /:id - Delete notification
 * - DELETE / - Clear all notifications
 * ============================================
 */

const express = require('express');
const router = express.Router();

// Controllers
const {
  getNotifications,
  getNotification,
  markAsRead,
  markAllAsRead,
  getUnreadCount,
  deleteNotification,
  clearAllNotifications,
  createNotification,
  getNotificationsByType
} = require('../controllers/notificationController');

// Middleware
const { protect } = require('../middleware/authMiddleware');
const { apiLimiter } = require('../middleware/rateLimitMiddleware');
const { validateMongoId, validatePagination } = require('../middleware/validationMiddleware');

// Apply protection and rate limiting
router.use(protect);
router.use(apiLimiter);

// ============================================
// NOTIFICATION ROUTES
// ============================================

/**
 * @route   GET /api/v1/notifications
 * @desc    Get all notifications for user
 * @access  Private
 * @query   read (true/false), limit, page
 */
router.get('/', validatePagination, getNotifications);

/**
 * @route   POST /api/v1/notifications
 * @desc    Create custom notification
 * @access  Private
 */
router.post('/', createNotification);

/**
 * @route   DELETE /api/v1/notifications
 * @desc    Clear all notifications
 * @access  Private
 */
router.delete('/', clearAllNotifications);

/**
 * @route   GET /api/v1/notifications/unread-count
 * @desc    Get unread notification count
 * @access  Private
 */
router.get('/unread-count', getUnreadCount);

/**
 * @route   PATCH /api/v1/notifications/read-all
 * @desc    Mark all notifications as read
 * @access  Private
 */
router.patch('/read-all', markAllAsRead);

/**
 * @route   GET /api/v1/notifications/type/:type
 * @desc    Get notifications by type
 * @access  Private
 */
router.get('/type/:type', getNotificationsByType);

/**
 * @route   GET /api/v1/notifications/:id
 * @desc    Get single notification
 * @access  Private
 */
router.get('/:id', validateMongoId, getNotification);

/**
 * @route   PATCH /api/v1/notifications/:id/read
 * @desc    Mark notification as read
 * @access  Private
 */
router.patch('/:id/read', validateMongoId, markAsRead);

/**
 * @route   DELETE /api/v1/notifications/:id
 * @desc    Delete single notification
 * @access  Private
 */
router.delete('/:id', validateMongoId, deleteNotification);

module.exports = router;