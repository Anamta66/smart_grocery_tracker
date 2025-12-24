/**
 * ============================================
 * Notification Controller
 * ============================================
 * Manages user notifications for grocery
 * expiry alerts, low stock, and system updates. 
 * 
 * Features:
 * - Get all notifications
 * - Mark as read/unread
 * - Delete notifications
 * - Get unread count
 * - Clear all notifications
 * ============================================
 */

const Notification = require('../models/Notification');

/**
 * @desc    Get all notifications for user
 * @route   GET /api/notifications
 * @access  Private
 * @query   read (true/false), limit, page
 */
exports.getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const { read, limit = 20, page = 1 } = req.query;

    // Build query
    const query = { user: userId };
    
    if (read !== undefined) {
      query.isRead = read === 'true';
    }

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Fetch notifications
    const notifications = await Notification.find(query)
      .sort({ createdAt: -1 }) // Newest first
      .limit(parseInt(limit))
      .skip(skip)
      .populate('relatedItem', 'name category expiryDate');

    // Get total count for pagination
    const total = await Notification.countDocuments(query);

    res.status(200).json({
      success: true,
      count: notifications.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
      data: notifications
    });

  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch notifications',
      error: error.message
    });
  }
};

/**
 * @desc    Get single notification
 * @route   GET /api/notifications/:id
 * @access  Private
 */
exports.getNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const notification = await Notification.findOne({
      _id: id,
      user: userId
    }).populate('relatedItem', 'name category expiryDate quantity');

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    res.status(200).json({
      success: true,
      data: notification
    });

  } catch (error) {
    console.error('Error fetching notification:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch notification',
      error: error. message
    });
  }
};

/**
 * @desc    Mark notification as read
 * @route   PATCH /api/notifications/:id/read
 * @access  Private
 */
exports.markAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req. user.id;

    const notification = await Notification.findOneAndUpdate(
      { _id: id, user: userId },
      { isRead: true, readAt: new Date() },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    res.status(200).json({
      success: true,
      data: notification,
      message: 'Notification marked as read'
    });

  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update notification',
      error: error. message
    });
  }
};

/**
 * @desc    Mark all notifications as read
 * @route   PATCH /api/notifications/read-all
 * @access  Private
 */
exports.markAllAsRead = async (req, res) => {
  try {
    const userId = req.user. id;

    const result = await Notification.updateMany(
      { user: userId, isRead: false },
      { isRead: true, readAt: new Date() }
    );

    res.status(200).json({
      success: true,
      count: result.modifiedCount,
      message: `Marked ${result.modifiedCount} notifications as read`
    });

  } catch (error) {
    console.error('Error marking all as read:', error);
    res.status(500).json({
      success: false,
      message:  'Failed to update notifications',
      error: error. message
    });
  }
};

/**
 * @desc    Get unread notification count
 * @route   GET /api/notifications/unread-count
 * @access  Private
 */
exports.getUnreadCount = async (req, res) => {
  try {
    const userId = req.user. id;

    const count = await Notification.countDocuments({
      user: userId,
      isRead: false
    });

    res.status(200).json({
      success: true,
      data: { count },
      message: `You have ${count} unread notifications`
    });

  } catch (error) {
    console.error('Error fetching unread count:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch unread count',
      error: error.message
    });
  }
};

/**
 * @desc    Delete notification
 * @route   DELETE /api/notifications/:id
 * @access  Private
 */
exports.deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const notification = await Notification.findOneAndDelete({
      _id: id,
      user: userId
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully'
    });

  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete notification',
      error:  error.message
    });
  }
};

/**
 * @desc    Clear all notifications
 * @route   DELETE /api/notifications
 * @access  Private
 */
exports.clearAllNotifications = async (req, res) => {
  try {
    const userId = req.user. id;

    const result = await Notification.deleteMany({ user: userId });

    res.status(200).json({
      success: true,
      count: result.deletedCount,
      message: `Cleared ${result.deletedCount} notifications`
    });

  } catch (error) {
    console.error('Error clearing notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to clear notifications',
      error: error. message
    });
  }
};

/**
 * @desc    Create custom notification
 * @route   POST /api/notifications
 * @access  Private (Admin or System)
 */
exports.createNotification = async (req, res) => {
  try {
    const userId = req.user.id;
    const { type, title, message, priority, relatedItem, metadata } = req.body;

    // Validation
    if (!title || !message) {
      return res.status(400).json({
        success: false,
        message: 'Title and message are required'
      });
    }

    const notification = await Notification.create({
      user: userId,
      type:  type || 'general',
      title,
      message,
      priority:  priority || 'medium',
      relatedItem,
      metadata
    });

    res.status(201).json({
      success: true,
      data: notification,
      message: 'Notification created successfully'
    });

  } catch (error) {
    console.error('Error creating notification:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create notification',
      error: error.message
    });
  }
};

/**
 * @desc    Get notifications by type
 * @route   GET /api/notifications/type/:type
 * @access  Private
 */
exports.getNotificationsByType = async (req, res) => {
  try {
    const { type } = req. params;
    const userId = req.user.id;
    const { limit = 20 } = req.query;

    const notifications = await Notification.find({
      user: userId,
      type
    })
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .populate('relatedItem', 'name category expiryDate');

    res.status(200).json({
      success: true,
      count: notifications.length,
      data: notifications
    });

  } catch (error) {
    console.error('Error fetching notifications by type:', error);
    res.status(500).json({
      success: false,
      message:  'Failed to fetch notifications',
      error: error.message
    });
  }
};
