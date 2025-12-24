/**
 * ============================================
 * Scheduler Service
 * ============================================
 * Handles scheduled tasks and cron jobs
 * Uses node-cron for task scheduling
 * 
 * Features:
 * - Daily expiry checks
 * - Weekly reports
 * - Monthly cleanup
 * - Auto-notifications
 * - Database maintenance
 * ============================================
 */

const cron = require('node-cron');
const expiryService = require('./expiryService');
const notificationService = require('./notificationService');
const analyticsService = require('./analyticsService');
const emailService = require('./emailService');
const User = require('../models/User');
const Grocery = require('../models/Grocery');

class SchedulerService {
  constructor() {
    this.jobs = [];
    this.isInitialized = false;
  }

  /**
   * Initialize all scheduled tasks
   */
  initialize() {
    if (this.isInitialized) {
      console.log('⚠️  Scheduler already initialized');
      return;
    }

    console.log('🕐 Initializing scheduler service...');

    // Schedule all tasks
    this.scheduleDailyExpiryCheck();
    this.scheduleHourlyNotifications();
    this.scheduleWeeklyReports();
    this.scheduleMonthlyCleanup();
    this.scheduleDatabaseMaintenance();

    this.isInitialized = true;
    console.log(`✅ Scheduler initialized with ${this.jobs.length} jobs`);
  }

  /**
   * Daily expiry check (runs at 9: 00 AM every day)
   */
  scheduleDailyExpiryCheck() {
    const job = cron.schedule('0 9 * * *', async () => {
      console.log('🔍 Running daily expiry check...');
      
      try {
        // Check expiry for all users
        const alertsSent = await expiryService.checkExpiryForAllUsers();
        
        // Auto-mark expired items
        const markedExpired = await expiryService.autoMarkExpiredItems();

        console.log(`✅ Daily expiry check complete. Alerts:  ${alertsSent}, Marked expired: ${markedExpired}`);
      } catch (error) {
        console.error('❌ Daily expiry check error:', error);
      }
    }, {
      scheduled: true,
      timezone: process.env.TIMEZONE || 'UTC'
    });

    this.jobs.push({ name: 'Daily Expiry Check', job });
    console.log('📅 Scheduled:  Daily expiry check at 9:00 AM');
  }

  /**
   * Hourly notification check (runs every hour)
   */
  scheduleHourlyNotifications() {
    const job = cron.schedule('0 * * * *', async () => {
      console.log('🔔 Running hourly notification check...');
      
      try {
        // Check for items expiring today
        const users = await User.find({ 
          isActive: true,
          'preferences.pushNotifications': true 
        });

        let notificationsSent = 0;

        for (const user of users) {
          const today = new Date();
          today.setHours(0, 0, 0, 0);

          const tomorrow = new Date(today);
          tomorrow.setDate(tomorrow.getDate() + 1);

          // Get items expiring today
          const itemsExpiringToday = await Grocery. find({
            user: user._id,
            expiryDate: { $gte: today, $lt: tomorrow },
            status: 'active'
          });

          if (itemsExpiringToday.length > 0) {
            for (const item of itemsExpiringToday) {
              await notificationService.sendExpiryAlert(user._id, item, 0);
              notificationsSent++;
            }
          }
        }

        console.log(`✅ Hourly notification check complete. Sent: ${notificationsSent}`);
      } catch (error) {
        console.error('❌ Hourly notification error:', error);
      }
    }, {
      scheduled: true,
      timezone: process.env. TIMEZONE || 'UTC'
    });

    this.jobs.push({ name: 'Hourly Notifications', job });
    console.log('📅 Scheduled: Hourly notification check');
  }

  /**
   * Weekly summary reports (runs every Monday at 8:00 AM)
   */
  scheduleWeeklyReports() {
    const job = cron.schedule('0 8 * * 1', async () => {
      console.log('📊 Generating weekly reports...');
      
      try {
        const users = await User.find({ 
          isActive: true,
          'preferences.emailNotifications': true 
        });

        for (const user of users) {
          try {
            // Get last 7 days data
            const endDate = new Date();
            const startDate = new Date();
            startDate.setDate(startDate.getDate() - 7);

            // Generate reports
            const [expenseReport, wasteReport] = await Promise.all([
              analyticsService.getExpenseReport(
                user._id,
                startDate. toISOString(),
                endDate.toISOString()
              ),
              analyticsService. getWasteAnalysis(
                user._id,
                startDate.toISOString(),
                endDate.toISOString()
              )
            ]);

            // Send email with weekly summary
            await this.sendWeeklySummaryEmail(user, expenseReport, wasteReport);

          } catch (error) {
            console.error(`❌ Error generating report for user ${user._id}:`, error);
          }
        }

        console.log(`✅ Weekly reports sent to ${users.length} users`);
      } catch (error) {
        console.error('❌ Weekly reports error:', error);
      }
    }, {
      scheduled: true,
      timezone: process.env.TIMEZONE || 'UTC'
    });

    this.jobs.push({ name: 'Weekly Reports', job });
    console.log('📅 Scheduled:  Weekly reports every Monday at 8:00 AM');
  }

  /**
   * Send weekly summary email
   */
  async sendWeeklySummaryEmail(user, expenseReport, wasteReport) {
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background:  linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                    color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .stat-box { background: white; padding: 15px; margin: 10px 0; border-radius:  8px; 
                      border-left: 4px solid #667eea; }
          .stat-label { font-size: 12px; color: #666; text-transform: uppercase; }
          .stat-value { font-size: 24px; font-weight: bold; color: #667eea; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📊 Your Weekly Grocery Summary</h1>
          </div>
          <div class="content">
            <h2>Hi ${user.name},</h2>
            <p>Here's your grocery activity summary for the past week:</p>

            <h3>💰 Spending Overview</h3>
            <div class="stat-box">
              <div class="stat-label">Total Spent</div>
              <div class="stat-value">$${expenseReport.summary.totalExpense}</div>
            </div>
            <div class="stat-box">
              <div class="stat-label">Items Purchased</div>
              <div class="stat-value">${expenseReport.summary.totalItems}</div>
            </div>
            <div class="stat-box">
              <div class="stat-label">Average per Day</div>
              <div class="stat-value">$${expenseReport.summary. avgExpensePerDay}</div>
            </div>

            <h3>🗑️ Waste Analysis</h3>
            <div class="stat-box">
              <div class="stat-label">Items Wasted</div>
              <div class="stat-value">${wasteReport.summary.totalWastedItems}</div>
            </div>
            <div class="stat-box">
              <div class="stat-label">Waste Value</div>
              <div class="stat-value">$${wasteReport.summary. totalWasteValue}</div>
            </div>

            ${wasteReport.recommendations.length > 0 ? `
              <h3>💡 Recommendations</h3>
              <ul>
                ${wasteReport.recommendations.slice(0, 3).map(rec => `
                  <li><strong>${rec.category}:</strong> ${rec.recommendation}</li>
                `).join('')}
              </ul>
            ` : ''}

            <p style="margin-top: 30px;">
              <a href="${process.env.FRONTEND_URL}/reports" 
                 style="display: inline-block; padding: 12px 30px; background: #667eea; 
                        color: white; text-decoration: none; border-radius: 5px;">
                View Detailed Report
              </a>
            </p>

            <p>Keep up the great work managing your groceries! </p>
            
            <p>Best regards,<br>Smart Grocery Team</p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} Smart Grocery.  All rights reserved.</p>
            <p><a href="${process.env. FRONTEND_URL}/settings">Manage preferences</a></p>
          </div>
        </div>
      </body>
      </html>
    `;

    await emailService.sendEmail({
      email: user.email,
      subject: '📊 Your Weekly Grocery Summary',
      html
    });
  }

  /**
   * Monthly cleanup (runs on 1st of every month at 2:00 AM)
   */
  scheduleMonthlyCleanup() {
    const job = cron.schedule('0 2 1 * *', async () => {
      console.log('🧹 Running monthly cleanup...');
      
      try {
        // Clean up old notifications (older than 30 days)
        const notifsCleaned = await notificationService. cleanupOldNotifications(30);

        // Clean up old expired items (older than 90 days)
        const expiredCleaned = await Grocery.deleteMany({
          status: 'expired',
          updatedAt: { $lt: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000) }
        });

        // Clean up consumed items (older than 60 days)
        const consumedCleaned = await Grocery. deleteMany({
          status: 'consumed',
          consumedAt: { $lt: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000) }
        });

        console.log(`✅ Monthly cleanup complete. Notifications: ${notifsCleaned}, Expired: ${expiredCleaned. deletedCount}, Consumed: ${consumedCleaned.deletedCount}`);
      } catch (error) {
        console.error('❌ Monthly cleanup error:', error);
      }
    }, {
      scheduled: true,
      timezone: process.env.TIMEZONE || 'UTC'
    });

    this.jobs.push({ name: 'Monthly Cleanup', job });
    console.log('📅 Scheduled: Monthly cleanup on 1st at 2:00 AM');
  }

  /**
   * Database maintenance (runs every Sunday at 3:00 AM)
   */
  scheduleDatabaseMaintenance() {
    const job = cron.schedule('0 3 * * 0', async () => {
      console.log('🔧 Running database maintenance...');
      
      try {
        const mongoose = require('mongoose');

        // Get database statistics
        const stats = await mongoose. connection.db.stats();
        console.log('📊 Database stats:', {
          collections: stats.collections,
          dataSize: `${(stats.dataSize / 1024 / 1024).toFixed(2)} MB`,
          indexSize: `${(stats.indexSize / 1024 / 1024).toFixed(2)} MB`
        });

        // Optimize indexes (example)
        const collections = await mongoose.connection.db. listCollections().toArray();
        
        for (const collection of collections) {
          try {
            await mongoose.connection.db.collection(collection.name).reIndex();
            console.log(`✅ Reindexed:  ${collection.name}`);
          } catch (error) {
            console.error(`❌ Error reindexing ${collection.name}:`, error.message);
          }
        }

        console.log('✅ Database maintenance complete');
      } catch (error) {
        console.error('❌ Database maintenance error:', error);
      }
    }, {
      scheduled: true,
      timezone: process.env.TIMEZONE || 'UTC'
    });

    this.jobs.push({ name: 'Database Maintenance', job });
    console.log('📅 Scheduled: Database maintenance every Sunday at 3:00 AM');
  }

  /**
   * Manual trigger for expiry check (for testing)
   */
  async triggerExpiryCheck() {
    console.log('🔍 Manual expiry check triggered.. .');
    try {
      const result = await expiryService.checkExpiryForAllUsers();
      console.log(`✅ Manual expiry check complete. Alerts sent: ${result}`);
      return result;
    } catch (error) {
      console.error('❌ Manual expiry check error:', error);
      throw error;
    }
  }

  /**
   * Stop all scheduled jobs
   */
  stopAll() {
    console.log('🛑 Stopping all scheduled jobs...');
    this.jobs.forEach(({ name, job }) => {
      job.stop();
      console.log(`⏹️  Stopped:  ${name}`);
    });
    this.isInitialized = false;
    console.log('✅ All jobs stopped');
  }

  /**
   * Get status of all jobs
   */
  getStatus() {
    return {
      initialized: this.isInitialized,
      totalJobs: this.jobs.length,
      jobs: this.jobs.map(({ name }) => ({
        name,
        status:  'running'
      }))
    };
  }

  /**
   * Restart scheduler
   */
  restart() {
    console.log('🔄 Restarting scheduler.. .');
    this.stopAll();
    this.initialize();
  }
}

module.exports = new SchedulerService();