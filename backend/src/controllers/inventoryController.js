/**
 * Inventory Controller (Basic Implementation)
 */

const Inventory = require('../models/Inventory');

exports.getAllInventory = async (req, res) => {
  try {
    const inventory = await Inventory.find({ storeOwner: req.user. id })
      .populate('category')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: inventory.length,
      data: inventory
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getInventoryById = async (req, res) => {
  try {
    const item = await Inventory.findOne({
      _id: req.params.id,
      storeOwner: req.user.id
    }).populate('category');

    if (!item) {
      return res.status(404).json({ success: false, message: 'Item not found' });
    }

    res.status(200).json({ success: true, data: item });
  } catch (error) {
    res.status(500).json({ success: false, message:  error.message });
  }
};

exports.createInventoryItem = async (req, res) => {
  try {
    req.body.storeOwner = req.user.id;
    const item = await Inventory.create(req.body);

    res.status(201).json({ success: true, data: item });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

exports.updateInventoryItem = async (req, res) => {
  try {
    const item = await Inventory.findOneAndUpdate(
      { _id: req.params.id, storeOwner: req.user. id },
      req.body,
      { new: true, runValidators: true }
    );

    if (!item) {
      return res.status(404).json({ success: false, message:  'Item not found' });
    }

    res.status(200).json({ success: true, data: item });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

exports.deleteInventoryItem = async (req, res) => {
  try {
    const item = await Inventory.findOneAndDelete({
      _id:  req.params.id,
      storeOwner: req.user.id
    });

    if (!item) {
      return res.status(404).json({ success: false, message: 'Item not found' });
    }

    res.status(200).json({ success: true, message: 'Item deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.restockItem = async (req, res) => {
  try {
    const { quantity } = req.body;
    const item = await Inventory. findOne({
      _id: req. params.id,
      storeOwner: req.user.id
    });

    if (!item) {
      return res.status(404).json({ success: false, message:  'Item not found' });
    }

    await item.restock(quantity);

    res.status(200).json({ success: true, data: item });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

exports.getLowStockItems = async (req, res) => {
  try {
    const items = await Inventory.getLowStockItems(req.user.id);

    res.status(200).json({ success: true, count: items.length, data: items });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};