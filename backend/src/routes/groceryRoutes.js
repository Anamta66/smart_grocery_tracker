/**
 * ============================================
 * Grocery Routes
 * ============================================
 * Handles grocery item CRUD operations
 * 
 * Routes:
 * - GET / - Get all groceries
 * - POST / - Create grocery item
 * - GET /:id - Get grocery by ID
 * - PUT /: id - Update grocery
 * - DELETE /:id - Delete grocery
 * - PATCH /:id/consume - Consume item
 * - GET /category/:categoryId - Get by category
 * - GET /stats - Get statistics
 * - POST /bulk-delete - Bulk delete
 * ============================================
 */

const express = require('express');
const router = express.Router();

// Controllers
const {
  getAllGroceries,
  getGroceryById,
  createGrocery,
  updateGrocery,
  deleteGrocery,
  consumeGrocery,
  getGroceriesByCategory,
  getGroceryStats,
  bulkDeleteGroceries
} = require('../controllers/groceryController');

// Middleware
const { protect } = require('../middleware/authMiddleware');
const { apiLimiter, uploadLimiter } = require('../middleware/rateLimitMiddleware');
const {
  validateCreateGrocery,
  validateUpdateGrocery,
  validateMongoId,
  validatePagination
} = require('../middleware/validationMiddleware');
const {
  uploadSingleImage,
  processUpload,
  handleUploadError
} = require('../middleware/uploadMiddleware');

// Apply protection to all routes
router.use(protect);

// Apply rate limiting
router.use(apiLimiter);

// ============================================
// GROCERY CRUD ROUTES
// ============================================

/**
 * @route   GET /api/v1/groceries
 * @desc    Get all grocery items for logged-in user
 * @access  Private
 * @query   category, status, search, sortBy, sortOrder, page, limit
 */
router. get('/', validatePagination, getAllGroceries);

/**
 * @route   POST /api/v1/groceries
 * @desc    Create new grocery item
 * @access  Private
 */
router.post(
  '/',
  uploadLimiter,
  uploadSingleImage,
  handleUploadError,
  processUpload,
  validateCreateGrocery,
  createGrocery
);

/**
 * @route   GET /api/v1/groceries/stats
 * @desc    Get grocery statistics
 * @access  Private
 */
router.get('/stats', getGroceryStats);

/**
 * @route   GET /api/v1/groceries/category/:categoryId
 * @desc    Get groceries by category
 * @access  Private
 */
router. get('/category/:categoryId', validateMongoId, getGroceriesByCategory);

/**
 * @route   POST /api/v1/groceries/bulk-delete
 * @desc    Bulk delete grocery items
 * @access  Private
 */
router.post('/bulk-delete', bulkDeleteGroceries);

/**
 * @route   GET /api/v1/groceries/: id
 * @desc    Get single grocery item by ID
 * @access  Private
 */
router.get('/:id', validateMongoId, getGroceryById);

/**
 * @route   PUT /api/v1/groceries/: id
 * @desc    Update grocery item
 * @access  Private
 */
router.put(
  '/:id',
  uploadSingleImage,
  handleUploadError,
  processUpload,
  validateUpdateGrocery,
  updateGrocery
);

/**
 * @route   DELETE /api/v1/groceries/:id
 * @desc    Delete grocery item
 * @access  Private
 */
router.delete('/:id', validateMongoId, deleteGrocery);

/**
 * @route   PATCH /api/v1/groceries/:id/consume
 * @desc    Consume/reduce quantity of grocery item
 * @access  Private
 */
router.patch('/:id/consume', validateMongoId, consumeGrocery);

module.exports = router;