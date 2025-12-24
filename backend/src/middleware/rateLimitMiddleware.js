/**
 * ============================================
 * Rate Limiting Middleware
 * ============================================
 * Prevents abuse by limiting request rates
 * Uses express-rate-limit
 * ============================================
 */

const rateLimit = require('express-rate-limit');

/**
 * @desc    General API rate limiter
 * Limit: 100 requests per 15 minutes
 */
exports.apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP. Please try again after 15 minutes.',
    retryAfter: '15 minutes'
  },
  standardHeaders: true, // Return rate limit info in `RateLimit-*` headers
  legacyHeaders: false, // Disable `X-RateLimit-*` headers
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Too many requests. Please slow down.',
      retryAfter: req.rateLimit.resetTime
    });
  }
});

/**
 * @desc    Authentication rate limiter (stricter)
 * Limit: 5 login attempts per 15 minutes
 */
exports.authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 login requests per windowMs
  skipSuccessfulRequests: true, // Don't count successful requests
  message:  {
    success: false,
    message: 'Too many login attempts. Please try again after 15 minutes.',
    retryAfter: '15 minutes'
  },
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Too many login attempts. Account temporarily locked.',
      retryAfter: Math.ceil(req.rateLimit.resetTime / 1000 / 60) + ' minutes'
    });
  }
});

/**
 * @desc    Password reset rate limiter
 * Limit: 3 requests per hour
 */
exports.passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3,
  message: {
    success: false,
    message: 'Too many password reset requests. Please try again later.',
    retryAfter: '1 hour'
  }
});

/**
 * @desc    Search rate limiter
 * Limit: 50 searches per minute
 */
exports.searchLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 50,
  message:  {
    success: false,
    message: 'Search rate limit exceeded. Please wait a moment.',
    retryAfter: '1 minute'
  }
});

/**
 * @desc    File upload rate limiter
 * Limit: 10 uploads per hour
 */
exports.uploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10,
  message: {
    success: false,
    message: 'Upload limit reached. Please try again later.',
    retryAfter: '1 hour'
  }
});

/**
 * @desc    Create custom rate limiter
 * @param   {number} windowMs - Time window in milliseconds
 * @param   {number} max - Max requests per window
 * @param   {string} message - Custom error message
 */
exports.createLimiter = (windowMs, max, message) => {
  return rateLimit({
    windowMs,
    max,
    message:  {
      success: false,
      message:  message || 'Too many requests.  Please try again later.'
    },
    standardHeaders: true,
    legacyHeaders: false
  });
};