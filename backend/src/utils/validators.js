/**
 * ============================================
 * Validators Utility
 * ============================================
 * Common validation functions for data validation
 * 
 * Features:
 * - Email validation
 * - Password strength validation
 * - Phone number validation
 * - Date validation
 * - Custom validators
 * ============================================
 */

/**
 * Validate email format
 * @param {string} email - Email address to validate
 * @returns {boolean} - True if valid
 */
exports.isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * Validate password strength
 * @param {string} password - Password to validate
 * @returns {object} - { isValid: boolean, errors: string[] }
 */
exports.validatePassword = (password) => {
  const errors = [];
  
  if (! password || password.length < 6) {
    errors.push('Password must be at least 6 characters long');
  }
  
  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter');
  }
  
  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter');
  }
  
  if (!/[0-9]/.test(password)) {
    errors.push('Password must contain at least one number');
  }
  
  // Optional: special character check
  // if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
  //   errors.push('Password must contain at least one special character');
  // }
  
  return {
    isValid: errors.length === 0,
    errors
  };
};

/**
 * Validate phone number
 * @param {string} phone - Phone number to validate
 * @returns {boolean} - True if valid
 */
exports.isValidPhone = (phone) => {
  // Remove all non-numeric characters
  const cleaned = phone.replace(/\D/g, '');
  
  // Check if it's between 10-15 digits
  return cleaned.length >= 10 && cleaned.length <= 15;
};

/**
 * Validate MongoDB ObjectId
 * @param {string} id - ID to validate
 * @returns {boolean} - True if valid
 */
exports.isValidObjectId = (id) => {
  const objectIdRegex = /^[0-9a-fA-F]{24}$/;
  return objectIdRegex.test(id);
};

/**
 * Validate date format (YYYY-MM-DD)
 * @param {string} dateString - Date string to validate
 * @returns {boolean} - True if valid
 */
exports. isValidDate = (dateString) => {
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  
  if (!dateRegex.test(dateString)) {
    return false;
  }
  
  const date = new Date(dateString);
  return date instanceof Date && !isNaN(date);
};

/**
 * Validate date is in the future
 * @param {string|Date} date - Date to validate
 * @returns {boolean} - True if date is in the future
 */
exports.isFutureDate = (date) => {
  const inputDate = new Date(date);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  return inputDate > today;
};

/**
 * Validate URL format
 * @param {string} url - URL to validate
 * @returns {boolean} - True if valid
 */
exports. isValidUrl = (url) => {
  try {
    new URL(url);
    return true;
  } catch (error) {
    return false;
  }
};

/**
 * Sanitize input string (prevent XSS)
 * @param {string} input - String to sanitize
 * @returns {string} - Sanitized string
 */
exports.sanitizeString = (input) => {
  if (typeof input !== 'string') return input;
  
  return input
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');
};

/**
 * Validate quantity (must be positive number)
 * @param {number} quantity - Quantity to validate
 * @returns {boolean} - True if valid
 */
exports.isValidQuantity = (quantity) => {
  return typeof quantity === 'number' && quantity > 0 && isFinite(quantity);
};

/**
 * Validate price (must be non-negative number)
 * @param {number} price - Price to validate
 * @returns {boolean} - True if valid
 */
exports. isValidPrice = (price) => {
  return typeof price === 'number' && price >= 0 && isFinite(price);
};

/**
 * Validate barcode format
 * @param {string} barcode - Barcode to validate
 * @returns {boolean} - True if valid
 */
exports.isValidBarcode = (barcode) => {
  // Accept common barcode formats:  EAN-13, UPC-A, Code-128
  const barcodeRegex = /^[0-9]{8,20}$/;
  return barcodeRegex.test(barcode);
};

/**
 * Validate name (letters, spaces, hyphens only)
 * @param {string} name - Name to validate
 * @returns {boolean} - True if valid
 */
exports. isValidName = (name) => {
  const nameRegex = /^[a-zA-Z\s\-']{2,50}$/;
  return nameRegex.test(name);
};

/**
 * Validate hex color code
 * @param {string} color - Color code to validate
 * @returns {boolean} - True if valid
 */
exports.isValidHexColor = (color) => {
  const hexColorRegex = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/;
  return hexColorRegex.test(color);
};

/**
 * Validate file extension
 * @param {string} filename - Filename to validate
 * @param {string[]} allowedExtensions - Array of allowed extensions
 * @returns {boolean} - True if valid
 */
exports.isValidFileExtension = (filename, allowedExtensions) => {
  const extension = filename.split('.').pop().toLowerCase();
  return allowedExtensions.includes(extension);
};

/**
 * Validate image file
 * @param {string} filename - Image filename
 * @returns {boolean} - True if valid image
 */
exports.isValidImage = (filename) => {
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'];
  return exports.isValidFileExtension(filename, imageExtensions);
};

/**
 * Check if string is empty or whitespace only
 * @param {string} str - String to check
 * @returns {boolean} - True if empty
 */
exports.isEmpty = (str) => {
  return !str || str.trim().length === 0;
};

/**
 * Validate array is not empty
 * @param {Array} arr - Array to validate
 * @returns {boolean} - True if array has items
 */
exports.isNonEmptyArray = (arr) => {
  return Array.isArray(arr) && arr.length > 0;
};

/**
 * Validate JSON string
 * @param {string} str - String to validate
 * @returns {boolean} - True if valid JSON
 */
exports.isValidJSON = (str) => {
  try {
    JSON.parse(str);
    return true;
  } catch (error) {
    return false;
  }
};