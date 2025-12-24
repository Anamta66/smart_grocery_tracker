/**
 * ============================================
 * SMART GROCERY MANAGEMENT SYSTEM - BACKEND
 * ============================================
 * 
 * Main server file for the Smart Grocery Management System
 * 
 * Architecture:  Layered (N-Tier) Architecture
 * - Presentation Layer (Routes)
 * - Middleware Layer
 * - Business Logic Layer (Controllers)
 * - Service Layer
 * - Data Access Layer (Models)
 * - Database Layer (MongoDB)
 * 
 * Technology Stack:
 * - Node. js (Runtime)
 * - Express.js (Web Framework)
 * - MongoDB (Database)
 * - Mongoose (ODM)
 * 
 * @author Your Name
 * @version 1.0.0
 * @license MIT
 * ============================================
 */

// ============================================
// IMPORT DEPENDENCIES
// ============================================
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const hpp = require('hpp');
const cookieParser = require('cookie-parser');
const path = require('path');

// Load environment variables
dotenv. config();

// Import utilities
const logger = require('./src/utils/logger');

// Import middleware
const { notFound, errorHandler } = require('./src/middleware/errorMiddleware');
const { apiLimiter } = require('./src/middleware/rateLimitMiddleware');

// Import routes
const routes = require('./src/routes');

// Import services
const schedulerService = require('./src/services/schedulerService');

// ============================================
// INITIALIZE EXPRESS APP
// ============================================
const app = express();

// ============================================
// ENVIRONMENT VARIABLES
// ============================================
const PORT = process.env.PORT || 5000;
const NODE_ENV = process.env.NODE_ENV || 'development';
const MONGODB_URI = process. env.MONGODB_URI || 'mongodb://localhost:27017/smart-grocery';

// ============================================
// DATABASE CONNECTION
// ============================================
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    logger.success(`✅ MongoDB Connected: ${conn.connection.host}`);
    logger.info(`📊 Database:  ${conn.connection.name}`);

    // Database event listeners
    mongoose.connection.on('error', (err) => {
      logger.error('❌ MongoDB connection error:', err);
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('⚠️  MongoDB disconnected');
    });

    mongoose.connection.on('reconnected', () => {
      logger.success('✅ MongoDB reconnected');
    });

  } catch (error) {
    logger.error('❌ MongoDB connection failed:', error);
    process.exit(1);
  }
};

// Connect to database
connectDB();

// ============================================
// MIDDLEWARE CONFIGURATION
// ============================================

// Security Headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
    },
  },
}));

// CORS Configuration
const corsOptions = {
  origin:  process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};
app.use(cors(corsOptions));

// Body Parser Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Cookie Parser
app.use(cookieParser());

// Compression Middleware
app.use(compression());

// Data Sanitization against NoSQL injection
app.use(mongoSanitize());

// Data Sanitization against XSS
app. use(xss());

// Prevent parameter pollution
app.use(hpp());

// HTTP Request Logger (Morgan)
if (NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Static Files (for file uploads)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ============================================
// CUSTOM MIDDLEWARE
// ============================================

// Request Logger Middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger. http(req.method, req.originalUrl, res.statusCode, duration);
  });
  
  next();
});

// ============================================
// ROUTES
// ============================================

// Health Check Route
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Smart Grocery Management API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: NODE_ENV,
    status: 'running',
    documentation: '/api/v1/info'
  });
});

// API Status Route
app.get('/status', (req, res) => {
  res.status(200).json({
    success: true,
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    memory: {
      used: `${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB`,
      total: `${Math.round(process.memoryUsage().heapTotal / 1024 / 1024)}MB`
    },
    database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
  });
});

// Mount API Routes (versioned)
app.use('/api/v1', apiLimiter, routes);

// API Documentation Route (if using Swagger or similar)
app.get('/api/docs', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API Documentation',
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
  });
});

// ============================================
// ERROR HANDLING
// ============================================

// 404 Not Found Handler
app.use(notFound);

// Global Error Handler
app.use(errorHandler);

// ============================================
// PROCESS ERROR HANDLERS
// ============================================

// Handle unhandled promise rejections
process. on('unhandledRejection', (err) => {
  logger.error('❌ UNHANDLED REJECTION!  Shutting down... ', err);
  server.close(() => {
    process.exit(1);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  logger.error('❌ UNCAUGHT EXCEPTION!  Shutting down...', err);
  process.exit(1);
});

// Graceful shutdown on SIGTERM
process.on('SIGTERM', () => {
  logger.info('👋 SIGTERM received.  Shutting down gracefully...');
  
  // Stop scheduled tasks
  schedulerService.stopAll();
  
  // Close server
  server.close(() => {
    logger.info('✅ Process terminated gracefully');
    
    // Close database connection
    mongoose.connection. close(false, () => {
      logger.info('✅ MongoDB connection closed');
      process.exit(0);
    });
  });
});

// Graceful shutdown on SIGINT (Ctrl+C)
process.on('SIGINT', () => {
  logger.info('👋 SIGINT received.  Shutting down gracefully...');
  
  schedulerService.stopAll();
  
  server.close(() => {
    logger.info('✅ Process terminated gracefully');
    mongoose.connection.close(false, () => {
      logger.info('✅ MongoDB connection closed');
      process.exit(0);
    });
  });
});

// ============================================
// START SERVER
// ============================================
const server = app.listen(PORT, () => {
  console.log('\n' + '='.repeat(60));
  logger.success(`🚀 Server running in ${NODE_ENV} mode on port ${PORT}`);
  logger.info(`📍 API URL: http://localhost:${PORT}`);
  logger.info(`📊 Health Check: http://localhost:${PORT}/status`);
  logger.info(`📚 API Docs: http://localhost:${PORT}/api/docs`);
  console.log('='.repeat(60) + '\n');

  // Initialize scheduler after server starts
  if (process.env. ENABLE_SCHEDULER === 'true') {
    try {
      schedulerService.initialize();
      logger.success('⏰ Scheduler service initialized');
    } catch (error) {
      logger.error('❌ Failed to initialize scheduler:', error);
    }
  }
});

// ============================================
// EXPORT APP (for testing)
// ============================================
module.exports = app;