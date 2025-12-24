/**
 * ============================================
 * Category Model
 * ============================================
 * Represents categories for organizing grocery items
 * 
 * Features:
 * - Category name and description
 * - Icon and color for UI
 * - Hierarchical categories (optional)
 * ============================================
 */

const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  // Basic Information
  name: {
    type: String,
    required:  [true, 'Category name is required'],
    unique: true,
    trim: true,
    minlength: [2, 'Category name must be at least 2 characters'],
    maxlength:  [50, 'Category name cannot exceed 50 characters']
  },

  description: {
    type:  String,
    trim: true,
    maxlength: [200, 'Description cannot exceed 200 characters']
  },

  // Visual Properties
  icon: {
    type: String,
    default: '🛒',
    maxlength: [10, 'Icon cannot exceed 10 characters']
  },

  color: {
    type: String,
    default: '#4CAF50',
    match: [/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/, 'Please provide a valid hex color']
  },

  // Hierarchy (optional)
  parent: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    default: null
  },

  // Metadata
  isActive: {
    type: Boolean,
    default: true
  },

  sortOrder: {
    type: Number,
    default: 0
  },

  // Timestamps
  createdAt: {
    type:  Date,
    default: Date. now
  },

  updatedAt: {
    type: Date,
    default: Date.now
  }

}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject:  { virtuals: true }
});

// ============================================
// INDEXES
// ============================================
categorySchema.index({ name: 1 });
categorySchema.index({ isActive: 1, sortOrder: 1 });

// ============================================
// VIRTUAL FIELDS
// ============================================

// Get item count for this category
categorySchema.virtual('itemCount', {
  ref: 'Grocery',
  localField: '_id',
  foreignField: 'category',
  count: true
});

// Get subcategories
categorySchema.virtual('subcategories', {
  ref: 'Category',
  localField: '_id',
  foreignField: 'parent'
});

// ============================================
// MIDDLEWARE
// ============================================

// Update 'updatedAt' before saving
categorySchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Prevent deleting category if it has items
categorySchema.pre('remove', async function(next) {
  const Grocery = mongoose.model('Grocery');
  const count = await Grocery.countDocuments({ category: this._id });
  
  if (count > 0) {
    throw new Error(`Cannot delete category.  ${count} items are using this category.`);
  }
  
  next();
});

// ============================================
// STATIC METHODS
// ============================================

// Get all active categories with item counts
categorySchema.statics. getActiveWithCounts = async function(userId = null) {
  const categories = await this.find({ isActive: true })
    .sort({ sortOrder: 1, name: 1 });
  
  if (!userId) return categories;
  
  // Add item counts for specific user
  const Grocery = mongoose.model('Grocery');
  
  const categoriesWithCounts = await Promise.all(
    categories.map(async (category) => {
      const count = await Grocery. countDocuments({
        user: userId,
        category: category._id
      });
      
      return {
        ...category. toObject(),
        itemCount:  count
      };
    })
  );
  
  return categoriesWithCounts;
};

// Seed default categories
categorySchema.statics.seedDefaults = async function() {
  const defaultCategories = [
    { name: 'Fruits', icon: '🍎', color: '#FF6B6B', sortOrder: 1 },
    { name: 'Vegetables', icon: '🥕', color: '#4CAF50', sortOrder: 2 },
    { name: 'Dairy', icon: '🥛', color: '#2196F3', sortOrder: 3 },
    { name: 'Meat', icon: '🍖', color: '#F44336', sortOrder: 4 },
    { name: 'Seafood', icon: '🐟', color: '#00BCD4', sortOrder: 5 },
    { name: 'Bakery', icon: '🍞', color: '#FF9800', sortOrder: 6 },
    { name: 'Beverages', icon: '🥤', color: '#9C27B0', sortOrder: 7 },
    { name: 'Snacks', icon: '🍿', color: '#FFC107', sortOrder: 8 },
    { name: 'Frozen', icon: '❄️', color: '#00BCD4', sortOrder: 9 },
    { name:  'Canned', icon: '🥫', color: '#795548', sortOrder: 10 },
    { name: 'Condiments', icon: '🧂', color: '#E91E63', sortOrder: 11 },
    { name: 'Other', icon: '📦', color: '#9E9E9E', sortOrder:  12 }
  ];
  
  for (const cat of defaultCategories) {
    await this.findOneAndUpdate(
      { name:  cat.name },
      cat,
      { upsert:  true, new: true }
    );
  }
  
  return defaultCategories. length;
};

// ============================================
// EXPORT MODEL
// ============================================

const Category = mongoose.model('Category', categorySchema);

module.exports = Category;