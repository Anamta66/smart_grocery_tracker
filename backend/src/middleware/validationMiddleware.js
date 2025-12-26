/**
 * ============================================
 * Validation Middleware
 * ============================================
 * Input validation using express-validator
 * Validates request body, params, and query
 * ============================================
 */

const { body, param, query, validationResult } = require('express-validator');

/**
 * @desc    Handle validation errors
 * @middleware
 */
exports.handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: err. path || err.param,
        message: err.msg,
        value: err.value
      }))
    });
  }

  next();
};

/**
 * User Registration Validation
 */
/**
 * User Registration Validation
 */
exports.validateRegister = [
  body('name')
    .trim()
    .notEmpty().withMessage('Name is required'),

  body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Please provide a valid email address')
    .normalizeEmail(),

  body('password')
    .notEmpty().withMessage('Password is required')
    .isLength({ min: 3 }).withMessage('Password must be at least 3 characters long'),

  body('role')
    .optional(),

  exports.handleValidationErrors
];

/**
 * User Login Validation
 */
exports.validateLogin = [
  body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Please provide a valid email address')
    .normalizeEmail(),

  body('password')
    .notEmpty().withMessage('Password is required'),

  exports.handleValidationErrors
];

/**
 * Create Grocery Item Validation
 */
exports.validateCreateGrocery = [
  body('name')
    .trim()
    .notEmpty().withMessage('Item name is required')
    .isLength({ min: 1, max: 100 }).withMessage('Name must be between 1 and 100 characters'),

  body('category')
    .optional() // Made optional since categoryId might be used instead
    .isMongoId().withMessage('Invalid category ID'),

  body('categoryId')
    .optional() // Support both 'category' and 'categoryId'
    .isString().withMessage('Category ID must be a string'),

  body('quantity')
    .notEmpty().withMessage('Quantity is required')
    .isFloat({ min: 0 }).withMessage('Quantity must be a positive number'),

  body('unit')
    .optional()
    .isIn(['Kg', 'kg', 'Grams', 'g', 'Liters', 'l', 'ml', 'Pieces', 'pcs', 'dozen', 'Packet', 'pack'])
    .withMessage('Invalid unit'),

  body('price')
    .optional()
    .isFloat({ min: 0 }).withMessage('Price must be a positive number'),

  body('expiryDate')
    .optional()
    .isISO8601().withMessage('Invalid expiry date format'),
    // Removed past date check for flexibility

  body('barcode')
    .optional()
    .isString()
    .isLength({ min: 8, max: 20 }).withMessage('Barcode must be between 8 and 20 characters'),

  body('minQuantity')
    .optional()
    .isFloat({ min: 0 }).withMessage('Minimum quantity must be a positive number'),

  exports.handleValidationErrors
];

/**
 * Update Grocery Item Validation
 */
exports. validateUpdateGrocery = [
  param('id')
    .isMongoId().withMessage('Invalid grocery item ID'),

  body('name')
    .optional()
    .trim()
    .isLength({ min: 1, max: 100 }).withMessage('Name must be between 1 and 100 characters'),

  body('category')
    .optional()
    .isMongoId().withMessage('Invalid category ID'),

  body('categoryId')
    .optional()
    .isString().withMessage('Category ID must be a string'),

  body('quantity')
    .optional()
    .isFloat({ min: 0 }).withMessage('Quantity must be a positive number'),

  body('price')
    .optional()
    .isFloat({ min: 0 }).withMessage('Price must be a positive number'),

  body('expiryDate')
    .optional()
    .isISO8601().withMessage('Invalid expiry date format'),

  body('unit')
    .optional()
    .isString().withMessage('Unit must be a string'),

  body('minQuantity')
    .optional()
    .isFloat({ min: 0 }).withMessage('Minimum quantity must be a positive number'),

  exports.handleValidationErrors
];

/**
 * Create Category Validation
 */
exports. validateCreateCategory = [
  body('name')
    .trim()
    .notEmpty().withMessage('Category name is required')
    .isLength({ min: 2, max: 50 }).withMessage('Category name must be between 2 and 50 characters'),

  body('description')
    .optional()
    .trim()
    .isLength({ max: 200 }).withMessage('Description must be less than 200 characters'),

  body('icon')
    .optional()
    .isString()
    .isLength({ max: 50 }).withMessage('Icon must be less than 50 characters'),

  body('color')
    .optional()
    .matches(/^#? ([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3}|[A-Fa-f0-9]{8})$/)
    .withMessage('Color must be a valid hex color code'),

  exports.handleValidationErrors
];

/**
 * Update Category Validation
 */
exports.validateUpdateCategory = [
  param('id')
    .isMongoId().withMessage('Invalid category ID'),

  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 }).withMessage('Category name must be between 2 and 50 characters'),

  body('description')
    .optional()
    .trim()
    .isLength({ max: 200 }).withMessage('Description must be less than 200 characters'),

  body('icon')
    .optional()
    .isString(),

  body('color')
    .optional()
    .isString(),

  exports.handleValidationErrors
];

/**
 * MongoDB ID Validation (for params)
 */
exports.validateMongoId = [
  param('id')
    .isMongoId().withMessage('Invalid ID format'),

  exports.handleValidationErrors
];

/**
 * Pagination Validation
 */
exports. validatePagination = [
  query('page')
    .optional()
    .isInt({ min: 1 }).withMessage('Page must be a positive integer')
    .toInt(),

  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100')
    .toInt(),

  exports.handleValidationErrors
];

/**
 * Search Query Validation
 */
exports.validateSearch = [
  query('q')
    .optional()
    .trim()
    .isLength({ min: 1, max:  100 }).withMessage('Search query must be between 1 and 100 characters'),

  query('category')
    .optional()
    .isMongoId().withMessage('Invalid category ID'),

  query('sortBy')
    .optional()
    .isIn(['name', 'price', 'quantity', 'expiryDate', 'createdAt'])
    .withMessage('Invalid sort field'),

  query('order')
    .optional()
    .isIn(['asc', 'desc'])
    .withMessage('Order must be asc or desc'),

  exports.handleValidationErrors
];

/**
 * Email Validation
 */
exports. validateEmail = [
  body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Please provide a valid email address')
    .normalizeEmail(),

  exports.handleValidationErrors
];

/**
 * Password Reset Validation
 */
exports.validatePasswordReset = [
  body('token')
    .notEmpty().withMessage('Reset token is required'),

  body('newPassword')
    .notEmpty().withMessage('New password is required')
    .isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),

  exports.handleValidationErrors
];

/**
 * Update Password Validation
 */
exports.validateUpdatePassword = [
  body('currentPassword')
    .notEmpty().withMessage('Current password is required'),

  body('newPassword')
    .notEmpty().withMessage('New password is required')
    .isLength({ min: 6 }).withMessage('New password must be at least 6 characters long')
    .custom((value, { req }) => {
      if (value === req.body.currentPassword) {
        throw new Error('New password must be different from current password');
      }
      return true;
    }),

  exports.handleValidationErrors
];

/**
 * Notification Validation
 */
exports. validateCreateNotification = [
  body('title')
    .trim()
    .notEmpty().withMessage('Title is required')
    .isLength({ min: 1, max:  100 }).withMessage('Title must be between 1 and 100 characters'),

  body('message')
    .trim()
    .notEmpty().withMessage('Message is required')
    .isLength({ min: 1, max: 500 }).withMessage('Message must be between 1 and 500 characters'),

  body('type')
    .optional()
    .isIn(['expiryWarning', 'expiryAlert', 'lowStock', 'restock', 'general'])
    .withMessage('Invalid notification type'),

  exports.handleValidationErrors
];

/**
 * Custom validator:  Check if value exists in database
 */
exports.validateExists = (model, field = '_id') => {
  return async (value) => {
    const doc = await model.findOne({ [field]:  value });
    if (!doc) {
      throw new Error(`${model.modelName} not found`);
    }
    return true;
  };
};

/**
 * Custom validator: Check if value is unique
 */
exports.validateUnique = (model, field, excludeId = null) => {
  return async (value) => {
    const query = { [field]: value };
    
    if (excludeId) {
      query._id = { $ne: excludeId };
    }

    const doc = await model.findOne(query);
    
    if (doc) {
      throw new Error(`${field} already exists`);
    }
    
    return true;
  };
};