/**
 * ============================================
 * Notification Service
 * ============================================
 * Handles push notifications and in-app alerts
 * Integrates with Firebase Cloud Messaging (FCM)
 * 
 * Features:
 * - Send push notifications
 * - Create in-app notifications
 * - Batch notifications
 * - Notification scheduling
 * ============================================
 */

const Notification = require('../models/Notification');
const User = require('../models/User');
const admin = require('firebase-admin');

class NotificationService {
  constructor() {
    // Initialize Firebase Admin (if credentials provided)
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      try {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
        
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount)
        });

        this.messaging = admin.messaging();
        console.log('✅ Firebase Cloud Messaging initialized');
      } catch (error) {
        console.error('❌ Firebase initialization error:', error. message);
        this.messaging = null;
      }
    } else {
      console.log('ℹ️  Firebase not configured (FCM disabled)');
      this.messaging = null;
    }
  }

  /**
   * Create in-app notification
   */
  async createNotification(data) {
    try {
      const notification = await Notification.create({
        user: data.userId,
        type: data.type,
        title: data.title,
        message: data.message,
        priority: data.priority || 'medium',
        relatedItem: data.relatedItem || null,
        metadata: data.metadata || {}
      });

      console.log(`📬 Notification created for user ${data.userId}`);
      return notification;
    } catch (error) {
      console.error('❌ Create notification error:', error);
      throw error;
    }
  }

  /**
   * Send push notification via FCM
   */
  async sendPushNotification(userId, title, message, data = {}) {
    if (!this.messaging) {
      console.log('ℹ️  Push notifications disabled (FCM not configured)');
      return { success: false, reason: 'FCM not configured' };
    }

    try {
      // Get user's FCM token
      const user = await User.findById(userId).select('fcmToken');
      
      if (!user || !user. fcmToken) {
        console.log(`⚠️  No FCM token for user ${userId}`);
        return { success: false, reason: 'No FCM token' };
      }

      // Prepare notification payload
      const payload = {
        notification: {
          title,
          body: message,
          icon: '/icon-192x192.png',
          badge: '/badge-72x72.png'
        },
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        },
        token: user.fcmToken
      };

      // Send notification
      const response = await this.messaging.send(payload);
      
      console.log(`🔔 Push notification sent to user ${userId}: `, response);
      return { success: true, messageId:  response };
    } catch (error) {
      console.error('❌ Push notification error:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send notification (both in-app and push)
   */
  async sendNotification(userId, type, title, message, options = {}) {
    try {
      // Create in-app notification
      const notification = await this.createNotification({
        userId,
        type,
        title,
        message,
        priority: options.priority || 'medium',
        relatedItem: options.relatedItem || null,
        metadata: options. metadata || {}
      });

      // Send push notification if user has enabled it
      const user = await User.findById(userId).select('preferences.pushNotifications');
      
      if (user?. preferences?.pushNotifications) {
        await this.sendPushNotification(userId, title, message, {
          notificationId: notification._id. toString(),
          type,
          ... options. pushData
        });
      }

      return notification;
    } catch (error) {
      console.error('❌ Send notification error:', error);
      throw error;
    }
  }

  /**
   * Send batch notifications
   */
  async sendBatchNotifications(notifications) {
    try {
      const results = await Promise.allSettled(
        notifications.map(notif => 
          this.sendNotification(
            notif.userId,
            notif.type,
            notif.title,
            notif.message,
            notif.options || {}
          )
        )
      );

      const successful = results.filter(r => r.status === 'fulfilled').length;
      const failed = results. filter(r => r.status === 'rejected').length;

      console.log(`📊 Batch notifications:  ${successful} sent, ${failed} failed`);
      
      return { successful, failed, results };
    } catch (error) {
      console.error('❌ Batch notification error:', error);
      throw error;
    }
  }

  /**
   * Send expiry alert notification
   */
  async sendExpiryAlert(userId, groceryItem, daysLeft) {
    let title, message, priority;

    if (daysLeft === 0) {
      title = '🚨 Item Expires Today! ';
      message = `${groceryItem.name} expires today.  Use or discard it immediately.`;
      priority = 'urgent';
    } else if (daysLeft === 1) {
      title = '⚠️ Item Expires Tomorrow';
      message = `${groceryItem.name} expires tomorrow. Plan to use it soon.`;
      priority = 'high';
    } else {
      title = '📅 Item Expiring Soon';
      message = `${groceryItem.name} expires in ${daysLeft} days. `;
      priority = 'medium';
    }

    return await this.sendNotification(
      userId,
      'expiry_alert',
      title,
      message,
      {
        priority,
        relatedItem: groceryItem._id,
        metadata: {
          itemName: groceryItem.name,
          expiryDate: groceryItem.expiryDate,
          daysLeft
        }
      }
    );
  }

  /**
   * Send low stock alert
   */
  async sendLowStockAlert(userId, groceryItem) {
    return await this.sendNotification(
      userId,
      'low_stock',
      '📉 Low Stock Alert',
      `${groceryItem.name} is running low (${groceryItem.quantity} ${groceryItem.unit} left). Consider restocking. `,
      {
        priority: 'medium',
        relatedItem: groceryItem._id,
        metadata: {
          itemName: groceryItem.name,
          quantity: groceryItem.quantity,
          unit: groceryItem.unit
        }
      }
    );
  }

  /**
   * Get unread notification count
   */
  async getUnreadCount(userId) {
    try {
      const count = await Notification.countDocuments({
        user: userId,
        isRead: false
      });

      return count;
    } catch (error) {
      console.error('❌ Get unread count error:', error);
      return 0;
    }
  }

  /**
   * Mark notification as read
   */
  async markAsRead(notificationId) {
    try {
      const notification = await Notification.findById(notificationId);
      
      if (notification) {
        await notification.markAsRead();
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('❌ Mark as read error:', error);
      return false;
    }
  }

  /**
   * Delete old read notifications (cleanup)
   */
  async cleanupOldNotifications(daysOld = 30) {
    try {
      const result = await Notification.cleanupOldNotifications(daysOld);
      console.log(`🗑️  Cleaned up ${result. deletedCount} old notifications`);
      return result. deletedCount;
    } catch (error) {
      console.error('❌ Cleanup error:', error);
      return 0;
    }
  }
}

module.exports = new NotificationService();