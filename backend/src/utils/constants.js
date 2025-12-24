/**
 * ============================================
 * Constants Utility
 * ============================================
 * Application-wide constants and enums
 * ============================================
 */

// User Roles
exports.USER_ROLES = {
  USER: 'user',
  ADMIN: 'admin',
  STORE_OWNER: 'store_owner'
};

// Grocery Status
exports.GROCERY_STATUS = {
  ACTIVE: 'active',
  CONSUMED: 'consumed',
  EXPIRED: 'expired',
  WASTED: 'wasted'
};

// Notification Types
exports.NOTIFICATION_TYPES = {
  EXPIRY_ALERT: 'expiry_alert',
  LOW_STOCK: 'low_stock',
  PRICE_ALERT: 'price_alert',
  GENERAL:  'general',
  SYSTEM: 'system',
  REMINDER: 'reminder'
};

// Notification Priority
exports.NOTIFICATION_PRIORITY = {
  LOW: 'low',
  MEDIUM: 'medium',
  HIGH: 'high',
  URGENT: 'urgent'
};

// Measurement Units
exports.MEASUREMENT_UNITS = {
  KG: 'kg',
  GRAM: 'g',
  LITER: 'l',
  MILLILITER: 'ml',
  PIECES: 'pcs',
  DOZEN: 'dozen',
  PACK: 'pack',
  BOTTLE: 'bottle',
  CAN: 'can',
  BOX: 'box'
};

// Storage Locations
exports.STORAGE_LOCATIONS = {
  FRIDGE: 'fridge',
  FREEZER: 'freezer',
  PANTRY: 'pantry',
  CABINET: 'cabinet',
  COUNTER: 'counter',
  OTHER: 'other'
};

// HTTP Status Codes
exports.HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  UNPROCESSABLE_ENTITY: 422,
  INTERNAL_SERVER_ERROR: 500
};

// Error Messages
exports.ERROR_MESSAGES = {
  INVALID_CREDENTIALS: 'Invalid email or password',
  UNAUTHORIZED: 'You are not authorized to access this resource',
  NOT_FOUND: 'Resource not found',
  VALIDATION_ERROR: 'Validation failed',
  SERVER_ERROR: 'Internal server error',
  TOKEN_EXPIRED: 'Token has expired',
  TOKEN_INVALID: 'Invalid token'
};

// Success Messages
exports.SUCCESS_MESSAGES = {
  LOGIN_SUCCESS: 'Login successful',
  LOGOUT_SUCCESS: 'Logout successful',
  CREATED_SUCCESS: 'Resource created successfully',
  UPDATED_SUCCESS: 'Resource updated successfully',
  DELETED_SUCCESS: 'Resource deleted successfully'
};

// Pagination
exports.PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100
};

// File Upload
exports.FILE_UPLOAD = {
  MAX_SIZE: 5 * 1024 * 1024, // 5MB
  ALLOWED_IMAGE_TYPES: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
  ALLOWED_EXTENSIONS:  ['jpg', 'jpeg', 'png', 'gif', 'webp']
};

// Date Formats
exports.DATE_FORMATS = {
  ISO:  'YYYY-MM-DD',
  FULL: 'YYYY-MM-DD HH:mm:ss',
  SHORT: 'MMM DD, YYYY',
  LONG: 'MMMM DD, YYYY'
};

// Expiry Thresholds (days)
exports.EXPIRY_THRESHOLDS = {
  CRITICAL: 2,
  WARNING: 5,
  ATTENTION: 10
};

// Email Templates
exports.EMAIL_SUBJECTS = {
  WELCOME: 'Welcome to Smart Grocery! ',
  PASSWORD_RESET: 'Password Reset Request',
  EXPIRY_ALERT: 'Items Expiring Soon',
  LOW_STOCK: 'Low Stock Alert',
  WEEKLY_SUMMARY: 'Your Weekly Grocery Summary'
};

module.exports = exports;