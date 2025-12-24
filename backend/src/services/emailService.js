/**
 * ============================================
 * Email Service
 * ============================================
 * Handles all email-related functionality
 * Uses Nodemailer for sending emails
 * 
 * Features:
 * - Send welcome emails
 * - Password reset emails
 * - Expiry alerts
 * - Low stock notifications
 * - Custom transactional emails
 * ============================================
 */

const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    // Create reusable transporter
    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: process.env. SMTP_PORT || 587,
      secure: false, // true for 465, false for other ports
      auth: {
        user: process.env.SMTP_EMAIL,
        pass: process.env.SMTP_PASSWORD
      }
    });

    // Verify connection configuration
    this.transporter.verify((error, success) => {
      if (error) {
        console.error('❌ Email service error:', error);
      } else {
        console.log('✅ Email service ready');
      }
    });
  }

  /**
   * Send email helper function
   * @private
   */
  async sendEmail(options) {
    try {
      const mailOptions = {
        from: `"${process.env.FROM_NAME || 'Smart Grocery'}" <${process.env. SMTP_EMAIL}>`,
        to: options.email,
        subject: options.subject,
        html: options.html,
        text: options.text
      };

      const info = await this.transporter.sendMail(mailOptions);
      
      console.log('📧 Email sent:', info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error('❌ Email sending error:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send welcome email to new users
   */
  async sendWelcomeEmail(user) {
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                    color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .button { display: inline-block; padding: 12px 30px; background: #667eea; 
                    color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🛒 Welcome to Smart Grocery! </h1>
          </div>
          <div class="content">
            <h2>Hi ${user.name},</h2>
            <p>Thank you for joining Smart Grocery Management System!  We're excited to help you manage your groceries efficiently and reduce food waste.</p>
            
            <h3>✨ What you can do:</h3>
            <ul>
              <li>📝 Track all your grocery items</li>
              <li>⏰ Get expiry alerts before items spoil</li>
              <li>📊 Monitor your spending and consumption</li>
              <li>🔔 Receive timely notifications</li>
            </ul>

            <p>Get started by adding your first grocery item! </p>
            
            <a href="${process.env.FRONTEND_URL}/dashboard" class="button">Go to Dashboard</a>

            <p>If you have any questions, feel free to reply to this email. </p>
            
            <p>Happy grocery tracking! <br>
            The Smart Grocery Team</p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} Smart Grocery.  All rights reserved.</p>
            <p>You received this email because you registered at Smart Grocery.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendEmail({
      email: user.email,
      subject: 'Welcome to Smart Grocery!  🎉',
      html
    });
  }

  /**
   * Send password reset email
   */
  async sendPasswordResetEmail(user, resetToken) {
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #f44336; color: white; padding:  30px; text-align:  center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding:  30px; border-radius:  0 0 10px 10px; }
          .button { display: inline-block; padding: 12px 30px; background: #f44336; 
                    color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size:  12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🔐 Password Reset Request</h1>
          </div>
          <div class="content">
            <h2>Hi ${user.name},</h2>
            <p>We received a request to reset your password for your Smart Grocery account.</p>
            
            <p>Click the button below to reset your password: </p>
            
            <a href="${resetUrl}" class="button">Reset Password</a>

            <p>Or copy and paste this link into your browser:</p>
            <p style="background: #eee; padding: 10px; word-break: break-all;">${resetUrl}</p>

            <div class="warning">
              <strong>⚠️ Security Notice:</strong>
              <ul>
                <li>This link will expire in 1 hour</li>
                <li>If you didn't request this, please ignore this email</li>
                <li>Your password won't change until you create a new one</li>
              </ul>
            </div>

            <p>Stay secure,<br>
            The Smart Grocery Team</p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} Smart Grocery. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendEmail({
      email: user.email,
      subject: 'Password Reset Request - Smart Grocery',
      html
    });
  }

  /**
   * Send expiry alert email
   */
  async sendExpiryAlertEmail(user, expiringItems) {
    const itemsList = expiringItems.map(item => `
      <li>
        <strong>${item.name}</strong> - 
        ${item. daysLeft === 0 ? 'Expires TODAY' : `Expires in ${item.daysLeft} days`}
        (${new Date(item.expiryDate).toLocaleDateString()})
      </li>
    `).join('');

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family:  Arial, sans-serif; line-height: 1.6; color: #333; }
          . container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #ff9800; color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .alert-box { background: #fff3cd; border-left: 4px solid #ff9800; padding: 15px; margin: 20px 0; }
          .item-list { background: white; padding: 20px; border-radius: 5px; margin: 20px 0; }
          .button { display: inline-block; padding: 12px 30px; background: #ff9800; 
                    color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>⚠️ Expiry Alert</h1>
          </div>
          <div class="content">
            <h2>Hi ${user.name},</h2>
            
            <div class="alert-box">
              <strong>🔔 You have ${expiringItems.length} item(s) expiring soon!</strong>
            </div>

            <p>The following items need your attention:</p>
            
            <div class="item-list">
              <ul>
                ${itemsList}
              </ul>
            </div>

            <p>💡 <strong>Tip:</strong> Plan your meals around these items to reduce waste!</p>
            
            <a href="${process.env.FRONTEND_URL}/groceries? filter=expiring" class="button">View Items</a>

            <p>Best regards,<br>
            Smart Grocery Alert System</p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} Smart Grocery. All rights reserved.</p>
            <p><a href="${process.env.FRONTEND_URL}/settings">Manage notification preferences</a></p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendEmail({
      email: user.email,
      subject: `⚠️ ${expiringItems.length} Items Expiring Soon - Smart Grocery`,
      html
    });
  }

  /**
   * Send low stock alert email
   */
  async sendLowStockEmail(user, lowStockItems) {
    const itemsList = lowStockItems.map(item => `
      <li><strong>${item.name}</strong> - Only ${item.quantity} ${item.unit} left</li>
    `).join('');

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height:  1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #2196f3; color: white; padding: 30px; text-align: center; border-radius:  10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .item-list { background: white; padding: 20px; border-radius: 5px; margin: 20px 0; }
          .button { display: inline-block; padding: 12px 30px; background: #2196f3; 
                    color:  white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .footer { text-align: center; margin-top:  20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📉 Low Stock Alert</h1>
          </div>
          <div class="content">
            <h2>Hi ${user.name},</h2>
            <p>The following items are running low:</p>
            
            <div class="item-list">
              <ul>
                ${itemsList}
              </ul>
            </div>

            <p>Consider restocking these items soon! </p>
            
            <a href="${process.env.FRONTEND_URL}/groceries?filter=low-stock" class="button">View Items</a>

            <p>Happy shopping! <br>
            Smart Grocery Team</p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} Smart Grocery. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendEmail({
      email: user.email,
      subject: `📉 Low Stock Alert - ${lowStockItems.length} Items Need Restocking`,
      html
    });
  }

  /**
   * Send custom email
   */
  async sendCustomEmail(email, subject, message) {
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding:  20px; }
          . content { background: #f9f9f9; padding: 30px; border-radius: 10px; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size:  12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="content">
            ${message}
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} Smart Grocery. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendEmail({
      email,
      subject,
      html
    });
  }
}

module.exports = new EmailService();