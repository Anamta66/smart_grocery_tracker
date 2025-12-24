/**
 * ============================================
 * Inventory Routes
 * ============================================
 * Handles inventory management (Store Owners)
 * 
 * Routes:
 * - GET / - Get all inventory items
 * - POST / - Create inventory item
 * - GET /low-stock - Get low stock items
 * - GET /:id - Get inventory item
 * - PUT /:id - Update inventory item
 * - DELETE /:id - Delete inventory item
 * - PATCH /:id/restock - Restock item
 * ============================================
 */

const express = require('express');
const router = express.Router();

// Controllers
const {
  getAllInventory,
  getInventoryById,
  createInventoryItem,
  updateInventoryItem,
  deleteInventoryItem,
  restockItem,
  getLowStockItems
} = require('../controllers/inventoryController');

// Middleware
const { protect, authorize } = require('../middleware/authMiddleware');
const { apiLimiter } = require('../middleware/rateLimitMiddleware');
const { validateMongoId, validatePagination } = require('../middleware/validationMiddleware');

// Apply protection - Only store owners and admins
router.use(protect);
router.use(authorize('store_owner', 'admin'));
router.use(apiLimiter);

// ============================================
// INVENTORY ROUTES
// ============================================

/**
 * @route   GET /api/v1/inventory
 * @desc    Get all inventory items
 * @access  Private (Store Owner/Admin)
 */
router.get('/', validatePagination, getAllInventory);

/**
 * @route   POST /api/v1/inventory
 * @desc    Create inventory item
 * @access  Private (Store Owner/Admin)
 */
router.post('/', createInventoryItem);

/**
 * @route   GET /api/v1/inventory/low-stock
 * @desc    Get low stock items
 * @access  Private (Store Owner/Admin)
 */
router.get('/low-stock', getLowStockItems);

/**
 * @route   GET /api/v1/inventory/:id
 * @desc    Get single inventory item
 * @access  Private (Store Owner/Admin)
 */
router.get('/: id', validateMongoId, getInventoryById);

/**
 * @route   PUT /api/v1/inventory/:id
 * @desc    Update inventory item
 * @access  Private (Store Owner/Admin)
 */
router.put('/:id', validateMongoId, updateInventoryItem);

/**
 * @route   DELETE /api/v1/inventory/:id
 * @desc    Delete inventory item
 * @access  Private (Store Owner/Admin)
 */
router.delete('/:id', validateMongoId, deleteInventoryItem);

/**
 * @route   PATCH /api/v1/inventory/: id/restock
 * @desc    Restock inventory item
 * @access  Private (Store Owner/Admin)
 */
router.patch('/:id/restock', validateMongoId, restockItem);

module.exports = router;