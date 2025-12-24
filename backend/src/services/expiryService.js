/**
 * ============================================
 * Expiry Service
 * ============================================
 * Handles expiry checking and alert logic
 * 
 * Features:
 * - Check items for expiry
 * - Send expiry alerts
 * - Generate expiry reports
 * - Auto-cleanup expired items
 * ============================================
 */

const Grocery = require('../models/Grocery');
const User = require('../models/User');
const notificationService = require('./notificationService');
const emailService = require('./emailService');

class ExpiryService {
  /**
   * Check and send expiry alerts for all users
   */
  async checkExpiryForAllUsers() {
    try {
      console.log('🔍 Starting expiry check for all users...');

      const users = await User.find({ isActive: true });
      let totalAlertsSent = 0;

      for (const user of users) {
        const alerts = await this.checkExpiryForUser(user._id);
        totalAlertsSent += alerts;
      }

      console.log(`✅ Expiry check complete. ${totalAlertsSent} alerts sent.`);
      return totalAlertsSent;
    } catch (error) {
      console.error('❌ Expiry check error:', error);
      throw error;
    }
  }

  /**
   * Check expiry for a specific user
   */
  async checkExpiryForUser(userId) {
    try {
      const user = await User.findById(userId).select('email name preferences');
      
      if (!user || !user.preferences. emailNotifications) {
        return 0;
      }

      const alertDays = user.preferences.expiryAlertDays || 3;
      
      // Get items expiring within alert days
      const expiringItems = await Grocery.getExpiringSoon(userId, alertDays);

      if (expiringItems.length === 0) {
        return 0;
      }

      // Group items by days until expiry
      const groupedItems = this.groupByDaysLeft(expiringItems);

      let alertsSent = 0;

      // Send notifications for each item
      for (const item of expiringItems) {
        const daysLeft = Math.ceil(
          (item.expiryDate - new Date()) / (1000 * 60 * 60 * 24)
        );

        await notificationService.sendExpiryAlert(userId, item, daysLeft);
        alertsSent++;
      }

      // Send summary email if items are expiring
      if (expiringItems.length > 0) {
        const itemsWithDaysLeft = expiringItems.map(item => ({
          name: item.name,
          expiryDate: item.expiryDate,
          daysLeft: Math.ceil(
            (item.expiryDate - new Date()) / (1000 * 60 * 60 * 24)
          )
        }));

        await emailService.sendExpiryAlertEmail(user, itemsWithDaysLeft);
      }

      console.log(`📧 Sent ${alertsSent} expiry alerts to ${user.email}`);
      return alertsSent;
    } catch (error) {
      console.error(`❌ Expiry check error for user ${userId}:`, error);
      return 0;
    }
  }

  /**
   * Group items by days until expiry
   */
  groupByDaysLeft(items) {
    const grouped = {
      today: [],
      tomorrow: [],
      thisWeek: []
    };

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    items.forEach(item => {
      const daysLeft = Math.ceil(
        (item.expiryDate - today) / (1000 * 60 * 60 * 24)
      );

      if (daysLeft === 0) {
        grouped.today.push(item);
      } else if (daysLeft === 1) {
        grouped.tomorrow.push(item);
      } else if (daysLeft <= 7) {
        grouped.thisWeek.push(item);
      }
    });

    return grouped;
  }

  /**
   * Auto-mark expired items
   */
  async autoMarkExpiredItems() {
    try {
      console.log('🔄 Auto-marking expired items...');

      const result = await Grocery.updateMany(
        {
          expiryDate: { $lt: new Date() },
          status: 'active'
        },
        {
          status: 'expired'
        }
      );

      console.log(`✅ Marked ${result.modifiedCount} items as expired`);
      return result.modifiedCount;
    } catch (error) {
      console.error('❌ Auto-mark expired error:', error);
      return 0;
    }
  }

  /**
   * Generate expiry report
   */
  async generateExpiryReport(userId) {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const [expiringSoon, expired, fresh] = await Promise.all([
        Grocery.find({
          user: userId,
          expiryDate: {
            $gte: today,
            $lte: new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)
          },
          status: 'active'
        }).populate('category'),

        Grocery.find({
          user: userId,
          expiryDate: { $lt: today },
          status: { $in: ['active', 'expired'] }
        }).populate('category'),

        Grocery.find({
          user: userId,
          expiryDate: { $gt: new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000) },
          status: 'active'
        }).populate('category')
      ]);

      return {
        summary: {
          expiringSoon: expiringSoon.length,
          expired: expired.length,
          fresh: fresh.length,
          total: expiringSoon.length + expired.length + fresh.length
        },
        items: {
          expiringSoon,
          expired,
          fresh
        }
      };
    } catch (error) {
      console.error('❌ Generate expiry report error:', error);
      throw error;
    }
  }

  /**
   * Get expiry statistics
   */
  async getExpiryStats(userId) {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const stats = await Grocery.aggregate([
        { $match: { user: userId } },
        {
          $project: {
            name: 1,
            expiryDate: 1,
            status: 1,
            daysUntilExpiry: {
              $divide: [
                { $subtract:  ['$expiryDate', today] },
                1000 * 60 * 60 * 24
              ]
            }
          }
        },
        {
          $group: {
            _id: {
              $cond: [
                { $lt: ['$daysUntilExpiry', 0] }, 'expired',
                { $cond: [
                  { $lte: ['$daysUntilExpiry', 3] }, 'critical',
                  { $cond: [
                    { $lte: ['$daysUntilExpiry', 7] }, 'warning',
                    'fresh'
                  ]}
                ]}
              ]
            },
            count: { $sum: 1 }
          }
        }
      ]);

      const formatted = {
        expired: 0,
        critical: 0,
        warning: 0,
        fresh: 0
      };

      stats.forEach(stat => {
        formatted[stat._id] = stat. count;
      });

      return formatted;
    } catch (error) {
      console.error('❌ Get expiry stats error:', error);
      throw error;
    }
  }
}

module.exports = new ExpiryService();