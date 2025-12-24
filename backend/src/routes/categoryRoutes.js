/**
 * ============================================
 * Category Routes
 * ============================================
 * Handles category management
 * 
 * Routes:
 * - GET / - Get all categories
 * - POST / - Create category
 * - GET /:id - Get category by ID
 * - PUT /:id - Update category
 * - DELETE /:id - Delete category
 * - POST /seed - Seed default categories
 * ============================================
 */

const express = require('express');
const router = express.Router();

// Controllers
const {
  getAllCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
  seedCategories
} = require('../controllers/categoryController');

// Middleware
const { protect, authorize } = require('../middleware/authMiddleware');
const { apiLimiter } = require('../middleware/rateLimitMiddleware');
const {
  validateCreateCategory,
  validateMongoId
} = require('../middleware/validationMiddleware');

// Apply protection and rate limiting
router.use(protect);
router.use(apiLimiter);

// ============================================
// CATEGORY ROUTES
// ============================================

/**
 * @route   GET /api/v1/categories
 * @desc    Get all categories with item counts
 * @access  Private
 */
router.get('/', getAllCategories);

/**
 * @route   POST /api/v1/categories
 * @desc    Create new category
 * @access  Private/Admin
 */
router.post('/', authorize('admin', 'store_owner'), validateCreateCategory, createCategory);

/**
 * @route   POST /api/v1/categories/seed
 * @desc    Seed default categories
 * @access  Private/Admin
 */
router.post('/seed', authorize('admin'), seedCategories);

/**
 * @route   GET /api/v1/categories/:id
 * @desc    Get single category by ID
 * @access  Private
 */
router. get('/:id', validateMongoId, getCategoryById);

/**
 * @route   PUT /api/v1/categories/:id
 * @desc    Update category
 * @access  Private/Admin
 */
router.put('/:id', authorize('admin', 'store_owner'), validateMongoId, updateCategory);

/**
 * @route   DELETE /api/v1/categories/:id
 * @desc    Delete category
 * @access  Private/Admin
 */
router.delete('/:id', authorize('admin', 'store_owner'), validateMongoId, deleteCategory);

module.exports = router;