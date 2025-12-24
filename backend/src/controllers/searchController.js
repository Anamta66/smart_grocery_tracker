/**
 * ============================================
 * Search Controller
 * ============================================
 * Advanced search and filtering for grocery items
 * 
 * Features:
 * - Global search
 * - Filter by category, expiry, quantity
 * - Sort options
 * - Recent searches
 * - Search suggestions
 * ============================================
 */

const Grocery = require('../models/Grocery');
const Category = require('../models/Category');
const User = require('../models/User');

/**
 * @desc    Global search for grocery items
 * @route   GET /api/search
 * @access  Private
 * @query   q (search query), filters, sort, limit, page
 */
exports. searchGroceries = async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      q,
      category,
      minQuantity,
      maxQuantity,
      expiryStatus, // 'expired', 'expiring_soon', 'fresh'
      sortBy = 'createdAt',
      order = 'desc',
      limit = 20,
      page = 1
    } = req.query;

    // Build search query
    const searchQuery = { user: userId };

    // Text search
    if (q) {
      searchQuery.$or = [
        { name:  { $regex: q, $options: 'i' } },
        { description: { $regex:  q, $options: 'i' } },
        { brand: { $regex: q, $options: 'i' } }
      ];
    }

    // Category filter
    if (category) {
      searchQuery.category = category;
    }

    // Quantity filter
    if (minQuantity !== undefined) {
      searchQuery. quantity = { $gte: parseInt(minQuantity) };
    }
    if (maxQuantity !== undefined) {
      searchQuery.quantity = { 
        ... searchQuery.quantity, 
        $lte: parseInt(maxQuantity) 
      };
    }

    // Expiry status filter
    if (expiryStatus) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      switch (expiryStatus) {
        case 'expired':
          searchQuery.expiryDate = { $lt: today };
          break;
        case 'expiring_soon':
          const sevenDays = new Date(today);
          sevenDays.setDate(today.getDate() + 7);
          searchQuery.expiryDate = { 
            $gte: today, 
            $lte: sevenDays 
          };
          break;
        case 'fresh':
          const thirtyDays = new Date(today);
          thirtyDays.setDate(today.getDate() + 30);
          searchQuery.expiryDate = { $gt: thirtyDays };
          break;
      }
    }

    // Build sort object
    const sortObject = {};
    sortObject[sortBy] = order === 'asc' ? 1 : -1;

    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Execute search
    const results = await Grocery.find(searchQuery)
      .populate('category', 'name icon color')
      .sort(sortObject)
      .limit(parseInt(limit))
      .skip(skip);

    // Get total count
    const total = await Grocery.countDocuments(searchQuery);

    // Save search to user's recent searches (optional)
    if (q) {
      await saveRecentSearch(userId, q);
    }

    res.status(200).json({
      success: true,
      count: results.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
      data: results,
      filters: {
        query: q,
        category,
        minQuantity,
        maxQuantity,
        expiryStatus
      }
    });

  } catch (error) {
    console.error('Error searching groceries:', error);
    res.status(500).json({
      success: false,
      message: 'Search failed',
      error: error. message
    });
  }
};

/**
 * @desc    Advanced filter with multiple conditions
 * @route   POST /api/search/filter
 * @access  Private
 */
exports.advancedFilter = async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      categories,      // Array of category IDs
      priceRange,      // { min, max }
      quantityRange,   // { min, max }
      expiryRange,     // { start, end }
      inStock,         // boolean
      sortBy,
      order = 'desc',
      limit = 20,
      page = 1
    } = req.body;

    const filterQuery = { user: userId };

    // Categories filter
    if (categories && categories.length > 0) {
      filterQuery.category = { $in: categories };
    }

    // Price range
    if (priceRange) {
      filterQuery.price = {};
      if (priceRange.min !== undefined) {
        filterQuery. price.$gte = priceRange.min;
      }
      if (priceRange.max !== undefined) {
        filterQuery. price.$lte = priceRange.max;
      }
    }

    // Quantity range
    if (quantityRange) {
      filterQuery.quantity = {};
      if (quantityRange. min !== undefined) {
        filterQuery.quantity.$gte = quantityRange.min;
      }
      if (quantityRange. max !== undefined) {
        filterQuery.quantity.$lte = quantityRange.max;
      }
    }

    // In stock filter
    if (inStock !== undefined) {
      if (inStock) {
        filterQuery.quantity = { $gt: 0 };
      } else {
        filterQuery.quantity = 0;
      }
    }

    // Expiry date range
    if (expiryRange) {
      filterQuery.expiryDate = {};
      if (expiryRange.start) {
        filterQuery.expiryDate.$gte = new Date(expiryRange.start);
      }
      if (expiryRange.end) {
        filterQuery.expiryDate.$lte = new Date(expiryRange.end);
      }
    }

    // Sorting
    const sortObject = {};
    if (sortBy) {
      sortObject[sortBy] = order === 'asc' ? 1 : -1;
    } else {
      sortObject.createdAt = -1;
    }

    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Execute query
    const results = await Grocery.find(filterQuery)
      .populate('category', 'name icon color')
      .sort(sortObject)
      .limit(parseInt(limit))
      .skip(skip);

    const total = await Grocery.countDocuments(filterQuery);

    res.status(200).json({
      success: true,
      count: results.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
      data: results,
      appliedFilters: req.body
    });

  } catch (error) {
    console.error('Error applying filters:', error);
    res.status(500).json({
      success: false,
      message: 'Filter failed',
      error: error. message
    });
  }
};

/**
 * @desc    Get search suggestions (autocomplete)
 * @route   GET /api/search/suggestions
 * @access  Private
 * @query   q (partial search term)
 */
exports.getSearchSuggestions = async (req, res) => {
  try {
    const userId = req.user.id;
    const { q } = req. query;

    if (!q || q.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Search query must be at least 2 characters'
      });
    }

    // Find matching items
    const suggestions = await Grocery.find({
      user: userId,
      name: { $regex: q, $options: 'i' }
    })
      .select('name category')
      .populate('category', 'name')
      .limit(10);

    // Extract unique names
    const uniqueSuggestions = [...new Set(suggestions.map(item => item. name))];

    res.status(200).json({
      success: true,
      count: uniqueSuggestions.length,
      data: uniqueSuggestions
    });

  } catch (error) {
    console.error('Error fetching suggestions:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch suggestions',
      error: error.message
    });
  }
};

/**
 * @desc    Get recent searches
 * @route   GET /api/search/recent
 * @access  Private
 */
exports.getRecentSearches = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await User.findById(userId).select('recentSearches');

    const recentSearches = user.recentSearches || [];

    res.status(200).json({
      success: true,
      count: recentSearches.length,
      data: recentSearches
    });

  } catch (error) {
    console.error('Error fetching recent searches:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch recent searches',
      error: error.message
    });
  }
};

/**
 * @desc    Clear recent searches
 * @route   DELETE /api/search/recent
 * @access  Private
 */
exports.clearRecentSearches = async (req, res) => {
  try {
    const userId = req.user.id;

    await User.findByIdAndUpdate(userId, {
      recentSearches: []
    });

    res.status(200).json({
      success: true,
      message: 'Recent searches cleared'
    });

  } catch (error) {
    console.error('Error clearing recent searches:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to clear recent searches',
      error: error.message
    });
  }
};

/**
 * @desc    Search by barcode/QR code
 * @route   GET /api/search/barcode/: code
 * @access  Private
 */
exports.searchByBarcode = async (req, res) => {
  try {
    const userId = req.user.id;
    const { code } = req. params;

    const item = await Grocery.findOne({
      user: userId,
      barcode: code
    }).populate('category', 'name icon color');

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Item not found with this barcode'
      });
    }

    res.status(200).json({
      success: true,
      data: item
    });

  } catch (error) {
    console.error('Error searching by barcode:', error);
    res.status(500).json({
      success: false,
      message: 'Barcode search failed',
      error: error.message
    });
  }
};

/**
 * Helper function to save recent search
 */
async function saveRecentSearch(userId, searchQuery) {
  try {
    const user = await User.findById(userId);
    
    if (!user. recentSearches) {
      user.recentSearches = [];
    }

    // Remove duplicate if exists
    user.recentSearches = user.recentSearches.filter(
      s => s !== searchQuery
    );

    // Add to beginning
    user.recentSearches. unshift(searchQuery);

    // Keep only last 10 searches
    user.recentSearches = user. recentSearches.slice(0, 10);

    await user.save();
  } catch (error) {
    console.error('Error saving recent search:', error);
  }
}

/**
 * @desc    Get popular searches (across all users - optional)
 * @route   GET /api/search/popular
 * @access  Private
 */
exports.getPopularSearches = async (req, res) => {
  try {
    // This is a sample implementation
    // In production, you'd track search frequency in a separate collection
    
    const popularItems = await Grocery.aggregate([
      { $group: { _id: '$name', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 10 },
      { $project: { _id: 0, term: '$_id', count: 1 } }
    ]);

    res.status(200).json({
      success: true,
      count: popularItems.length,
      data: popularItems
    });

  } catch (error) {
    console.error('Error fetching popular searches:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch popular searches',
      error: error.message
    });
  }
};
