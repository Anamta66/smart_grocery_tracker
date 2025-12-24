/**
 * ============================================
 * Response Handler Utility
 * ============================================
 * Standardized API response formatting
 * 
 * Features:
 * - Success responses
 * - Error responses
 * - Pagination
 * - Consistent response structure
 * ============================================
 */

/**
 * Send success response
 * @param {object} res - Express response object
 * @param {number} statusCode - HTTP status code
 * @param {string} message - Success message
 * @param {any} data - Response data
 */
exports.sendSuccess = (res, statusCode = 200, message = 'Success', data = null) => {
  const response = {
    success: true,
    message,
    timestamp: new Date().toISOString()
  };
  
  if (data !== null) {
    response.data = data;
  }
  
  res.status(statusCode).json(response);
};

/**
 * Send error response
 * @param {object} res - Express response object
 * @param {number} statusCode - HTTP status code
 * @param {string} message - Error message
 * @param {any} error - Error details (only in development)
 */
exports.sendError = (res, statusCode = 500, message = 'Error', error = null) => {
  const response = {
    success: false,
    message,
    timestamp: new Date().toISOString()
  };
  
  // Include error details only in development
  if (process. env.NODE_ENV === 'development' && error) {
    response.error = error;
  }
  
  res.status(statusCode).json(response);
};

/**
 * Send paginated response
 * @param {object} res - Express response object
 * @param {Array} data - Array of items
 * @param {number} page - Current page
 * @param {number} limit - Items per page
 * @param {number} total - Total items count
 * @param {string} message - Success message
 */
exports.sendPaginated = (res, data, page, limit, total, message = 'Success') => {
  const response = {
    success: true,
    message,
    data,
    pagination: {
      page:  parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit),
      hasNext: page * limit < total,
      hasPrev: page > 1
    },
    timestamp: new Date().toISOString()
  };
  
  res.status(200).json(response);
};

/**
 * Send created response (201)
 * @param {object} res - Express response object
 * @param {string} message - Success message
 * @param {any} data - Created resource data
 */
exports.sendCreated = (res, message = 'Created successfully', data = null) => {
  exports.sendSuccess(res, 201, message, data);
};

/**
 * Send no content response (204)
 * @param {object} res - Express response object
 */
exports.sendNoContent = (res) => {
  res.status(204).send();
};

/**
 * Send bad request error (400)
 * @param {object} res - Express response object
 * @param {string} message - Error message
 */
exports.sendBadRequest = (res, message = 'Bad request') => {
  exports.sendError(res, 400, message);
};

/**
 * Send unauthorized error (401)
 * @param {object} res - Express response object
 * @param {string} message - Error message
 */
exports.sendUnauthorized = (res, message = 'Unauthorized') => {
  exports.sendError(res, 401, message);
};

/**
 * Send forbidden error (403)
 * @param {object} res - Express response object
 * @param {string} message - Error message
 */
exports.sendForbidden = (res, message = 'Forbidden') => {
  exports.sendError(res, 403, message);
};

/**
 * Send not found error (404)
 * @param {object} res - Express response object
 * @param {string} message - Error message
 */
exports.sendNotFound = (res, message = 'Resource not found') => {
  exports.sendError(res, 404, message);
};

/**
 * Send validation error (422)
 * @param {object} res - Express response object
 * @param {Array} errors - Array of validation errors
 */
exports.sendValidationError = (res, errors) => {
  res.status(422).json({
    success: false,
    message: 'Validation failed',
    errors,
    timestamp: new Date().toISOString()
  });
};

/**
 * Send server error (500)
 * @param {object} res - Express response object
 * @param {string} message - Error message
 * @param {any} error - Error object
 */
exports.sendServerError = (res, message = 'Internal server error', error = null) => {
  exports.sendError(res, 500, message, error);
};