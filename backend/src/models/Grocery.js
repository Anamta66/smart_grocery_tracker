/**
 * ============================================
 * Grocery Model
 * ============================================
 * Represents grocery items in user's list
 * 
 * Features:
 * - Item details and categorization
 * - Quantity tracking
 * - Expiry date management
 * - Price tracking
 * - Barcode support
 * ============================================
 */

const mongoose = require('mongoose');

const grocerySchema = new mongoose. Schema({
  // Owner
  user: {
    type:  mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Grocery item must belong to a user'],
    index: true
  },

  // Basic Information
  name: {
    type: String,
    required: [true, 'Please provide item name'],
    trim: true,
    minlength: [1, 'Item name must be at least 1 character'],
    maxlength: [100, 'Item name cannot exceed 100 characters']
  },

  description: {
    type: String,
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },

  // Categorization
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: [true, 'Please select a category']
  },

  // Quantity & Unit
  quantity: {
    type: Number,
    required: [true, 'Please specify quantity'],
    min: [0, 'Quantity cannot be negative'],
    default: 1
  },

  unit: {
    type: String,
    enum: ['kg', 'g', 'l', 'ml', 'pcs', 'dozen', 'pack', 'bottle', 'can', 'box'],
    default: 'pcs'
  },

  // Pricing
  price: {
    type: Number,
    min: [0, 'Price cannot be negative'],
    default: 0
  },

  currency: {
    type: String,
    default: 'USD',
    enum: ['USD', 'EUR', 'GBP', 'PKR', 'INR']
  },

  // Dates
  purchaseDate: {
    type:  Date,
    default: Date. now
  },

  expiryDate: {
    type:  Date,
    index: true
  },

  // Storage
  location: {
    type: String,
    enum: ['fridge', 'freezer', 'pantry', 'cabinet', 'counter', 'other'],
    default: 'pantry'
  },

  // Identification
  barcode: {
    type: String,
    trim: true,
    sparse: true, // Allow multiple null values
    index: true
  },

  brand: {
    type: String,
    trim: true,
    maxlength: [50, 'Brand name cannot exceed 50 characters']
  },

  // Media
  imageUrl: {
    type: String,
    default: null
  },

  // Status
  status: {
    type: String,
    enum: ['active', 'consumed', 'expired', 'wasted'],
    default: 'active',
    index: true
  },

  // Additional Info
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters']
  },

  tags: [{
    type: String,
    trim: true,
    maxlength: [30, 'Tag cannot exceed 30 characters']
  }],

  // Tracking
  isLowStock: {
    type: Boolean,
    default: false
  },

  lowStockThreshold: {
    type: Number,
    min: [0, 'Threshold cannot be negative'],
    default: 5
  },

  // Timestamps
  createdAt: {
    type: Date,
    default: Date.now,
    index: true
  },

  updatedAt: {
    type:  Date,
    default: Date. now
  },

  consumedAt: {
    type:  Date,
    default: null
  }

}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject:  { virtuals: true }
});

// ============================================
// INDEXES
// ============================================
grocerySchema.index({ user: 1, status: 1 });
grocerySchema.index({ user: 1, category: 1 });
grocerySchema.index({ user: 1, expiryDate: 1 });
grocerySchema.index({ createdAt: -1 });
grocerySchema.index({ name: 'text', description: 'text' }); // Text search

// ============================================
// VIRTUAL FIELDS
// ============================================

// Days until expiry
grocerySchema. virtual('daysUntilExpiry').get(function() {
  if (!this.expiryDate) return null;
  
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const expiry = new Date(this.expiryDate);
  expiry.setHours(0, 0, 0, 0);
  
  const diffTime = expiry - today;
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  return diffDays;
});

// Expiry status
grocerySchema.virtual('expiryStatus').get(function() {
  const daysLeft = this.daysUntilExpiry;
  
  if (daysLeft === null) return 'no_expiry';
  if (daysLeft < 0) return 'expired';
  if (daysLeft === 0) return 'expires_today';
  if (daysLeft <= 2) return 'critical';
  if (daysLeft <= 5) return 'warning';
  if (daysLeft <= 10) return 'attention';
  return 'fresh';
});

// Total value
grocerySchema.virtual('totalValue').get(function() {
  return this.quantity * this.price;
});

// ============================================
// MIDDLEWARE
// ============================================

// Update 'updatedAt' before saving
grocerySchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Check low stock status before saving
grocerySchema.pre('save', function(next) {
  if (this.quantity <= this.lowStockThreshold) {
    this.isLowStock = true;
  } else {
    this.isLowStock = false;
  }
  next();
});

// Auto-update status based on expiry
grocerySchema. pre('save', function(next) {
  if (this.expiryDate) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    if (this.expiryDate < today && this.status === 'active') {
      this.status = 'expired';
    }
  }
  
  if (this.quantity === 0 && this.status === 'active') {
    this.status = 'consumed';
    this.consumedAt = Date.now();
  }
  
  next();
});

// ============================================
// INSTANCE METHODS
// ============================================

// Consume item (reduce quantity)
grocerySchema.methods.consume = async function(amount) {
  if (amount > this.quantity) {
    throw new Error('Cannot consume more than available quantity');
  }
  
  this.quantity -= amount;
  
  if (this.quantity === 0) {
    this.status = 'consumed';
    this.consumedAt = Date. now();
  }
  
  return await this.save();
};

// Restock item
grocerySchema.methods.restock = async function(amount) {
  this.quantity += amount;
  
  if (this.status === 'consumed') {
    this.status = 'active';
  }
  
  return await this.save();
};

// Check if expired
grocerySchema.methods.isExpired = function() {
  if (!this.expiryDate) return false;
  
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  return this.expiryDate < today;
};

// ============================================
// STATIC METHODS
// ============================================

// Get items expiring within days
grocerySchema.statics. getExpiringSoon = async function(userId, days = 7) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const futureDate = new Date(today);
  futureDate.setDate(today.getDate() + days);
  
  return await this.find({
    user: userId,
    expiryDate:  { $gte: today, $lte: futureDate },
    status: 'active'
  })
    .populate('category')
    .sort({ expiryDate: 1 });
};

// Get expired items
grocerySchema.statics.getExpired = async function(userId) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  return await this. find({
    user: userId,
    expiryDate: { $lt: today },
    status: { $in: ['active', 'expired'] }
  })
    .populate('category')
    .sort({ expiryDate: -1 });
};

// Get low stock items
grocerySchema. statics.getLowStock = async function(userId) {
  return await this.find({
    user: userId,
    isLowStock: true,
    status: 'active'
  })
    .populate('category')
    .sort({ quantity: 1 });
};

// Get statistics
grocerySchema.statics. getStats = async function(userId) {
  const stats = await this.aggregate([
    { $match: { user: mongoose.Types.ObjectId(userId) } },
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 },
        totalValue: { $sum: { $multiply: ['$quantity', '$price'] } }
      }
    }
  ]);
  
  return stats;
};

// ============================================
// QUERY HELPERS
// ============================================

// Find active items
grocerySchema.query.active = function() {
  return this.where({ status: 'active' });
};

// Find by category
grocerySchema.query.byCategory = function(categoryId) {
  return this.where({ category: categoryId });
};

// ============================================
// EXPORT MODEL
// ============================================

const Grocery = mongoose.model('Grocery', grocerySchema);

module.exports = Grocery;