/**
 * ============================================
 * Main Routes Index
 * ============================================
 * Central router that combines all route modules
 * Implements versioning and base path organization
 * ============================================
 */

const express = require('express');
const router = express.Router();

// Import route modules
const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');
const groceryRoutes = require('./groceryRoutes');
const categoryRoutes = require('./categoryRoutes');
const notificationRoutes = require('./notificationRoutes');
const expiryRoutes = require('./expiryRoutes');
const searchRoutes = require('./searchRoutes');
const inventoryRoutes = require('./inventoryRoutes');

// ============================================
// API HEALTH CHECK
// ============================================
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// ============================================
// API INFO
// ============================================
router. get('/info', (req, res) => {
  res.status(200).json({
    success: true,
    data: {
      name: 'Smart Grocery Management API',
      version: '1.0.0',
      description: 'RESTful API for grocery tracking and expiry management',
      endpoints: {
        auth: '/api/v1/auth',
        users: '/api/v1/users',
        groceries: '/api/v1/groceries',
        categories: '/api/v1/categories',
        notifications: '/api/v1/notifications',
        expiry: '/api/v1/expiry',
        search: '/api/v1/search',
        inventory: '/api/v1/inventory'
      }
    }
  });
});

// ============================================
// MOUNT ROUTE MODULES
// ============================================
router. use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/groceries', groceryRoutes);
router.use('/categories', categoryRoutes);
router.use('/notifications', notificationRoutes);
router.use('/expiry', expiryRoutes);
router.use('/search', searchRoutes);
router.use('/inventory', inventoryRoutes);

// ============================================
// 404 HANDLER FOR API ROUTES
// ============================================
router. use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`,
    availableRoutes: [
      'GET /api/v1/health',
      'GET /api/v1/info',
      'POST /api/v1/auth/login',
      'POST /api/v1/auth/register',
      'GET /api/v1/groceries',
      'GET /api/v1/categories'
    ]
  });
});

module.exports = router;