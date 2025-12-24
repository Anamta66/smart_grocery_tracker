/**
 * Category Controller
 * Handles category management for grocery items
 */

const Category = require('../models/Category');
const Grocery = require('../models/Grocery');
const { validationResult } = require('express-validator');

/**
 * Get all categories
 * @route GET /api/categories
 * @access Private
 */
exports.getAllCategories = async (req, res) => {
  try {
    const categories = await Category.find()
      .sort({ name: 1 });

    // Get item count for each category (for current user)
    const categoriesWithCount = await Promise.all(
      categories.map(async (category) => {
        const count = await Grocery.countDocuments({
          userId: req.user.userId,
          category: category._id
        });
        return {
          ...category. toObject(),
          itemCount: count
        };
      })
    );

    res.status(200).json({
      success: true,
      data:  categoriesWithCount
    });

  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

/**
 * Get category by ID
 * @route GET /api/categories/:id
 * @access Private
 */
exports.getCategoryById = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }

    // Get item count
    const itemCount = await Grocery.countDocuments({
      userId: req. user.userId,
      category: category._id
    });

    res.status(200).json({
      success: true,
      data: {
        ...category.toObject(),
        itemCount
      }
    });

  } catch (error) {
    console.error('Get category error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error:  error.message
    });
  }
};

/**
 * Create a new category
 * @route POST /api/categories
 * @access Private/Admin
 */
exports.createCategory = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const { name, description, icon, color } = req.body;

    // Check if category already exists
    const existingCategory = await Category.findOne({ 
      name: { $regex: new RegExp(`^${name}$`, 'i') }
    });

    if (existingCategory) {
      return res.status(400).json({
        success: false,
        message: 'Category already exists'
      });
    }

    const category = new Category({
      name,
      description,
      icon:  icon || '🛒',
      color:  color || '#4CAF50',
      createdAt: new Date(),
      updatedAt: new Date()
    });

    await category.save();

    res.status(201).json({
      success: true,
      message: 'Category created successfully',
      data: category
    });

  } catch (error) {
    console.error('Create category error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error:  error.message
    });
  }
};

/**
 * Update a category
 * @route PUT /api/categories/:id
 * @access Private/Admin
 */
exports.updateCategory = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }

    const { name, description, icon, color } = req.body;

    // Check if new name conflicts with existing category
    if (name && name !== category.name) {
      const existingCategory = await Category.findOne({
        name: { $regex:  new RegExp(`^${name}$`, 'i') },
        _id: { $ne: req.params.id }
      });

      if (existingCategory) {
        return res.status(400).json({
          success: false,
          message: 'Category name already exists'
        });
      }
    }

    // Update fields
    if (name) category.name = name;
    if (description !== undefined) category.description = description;
    if (icon) category.icon = icon;
    if (color) category.color = color;

    category.updatedAt = new Date();
    await category.save();

    res.status(200).json({
      success: true,
      message: 'Category updated successfully',
      data: category
    });

  } catch (error) {
    console.error('Update category error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error:  error.message
    });
  }
};

/**
 * Delete a category
 * @route DELETE /api/categories/:id
 * @access Private/Admin
 */
exports.deleteCategory = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }

    // Check if category is in use
    const groceriesCount = await Grocery.countDocuments({
      category: category._id
    });

    if (groceriesCount > 0) {
      return res.status(400).json({
        success: false,
        message: `Cannot delete category.  ${groceriesCount} grocery items are using this category.`
      });
    }

    await Category.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Category deleted successfully'
    });

  } catch (error) {
    console.error('Delete category error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

/**
 * Get default categories (seed data)
 * @route POST /api/categories/seed
 * @access Private/Admin
 */
exports.seedCategories = async (req, res) => {
  try {
    // Default categories
    const defaultCategories = [
      { name: 'Fruits', icon: '🍎', color: '#FF6B6B', description: 'Fresh fruits' },
      { name: 'Vegetables', icon: '🥕', color: '#4CAF50', description: 'Fresh vegetables' },
      { name:  'Dairy', icon: '🥛', color: '#2196F3', description: 'Milk, cheese, yogurt' },
      { name: 'Meat', icon: '🍖', color: '#F44336', description: 'Meat products' },
      { name: 'Bakery', icon: '🍞', color: '#FF9800', description: 'Bread and bakery items' },
      { name: 'Beverages', icon: '🥤', color: '#9C27B0', description: 'Drinks and beverages' },
      { name:  'Snacks', icon: '🍿', color: '#FFC107', description: 'Snacks and chips' },
      { name: 'Frozen', icon: '❄️', color: '#00BCD4', description: 'Frozen foods' },
      { name: 'Canned', icon: '🥫', color: '#795548', description: 'Canned goods' },
      { name: 'Spices', icon: '🌶️', color: '#E91E63', description: 'Spices and condiments' }
    ];

    // Check which categories already exist
    const existingCategories = await Category.find({
      name: { $in: defaultCategories.map(cat => cat.name) }
    });

    const existingNames = existingCategories. map(cat => cat.name);

    // Filter out existing categories
    const categoriesToCreate = defaultCategories. filter(
      cat => !existingNames.includes(cat.name)
    );

    if (categoriesToCreate.length === 0) {
      return res.status(200).json({
        success: true,
        message: 'All default categories already exist'
      });
    }

    // Create new categories
    const newCategories = await Category.insertMany(
      categoriesToCreate.map(cat => ({
        ... cat,
        createdAt:  new Date(),
        updatedAt: new Date()
      }))
    );

    res.status(201).json({
      success: true,
      message: `${newCategories.length} categories created successfully`,
      data: newCategories
    });

  } catch (error) {
    console.error('Seed categories error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};