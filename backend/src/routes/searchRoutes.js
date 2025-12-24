/**
 * ============================================
 * Search Routes
 * ============================================
 * Handles advanced search and filtering
 * 
 * Routes:
 * - GET / - Global search
 * - POST /filter - Advanced filter
 * - GET /suggestions - Search suggestions
 * - GET /recent - Recent searches
 * - DELETE /recent - Clear recent searches
 * - GET /barcode/:code - Barcode search
 * - GET /popular - Popular searches
 * ============================================
 */

const express = require('express');
const router = express.Router();

// Controllers
const {
  searchGroceries,
  advancedFilter,
  getSearchSuggestions,
  getRecentSearches,
  clearRecentSearches,
  searchByBarcode,
  getPopularSearches
} = require('../controllers/searchController');

// Middleware
const { protect } = require('../middleware/authMiddleware');
const { searchLimiter, apiLimiter } = require('../middleware/rateLimitMiddleware');
const { validateSearch, validatePagination } = require('../middleware/validationMiddleware');

// Apply protection
router.use(protect);

// ============================================
// SEARCH ROUTES
// ============================================

/**
 * @route   GET /api/v1/search
 * @desc    Global search for grocery items
 * @access  Private
 * @query   q, category, minQuantity, maxQuantity, expiryStatus, sortBy, order, limit, page
 */
router.get('/', searchLimiter, validateSearch, validatePagination, searchGroceries);

/**
 * @route   POST /api/v1/search/filter
 * @desc    Advanced filter with multiple conditions
 * @access  Private
 */
router.post('/filter', apiLimiter, advancedFilter);

/**
 * @route   GET /api/v1/search/suggestions
 * @desc    Get search suggestions (autocomplete)
 * @access  Private
 * @query   q (partial search term)
 */
router.get('/suggestions', searchLimiter, getSearchSuggestions);

/**
 * @route   GET /api/v1/search/recent
 * @desc    Get recent searches
 * @access  Private
 */
router.get('/recent', apiLimiter, getRecentSearches);

/**
 * @route   DELETE /api/v1/search/recent
 * @desc    Clear recent searches
 * @access  Private
 */
router.delete('/recent', apiLimiter, clearRecentSearches);

/**
 * @route   GET /api/v1/search/barcode/:code
 * @desc    Search by barcode/QR code
 * @access  Private
 */
router.get('/barcode/:code', apiLimiter, searchByBarcode);

/**
 * @route   GET /api/v1/search/popular
 * @desc    Get popular searches
 * @access  Private
 */
router.get('/popular', apiLimiter, getPopularSearches);

module.exports = router;