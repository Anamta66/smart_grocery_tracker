/**
 * ============================================
 * Expiry Controller
 * ============================================
 * Handles expiry tracking, alerts, and 
 * fetching items nearing expiration.
 * 
 * Features:
 * - Get items expiring soon
 * - Get expired items
 * - Check expiry status for specific item
 * - Bulk expiry check
 * ============================================
 */

const Grocery = require('../models/Grocery');
const User = require('../models/User');
const Notification = require('../models/Notification');

/**
 * @desc    Get all items expiring within specified days
 * @route   GET /api/expiry/expiring-soon
 * @access  Private
 * @query   days (default: 7)
 */
exports.getExpiringSoon = async (req, res) => {
  try {
    const userId = req.user.id; // From auth middleware
    const days = parseInt(req.query.days) || 7;

    // Calculate date threshold
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const futureDate = new Date();
    futureDate.setDate(today.getDate() + days);
    futureDate.setHours(23, 59, 59, 999);

    // Find items expiring within the specified days
    const expiringItems = await Grocery. find({
      user: userId,
      expiryDate: {
        $gte: today,
        $lte: futureDate
      },
      quantity: { $gt: 0 } // Only items in stock
    })
      .populate('category', 'name icon color')
      .sort({ expiryDate: 1 }); // Earliest expiry first

    // Add days remaining to each item
    const itemsWithDaysRemaining = expiringItems. map(item => {
      const daysRemaining = Math.ceil(
        (item.expiryDate - today) / (1000 * 60 * 60 * 24)
      );
      
      return {
        ...item. toObject(),
        daysRemaining,
        urgencyLevel: daysRemaining <= 2 ? 'critical' : 
                      daysRemaining <= 5 ? 'warning' : 'normal'
      };
    });

    res.status(200).json({
      success: true,
      count: itemsWithDaysRemaining.length,
      data: itemsWithDaysRemaining,
      message: `Found ${itemsWithDaysRemaining.length} items expiring within ${days} days`
    });

  } catch (error) {
    console.error('Error fetching expiring items:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch expiring items',
      error: error. message
    });
  }
};

/**
 * @desc    Get all expired items
 * @route   GET /api/expiry/expired
 * @access  Private
 */
exports. getExpiredItems = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Find items that have already expired
    const expiredItems = await Grocery.find({
      user: userId,
      expiryDate: { $lt: today },
      quantity: { $gt: 0 } // Only items still in stock
    })
      .populate('category', 'name icon color')
      .sort({ expiryDate: -1 }); // Most recently expired first

    // Calculate days expired
    const itemsWithDaysExpired = expiredItems.map(item => {
      const daysExpired = Math.ceil(
        (today - item.expiryDate) / (1000 * 60 * 60 * 24)
      );
      
      return {
        ...item.toObject(),
        daysExpired
      };
    });

    res.status(200).json({
      success: true,
      count: itemsWithDaysExpired.length,
      data: itemsWithDaysExpired,
      message: `Found ${itemsWithDaysExpired.length} expired items`
    });

  } catch (error) {
    console.error('Error fetching expired items:', error);
    res.status(500).json({
      success: false,
      message:  'Failed to fetch expired items',
      error: error.message
    });
  }
};

/**
 * @desc    Check expiry status for specific item
 * @route   GET /api/expiry/check/: id
 * @access  Private
 */
exports.checkExpiryStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const item = await Grocery. findOne({ _id: id, user: userId })
      .populate('category', 'name icon color');

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Item not found'
      });
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let status, daysRemaining, urgencyLevel, recommendation;

    if (item.expiryDate < today) {
      // Expired
      const daysExpired = Math.ceil(
        (today - item.expiryDate) / (1000 * 60 * 60 * 24)
      );
      
      status = 'expired';
      daysRemaining = -daysExpired;
      urgencyLevel = 'critical';
      recommendation = 'Discard this item immediately for safety';
      
    } else {
      // Not expired yet
      daysRemaining = Math.ceil(
        (item.expiryDate - today) / (1000 * 60 * 60 * 24)
      );

      if (daysRemaining === 0) {
        status = 'expires_today';
        urgencyLevel = 'critical';
        recommendation = 'Use this item today or discard';
      } else if (daysRemaining <= 2) {
        status = 'critical';
        urgencyLevel = 'critical';
        recommendation = 'Use immediately to avoid waste';
      } else if (daysRemaining <= 5) {
        status = 'warning';
        urgencyLevel = 'warning';
        recommendation = 'Plan to use within next few days';
      } else if (daysRemaining <= 10) {
        status = 'attention';
        urgencyLevel = 'normal';
        recommendation = 'Keep an eye on this item';
      } else {
        status = 'fresh';
        urgencyLevel = 'normal';
        recommendation = 'Item is fresh';
      }
    }

    res.status(200).json({
      success: true,
      data: {
        item: item.toObject(),
        expiryStatus: {
          status,
          daysRemaining,
          urgencyLevel,
          recommendation,
          expiryDate: item.expiryDate
        }
      }
    });

  } catch (error) {
    console.error('Error checking expiry status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check expiry status',
      error: error.message
    });
  }
};

/**
 * @desc    Get expiry summary/dashboard
 * @route   GET /api/expiry/summary
 * @access  Private
 */
exports.getExpirySummary = async (req, res) => {
  try {
    const userId = req. user.id;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Calculate different date thresholds
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);
    
    const threeDays = new Date(today);
    threeDays.setDate(today.getDate() + 3);
    
    const sevenDays = new Date(today);
    sevenDays.setDate(today.getDate() + 7);

    // Parallel queries for efficiency
    const [
      expired,
      expiringToday,
      expiringIn3Days,
      expiringIn7Days,
      totalItems
    ] = await Promise.all([
      // Already expired
      Grocery.countDocuments({
        user: userId,
        expiryDate:  { $lt: today },
        quantity: { $gt:  0 }
      }),
      
      // Expiring today
      Grocery.countDocuments({
        user: userId,
        expiryDate: { $gte: today, $lt: tomorrow },
        quantity: { $gt: 0 }
      }),
      
      // Expiring in 3 days
      Grocery.countDocuments({
        user: userId,
        expiryDate: { $gte: today, $lte: threeDays },
        quantity: { $gt: 0 }
      }),
      
      // Expiring in 7 days
      Grocery.countDocuments({
        user: userId,
        expiryDate:  { $gte: today, $lte: sevenDays },
        quantity: { $gt:  0 }
      }),
      
      // Total items with expiry
      Grocery.countDocuments({
        user: userId,
        expiryDate:  { $exists: true },
        quantity: { $gt:  0 }
      })
    ]);

    // Calculate percentages
    const criticalPercentage = totalItems > 0 
      ? Math.round((expiringIn3Days / totalItems) * 100) 
      : 0;

    res.status(200).json({
      success: true,
      data: {
        summary: {
          expired,
          expiringToday,
          expiringIn3Days,
          expiringIn7Days,
          totalItems,
          criticalPercentage
        },
        alerts: {
          critical: expired + expiringToday,
          warning: expiringIn3Days,
          attention: expiringIn7Days
        }
      },
      message: 'Expiry summary fetched successfully'
    });

  } catch (error) {
    console.error('Error fetching expiry summary:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch expiry summary',
      error: error. message
    });
  }
};

/**
 * @desc    Send expiry notifications
 * @route   POST /api/expiry/notify
 * @access  Private
 */
exports.sendExpiryNotifications = async (req, res) => {
  try {
    const userId = req. user.id;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const threeDays = new Date(today);
    threeDays.setDate(today.getDate() + 3);

    // Find items expiring within 3 days
    const expiringItems = await Grocery.find({
      user: userId,
      expiryDate: { $gte: today, $lte: threeDays },
      quantity: { $gt: 0 }
    });

    const notifications = [];

    for (const item of expiringItems) {
      const daysRemaining = Math.ceil(
        (item.expiryDate - today) / (1000 * 60 * 60 * 24)
      );

      let title, message, priority;

      if (daysRemaining === 0) {
        title = '🚨 Expires Today! ';
        message = `${item.name} expires today.  Use or discard immediately.`;
        priority = 'high';
      } else if (daysRemaining === 1) {
        title = '⚠️ Expires Tomorrow';
        message = `${item.name} expires tomorrow. Plan to use it soon.`;
        priority = 'high';
      } else {
        title = '📅 Expiring Soon';
        message = `${item.name} expires in ${daysRemaining} days. `;
        priority = 'medium';
      }

      // Create notification
      const notification = await Notification.create({
        user: userId,
        type: 'expiry_alert',
        title,
        message,
        priority,
        relatedItem: item._id,
        metadata: {
          itemName: item.name,
          expiryDate: item.expiryDate,
          daysRemaining
        }
      });

      notifications. push(notification);
    }

    res.status(200).json({
      success: true,
      count: notifications.length,
      data: notifications,
      message: `Sent ${notifications.length} expiry notifications`
    });

  } catch (error) {
    console.error('Error sending expiry notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send expiry notifications',
      error: error.message
    });
  }
};
