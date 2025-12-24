/**
 * ============================================
 * Notification Model
 * ============================================
 * Represents user notifications
 * 
 * Features:
 * - Different notification types
 * - Read/unread status
 * - Priority levels
 * - Related items reference
 * ============================================
 */

const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  // Recipient
  user: {
    type:  mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Notification must belong to a user'],
    index: true
  },

  // Notification Details
  type: {
    type: String,
    enum: [
      'expiry_alert',
      'low_stock',
      'price_alert',
      'general',
      'system',
      'reminder'
    ],
    required: [true, 'Notification type is required'],
    index:  true
  },

  title: {
    type: String,
    required: [true, 'Notification title is required'],
    trim: true,
    maxlength: [100, 'Title cannot exceed 100 characters']
  },

  message: {
    type: String,
    required: [true, 'Notification message is required'],
    trim: true,
    maxlength: [500, 'Message cannot exceed 500 characters']
  },

  // Priority
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium',
    index: true
  },

  // Status
  isRead: {
    type: Boolean,
    default:  false,
    index: true
  },

  readAt: {
    type: Date,
    default: null
  },

  // Related Item (optional)
  relatedItem: {
    type:  mongoose.Schema.Types.ObjectId,
    ref: 'Grocery',
    default: null
  },

  // Action (optional)
  actionUrl: {
    type: String,
    trim: true
  },

  actionLabel: {
    type: String,
    trim: true,
    maxlength: [50, 'Action label cannot exceed 50 characters']
  },

  // Additional Data
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },

  // Delivery Status
  isSent: {
    type: Boolean,
    default: false
  },

  sentAt: {
    type: Date,
    default: null
  },

  // Expiry
  expiresAt: {
    type: Date,
    default: function() {
      // Auto-expire after 30 days
      return new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    }
  },

  // Timestamps
  createdAt: {
    type: Date,
    default: Date.now,
    index: true
  }

}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject:  { virtuals: true }
});

// ============================================
// INDEXES
// ============================================
notificationSchema.index({ user: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ user: 1, type: 1 });
notificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index

// ============================================
// VIRTUAL FIELDS
// ============================================

// Time since created
notificationSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diff = now - this. createdAt;
  
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);
  
  if (days > 0) return `${days}d ago`;
  if (hours > 0) return `${hours}h ago`;
  if (minutes > 0) return `${minutes}m ago`;
  return 'Just now';
});

// ============================================
// MIDDLEWARE
// ============================================

// Auto-mark as sent when created
notificationSchema.pre('save', function(next) {
  if (this.isNew && ! this.isSent) {
    this.isSent = true;
    this.sentAt = Date.now();
  }
  next();
});

// ============================================
// INSTANCE METHODS
// ============================================

// Mark as read
notificationSchema.methods.markAsRead = async function() {
  this.isRead = true;
  this. readAt = Date.now();
  return await this.save();
};

// Mark as unread
notificationSchema.methods. markAsUnread = async function() {
  this.isRead = false;
  this.readAt = null;
  return await this.save();
};

// ============================================
// STATIC METHODS
// ============================================

// Create expiry alert notification
notificationSchema.statics. createExpiryAlert = async function(userId, groceryItem, daysLeft) {
  let title, priority;
  
  if (daysLeft === 0) {
    title = '🚨 Item Expires Today!';
    priority = 'urgent';
  } else if (daysLeft === 1) {
    title = '⚠️ Item Expires Tomorrow';
    priority = 'high';
  } else {
    title = '📅 Item Expiring Soon';
    priority = 'medium';
  }
  
  return await this.create({
    user: userId,
    type: 'expiry_alert',
    title,
    message: `${groceryItem.name} ${daysLeft === 0 ? 'expires today' : `expires in ${daysLeft} days`}.  Consider using it soon. `,
    priority,
    relatedItem: groceryItem._id,
    metadata: {
      itemName: groceryItem.name,
      expiryDate: groceryItem.expiryDate,
      daysLeft
    }
  });
};

// Get unread count for user
notificationSchema.statics.getUnreadCount = async function(userId) {
  return await this.countDocuments({
    user: userId,
    isRead: false
  });
};

// Mark all as read for user
notificationSchema.statics.markAllAsRead = async function(userId) {
  return await this.updateMany(
    { user: userId, isRead: false },
    { isRead: true, readAt: Date.now() }
  );
};

// Delete old read notifications (cleanup)
notificationSchema.statics.cleanupOldNotifications = async function(daysOld = 30) {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - daysOld);
  
  return await this.deleteMany({
    isRead: true,
    readAt: { $lt: cutoffDate }
  });
};

// ============================================
// QUERY HELPERS
// ============================================

// Find unread notifications
notificationSchema.query.unread = function() {
  return this.where({ isRead: false });
};

// Find by type
notificationSchema.query. byType = function(type) {
  return this.where({ type });
};

// Find by priority
notificationSchema.query.byPriority = function(priority) {
  return this.where({ priority });
};

// ============================================
// EXPORT MODEL
// ============================================

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification;