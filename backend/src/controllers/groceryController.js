/**
 * Grocery Controller
 * Handles all grocery item CRUD operations
 * Implements the core functionality of the grocery management system
 */

const Grocery = require('../models/Grocery');
const Category = require('../models/Category');
const { validationResult } = require('express-validator');

/**
 * Get all grocery items for the logged-in user
 * @route GET /api/groceries
 * @access Private
 */
exports.getAllGroceries = async (req, res) => {
  try {
    const { 
      category, 
      status, 
      search, 
      sortBy = 'createdAt',
      sortOrder = 'desc',
      page = 1,
      limit = 20
    } = req.query;

    // Build query
    const query = { userId: req.user.userId };

    // Filter by category
    if (category) {
      query.category = category;
    }

    // Filter by status
    if (status) {
      query.status = status;
    }

    // Search in name and description
    if (search) {
      query.$or = [
        { name: { $regex: search, $options:  'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }

    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Execute query
    const groceries = await Grocery.find(query)
      .populate('category', 'name icon color')
      .sort({ [sortBy]: sortOrder === 'desc' ? -1 : 1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Grocery.countDocuments(query);

    res.status(200).json({
      success: true,
      data: {
        groceries,
        pagination: {
          page:  parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit))
        }
      }
    });

  } catch (error) {
    console.error('Get groceries error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

/**
 * Get a single grocery item by ID
 * @route GET /api/groceries/: id
 * @access Private
 */
exports.getGroceryById = async (req, res) => {
  try {
    const grocery = await Grocery.findOne({
      _id: req.params.id,
      userId: req.user.userId
    }).populate('category', 'name icon color');

    if (!grocery) {
      return res.status(404).json({
        success: false,
        message: 'Grocery item not found'
      });
    }

    res.status(200).json({
      success: true,
      data:  grocery
    });

  } catch (error) {
    console.error('Get grocery error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error:  error.message
    });
  }
};

/**
 * Create a new grocery item
 * @route POST /api/groceries
 * @access Private
 */
exports.createGrocery = async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const {
      name,
      description,
      category,
      quantity,
      unit,
      price,
      purchaseDate,
      expiryDate,
      location,
      barcode,
      imageUrl,
      notes,
      status
    } = req.body;

    // Verify category exists
    if (category) {
      const categoryExists = await Category.findById(category);
      if (!categoryExists) {
        return res. status(400).json({
          success: false,
          message:  'Invalid category ID'
        });
      }
    }

    // Create grocery item
    const grocery = new Grocery({
      userId: req.user.userId,
      name,
      description,
      category,
      quantity,
      unit:  unit || 'pcs',
      price,
      purchaseDate:  purchaseDate || new Date(),
      expiryDate,
      location,
      barcode,
      imageUrl,
      notes,
      status:  status || 'active',
      createdAt: new Date(),
      updatedAt: new Date()
    });

    await grocery.save();

    // Populate category before sending response
    await grocery.populate('category', 'name icon color');

    res.status(201).json({
      success: true,
      message:  'Grocery item created successfully',
      data: grocery
    });

  } catch (error) {
    console.error('Create grocery error:', error);
    res.status(500).json({
      success: false,
      message:  'Server error',
      error: error.message
    });
  }
};

/**
 * Update a grocery item
 * @route PUT /api/groceries/:id
 * @access Private
 */
exports.updateGrocery = async (req, res) => {
  try {
    const grocery = await Grocery.findOne({
      _id: req.params.id,
      userId: req.user.userId
    });

    if (!grocery) {
      return res.status(404).json({
        success: false,
        message: 'Grocery item not found'
      });
    }

    const {
      name,
      description,
      category,
      quantity,
      unit,
      price,
      purchaseDate,
      expiryDate,
      location,
      barcode,
      imageUrl,
      notes,
      status
    } = req.body;

    // Verify category if provided
    if (category && category !== grocery.category.toString()) {
      const categoryExists = await Category.findById(category);
      if (!categoryExists) {
        return res.status(400).json({
          success: false,
          message: 'Invalid category ID'
        });
      }
    }

    // Update fields
    if (name) grocery.name = name;
    if (description !== undefined) grocery.description = description;
    if (category) grocery.category = category;
    if (quantity !== undefined) grocery.quantity = quantity;
    if (unit) grocery.unit = unit;
    if (price !== undefined) grocery.price = price;
    if (purchaseDate) grocery.purchaseDate = purchaseDate;
    if (expiryDate !== undefined) grocery.expiryDate = expiryDate;
    if (location) grocery.location = location;
    if (barcode) grocery.barcode = barcode;
    if (imageUrl) grocery.imageUrl = imageUrl;
    if (notes !== undefined) grocery.notes = notes;
    if (status) grocery.status = status;

    grocery.updatedAt = new Date();
    await grocery.save();

    // Populate category
    await grocery.populate('category', 'name icon color');

    res.status(200).json({
      success: true,
      message: 'Grocery item updated successfully',
      data: grocery
    });

  } catch (error) {
    console.error('Update grocery error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

/**
 * Delete a grocery item
 * @route DELETE /api/groceries/:id
 * @access Private
 */
exports. deleteGrocery = async (req, res) => {
  try {
    const grocery = await Grocery.findOneAndDelete({
      _id:  req.params.id,
      userId: req.user.userId
    });

    if (!grocery) {
      return res.status(404).json({
        success: false,
        message: 'Grocery item not found'
      });
    }

    res.status(200).json({
      success: true,
      message:  'Grocery item deleted successfully'
    });

  } catch (error) {
    console.error('Delete grocery error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

/**
 * Mark grocery as consumed/used
 * @route PATCH /api/groceries/:id/consume
 * @access Private
 */
exports.consumeGrocery = async (req, res) => {
  try {
    const { quantityConsumed } = req.body;

    const grocery = await Grocery.findOne({
      _id: req. params.id,
      userId: req.user.userId
    });

    if (!grocery) {
      return res.status(404).json({
        success: false,
        message: 'Grocery item not found'
      });
    }

    if (quantityConsumed && quantityConsumed > 0) {
      grocery.quantity = Math.max(0, grocery.quantity - quantityConsumed);
    }

    // If quantity reaches 0, mark as consumed
    if (grocery.quantity === 0) {
      grocery.status = 'consumed';
    }

    grocery.updatedAt = new Date();
    await grocery. save();

    await grocery.populate('category', 'name icon color');

    res.status(200).json({
      success: true,
      message:  'Grocery item updated successfully',
      data: grocery
    });

  } catch (error) {
    console.error('Consume grocery error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

/**
 * Get groceries by category
 * @route GET /api/groceries/category/:categoryId
 * @access Private
 */
exports.getGroceriesByCategory = async (req, res) => {
  try {
    const groceries = await Grocery.find({
      userId: req.user.userId,
      category: req.params.categoryId
    })
      .populate('category', 'name icon color')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: groceries
    });

  } catch (error) {
    console.error('Get groceries by category error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

/**
 * Get grocery statistics
 * @route GET /api/groceries/stats
 * @access Private
 */
exports.getGroceryStats = async (req, res) => {
  try {
    const userId = req.user.userId;

    const stats = await Grocery.aggregate([
      { $match: { userId: userId } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          totalValue: { $sum: { $multiply: ['$quantity', '$price'] } }
        }
      }
    ]);

    // Get count by category
    const categoryStats = await Grocery.aggregate([
      { $match: { userId: userId } },
      {
        $group: {
          _id: '$category',
          count: { $sum: 1 }
        }
      },
      {
        $lookup: {
          from: 'categories',
          localField: '_id',
          foreignField: '_id',
          as: 'categoryInfo'
        }
      }
    ]);

    res.status(200).json({
      success: true,
      data: {
        statusStats: stats,
        categoryStats
      }
    });

  } catch (error) {
    console.error('Get grocery stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

/**
 * Bulk delete groceries
 * @route POST /api/groceries/bulk-delete
 * @access Private
 */
exports.bulkDeleteGroceries = async (req, res) => {
  try {
    const { ids } = req.body;

    if (!ids || !Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Please provide an array of grocery IDs'
      });
    }

    const result = await Grocery.deleteMany({
      _id: { $in: ids },
      userId: req.user. userId
    });

    res.status(200).json({
      success: true,
      message:  `${result.deletedCount} grocery items deleted successfully`,
      deletedCount: result.deletedCount
    });

  } catch (error) {
    console.error('Bulk delete error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error:  error.message
    });
  }
};