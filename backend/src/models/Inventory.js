/**
 * ============================================
 * Inventory Model
 * ============================================
 * Represents inventory items for store owners
 * Separate from regular grocery items
 * 
 * Features:
 * - Stock management
 * - Supplier information
 * - Batch tracking
 * - Low stock alerts
 * ============================================
 */

const mongoose = require('mongoose');

const inventorySchema = new mongoose.Schema({
  // Store Owner
  storeOwner: {
    type: mongoose.Schema. Types.ObjectId,
    ref: 'User',
    required: [true, 'Inventory item must belong to a store owner'],
    index: true
  },

  // Product Information
  productName: {
    type: String,
    required: [true, 'Product name is required'],
    trim: true,
    maxlength: [100, 'Product name cannot exceed 100 characters']
  },

  sku: {
    type: String,
    trim: true,
    unique: true,
    sparse: true,
    index: true
  },

  barcode: {
    type: String,
    trim: true,
    index: true
  },

  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: [true, 'Category is required']
  },

  // Stock Information
  stockQuantity: {
    type: Number,
    required: [true, 'Stock quantity is required'],
    min: [0, 'Stock quantity cannot be negative'],
    default: 0
  },

  unit: {
    type: String,
    enum: ['kg', 'g', 'l', 'ml', 'pcs', 'dozen', 'pack'],
    default: 'pcs'
  },

  reorderLevel: {
    type: Number,
    min: [0, 'Reorder level cannot be negative'],
    default: 10
  },

  maxStockLevel: {
    type:  Number,
    min: [0, 'Max stock level cannot be negative']
  },

  // Pricing
  costPrice: {
    type: Number,
    required: [true, 'Cost price is required'],
    min: [0, 'Cost price cannot be negative']
  },

  sellingPrice: {
    type:  Number,
    required: [true, 'Selling price is required'],
    min: [0, 'Selling price cannot be negative']
  },

  // Supplier
  supplier: {
    name: { type: String, trim: true },
    contact: { type: String, trim:  true },
    email: { type: String, trim: true }
  },

  // Dates
  lastRestockDate: {
    type: Date,
    default: Date.now
  },

  expiryDate: {
    type: Date
  },

  // Status
  isActive: {
    type: Boolean,
    default: true
  },

  // Timestamps
  createdAt: {
    type:  Date,
    default: Date. now
  },

  updatedAt:  {
    type: Date,
    default: Date.now
  }

}, {
  timestamps:  true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// ============================================
// INDEXES
// ============================================
inventorySchema.index({ storeOwner: 1, stockQuantity: 1 });
inventorySchema.index({ storeOwner: 1, category: 1 });

// ============================================
// VIRTUAL FIELDS
// ============================================

// Check if low stock
inventorySchema.virtual('isLowStock').get(function() {
  return this.stockQuantity <= this.reorderLevel;
});

// Profit margin
inventorySchema.virtual('profitMargin').get(function() {
  return this.sellingPrice - this.costPrice;
});

// Profit percentage
inventorySchema.virtual('profitPercentage').get(function() {
  if (this.costPrice === 0) return 0;
  return ((this.sellingPrice - this.costPrice) / this.costPrice) * 100;
});

// ============================================
// MIDDLEWARE
// ============================================

inventorySchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// ============================================
// INSTANCE METHODS
// ============================================

inventorySchema.methods.restock = async function(quantity) {
  this.stockQuantity += quantity;
  this.lastRestockDate = Date.now();
  return await this.save();
};

inventorySchema.methods.reduceStock = async function(quantity) {
  if (quantity > this.stockQuantity) {
    throw new Error('Insufficient stock');
  }
  
  this.stockQuantity -= quantity;
  return await this.save();
};

// ============================================
// STATIC METHODS
// ============================================

inventorySchema.statics.getLowStockItems = async function(storeOwnerId) {
  return await this.find({
    storeOwner: storeOwnerId,
    $expr: { $lte: ['$stockQuantity', '$reorderLevel'] }
  }).populate('category');
};

// ============================================
// EXPORT MODEL
// ============================================

const Inventory = mongoose.model('Inventory', inventorySchema);

module.exports = Inventory;