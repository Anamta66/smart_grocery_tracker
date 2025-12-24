/**
 * ============================================
 * User Model
 * ============================================
 * Represents users in the system (customers and store owners)
 * 
 * Features:
 * - Authentication credentials
 * - User profile information
 * - Preferences and settings
 * - Role-based access control
 * ============================================
 */

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  // Basic Information
  name: {
    type: String,
    required: [true, 'Please provide a name'],
    trim:  true,
    minlength: [2, 'Name must be at least 2 characters'],
    maxlength: [50, 'Name cannot exceed 50 characters']
  },

  email: {
    type:  String,
    required: [true, 'Please provide an email'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Please provide a valid email address'
    ],
    index: true
  },

  password: {
    type: String,
    required: [true, 'Please provide a password'],
    minlength: [6, 'Password must be at least 6 characters'],
    select: false // Don't include password in queries by default
  },

  // Contact Information
  phone: {
    type: String,
    trim: true,
    match: [/^[0-9]{10,15}$/, 'Please provide a valid phone number']
  },

  address: {
    street: { type: String, trim: true },
    city: { type: String, trim: true },
    state: { type: String, trim: true },
    zipCode: { type: String, trim: true },
    country: { type: String, trim: true, default: 'USA' }
  },

  // Profile
  profileImage: {
    type: String,
    default: null
  },

  // Role & Permissions
  role: {
    type: String,
    enum: ['user', 'admin', 'store_owner'],
    default: 'user'
  },

  // Account Status
  isActive: {
    type: Boolean,
    default: true
  },

  isEmailVerified: {
    type:  Boolean,
    default: false
  },

  emailVerificationToken: {
    type: String,
    select: false
  },

  emailVerificationExpires: {
    type: Date,
    select:  false
  },

  // Password Reset
  passwordResetToken: {
    type: String,
    select: false
  },

  passwordResetExpires: {
    type: Date,
    select: false
  },

  // User Preferences
  preferences: {
    theme: {
      type:  String,
      enum: ['light', 'dark', 'system'],
      default: 'system'
    },
    language: {
      type: String,
      enum: ['en', 'es', 'fr', 'de'],
      default: 'en'
    },
    emailNotifications: {
      type:  Boolean,
      default: true
    },
    pushNotifications: {
      type:  Boolean,
      default: true
    },
    expiryAlertDays: {
      type:  Number,
      default: 3,
      min: [1, 'Alert days must be at least 1'],
      max: [30, 'Alert days cannot exceed 30']
    }
  },

  // Recent Searches (for autocomplete)
  recentSearches: [{
    type: String,
    maxlength: 100
  }],

  // Timestamps
  lastLogin: {
    type: Date,
    default: null
  },

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
  toObject: { virtuals: true }
});

// ============================================
// INDEXES
// ============================================
userSchema.index({ email: 1 });
userSchema.index({ createdAt: -1 });

// ============================================
// VIRTUAL FIELDS
// ============================================

// Virtual for full address
userSchema.virtual('fullAddress').get(function() {
  if (! this.address) return null;
  
  const { street, city, state, zipCode, country } = this.address;
  const parts = [street, city, state, zipCode, country].filter(Boolean);
  return parts.join(', ');
});

// Virtual for grocery count (populate separately)
userSchema.virtual('groceryCount', {
  ref: 'Grocery',
  localField: '_id',
  foreignField: 'user',
  count: true
});

// ============================================
// MIDDLEWARE
// ============================================

// Hash password before saving
userSchema.pre('save', async function(next) {
  // Only hash password if it's modified
  if (! this.isModified('password')) {
    return next();
  }

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Update 'updatedAt' timestamp before saving
userSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// ============================================
// INSTANCE METHODS
// ============================================

// Compare entered password with hashed password
userSchema.methods.comparePassword = async function(enteredPassword) {
  try {
    return await bcrypt. compare(enteredPassword, this. password);
  } catch (error) {
    throw new Error('Password comparison failed');
  }
};

// Generate JWT token (to be used with jsonwebtoken library)
userSchema.methods.generateAuthToken = function(jwtSecret, expiresIn = '7d') {
  const jwt = require('jsonwebtoken');
  
  return jwt.sign(
    { userId: this._id, email: this.email, role: this.role },
    jwtSecret,
    { expiresIn }
  );
};

// Check if password was changed after JWT was issued
userSchema.methods.changedPasswordAfter = function(JWTTimestamp) {
  if (this.passwordChangedAt) {
    const changedTimestamp = parseInt(
      this.passwordChangedAt. getTime() / 1000,
      10
    );
    return JWTTimestamp < changedTimestamp;
  }
  return false;
};

// ============================================
// STATIC METHODS
// ============================================

// Find user by credentials
userSchema.statics.findByCredentials = async function(email, password) {
  const user = await this.findOne({ email }).select('+password');
  
  if (!user) {
    throw new Error('Invalid email or password');
  }

  const isPasswordMatch = await user.comparePassword(password);
  
  if (!isPasswordMatch) {
    throw new Error('Invalid email or password');
  }

  return user;
};

// Get active users count
userSchema.statics.getActiveUsersCount = async function() {
  return await this.countDocuments({ isActive: true });
};

// ============================================
// QUERY HELPERS
// ============================================

// Helper to find active users
userSchema.query.active = function() {
  return this.where({ isActive: true });
};

// Helper to find by role
userSchema.query.byRole = function(role) {
  return this.where({ role });
};

// ============================================
// EXPORT MODEL
// ============================================

const User = mongoose.model('User', userSchema);

module.exports = User;