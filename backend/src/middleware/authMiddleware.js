/**
 * ============================================
 * Authentication Middleware
 * ============================================
 * Handles JWT token verification and user
 * authentication/authorization
 * 
 * Features:
 * - JWT token verification
 * - User authentication
 * - Role-based authorization
 * - Token expiry handling
 * ============================================
 */

const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * @desc    Protect routes - Verify JWT token
 * @middleware
 */
exports.protect = async (req, res, next) => {
  try {
    let token;

    // Check for token in Authorization header
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      // Extract token from "Bearer <token>"
      token = req.headers. authorization.split(' ')[1];
    }
    // Alternative: Check for token in cookies (if using cookie-based auth)
    else if (req.cookies && req.cookies.token) {
      token = req. cookies.token;
    }

    // Check if token exists
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized.  Please login to access this resource.'
      });
    }

    try {
      // Verify token
      const decoded = jwt.verify(token, process. env.JWT_SECRET);

      // Find user by ID from token
      const user = await User.findById(decoded.userId).select('-password');

      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'User not found.  Token may be invalid.'
        });
      }

      // Check if user account is active
      if (!user. isActive) {
        return res.status(403).json({
          success: false,
          message: 'Your account has been deactivated.  Please contact support.'
        });
      }

      // Attach user to request object
      req.user = {
        id: user._id,
        email: user.email,
        name: user.name,
        role: user.role
      };

      next();

    } catch (error) {
      // Token verification failed
      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          message: 'Session expired. Please login again.',
          expired: true
        });
      }

      if (error.name === 'JsonWebTokenError') {
        return res.status(401).json({
          success: false,
          message: 'Invalid token. Please login again.'
        });
      }

      // Other JWT errors
      return res.status(401).json({
        success: false,
        message: 'Authentication failed.',
        error: error.message
      });
    }

  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      message:  'Server error during authentication',
      error: error.message
    });
  }
};

/**
 * @desc    Authorize specific roles
 * @param   {... string} roles - Allowed roles (e.g., 'admin', 'user')
 * @middleware
 */
exports.authorize = (...roles) => {
  return (req, res, next) => {
    // Check if user exists on request (set by protect middleware)
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Not authenticated. Please login first.'
      });
    }

    // Check if user's role is in allowed roles
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Access denied. User role '${req.user.role}' is not authorized to access this resource.`,
        requiredRoles: roles
      });
    }

    next();
  };
};

/**
 * @desc    Check if user owns the resource
 * @param   {string} paramName - Name of the param containing userId
 * @middleware
 */
exports.checkOwnership = (paramName = 'userId') => {
  return (req, res, next) => {
    // Get userId from params or body
    const resourceUserId = req.params[paramName] || req.body[paramName];

    // Check if authenticated user matches resource owner
    if (req.user.id. toString() !== resourceUserId.toString()) {
      // Allow admins to bypass ownership check
      if (req. user.role === 'admin') {
        return next();
      }

      return res.status(403).json({
        success: false,
        message: 'Access denied. You can only access your own resources.'
      });
    }

    next();
  };
};

/**
 * @desc    Optional authentication (doesn't fail if no token)
 * @middleware
 */
exports.optionalAuth = async (req, res, next) => {
  try {
    let token;

    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      token = req. headers.authorization.split(' ')[1];
    }

    if (token) {
      try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.userId).select('-password');

        if (user && user.isActive) {
          req.user = {
            id: user._id,
            email: user.email,
            name: user.name,
            role: user.role
          };
        }
      } catch (error) {
        // Token invalid or expired, but continue anyway
        console.log('Optional auth - invalid token:', error.message);
      }
    }

    next();
  } catch (error) {
    console.error('Optional auth error:', error);
    next();
  }
};

/**
 * @desc    Verify email confirmation (if implemented)
 * @middleware
 */
exports.requireEmailVerified = async (req, res, next) => {
  try {
    if (! req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    const user = await User.findById(req.user.id);

    if (!user.isEmailVerified) {
      return res.status(403).json({
        success: false,
        message: 'Please verify your email to access this resource.',
        emailVerified: false
      });
    }

    next();
  } catch (error) {
    console.error('Email verification check error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};