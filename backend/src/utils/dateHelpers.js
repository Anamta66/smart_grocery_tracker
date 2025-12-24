/**
 * ============================================
 * Date Helpers Utility
 * ============================================
 * Common date manipulation and formatting functions
 * 
 * Features:
 * - Date formatting
 * - Date calculations
 * - Expiry date helpers
 * - Time zone handling
 * ============================================
 */

/**
 * Format date to readable string
 * @param {Date|string} date - Date to format
 * @param {string} format - Format type ('short', 'long', 'iso')
 * @returns {string} - Formatted date string
 */
exports.formatDate = (date, format = 'short') => {
  const d = new Date(date);
  
  if (isNaN(d.getTime())) {
    return 'Invalid Date';
  }
  
  switch (format) {
    case 'short':
      return d. toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    
    case 'long':
      return d.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        weekday: 'long'
      });
    
    case 'iso':
      return d.toISOString().split('T')[0];
    
    case 'time':
      return d.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
      });
    
    case 'datetime':
      return d.toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    
    default:
      return d.toLocaleDateString();
  }
};

/**
 * Calculate days between two dates
 * @param {Date|string} date1 - First date
 * @param {Date|string} date2 - Second date
 * @returns {number} - Number of days
 */
exports.daysBetween = (date1, date2) => {
  const d1 = new Date(date1);
  const d2 = new Date(date2);
  
  d1.setHours(0, 0, 0, 0);
  d2.setHours(0, 0, 0, 0);
  
  const diffTime = Math.abs(d2 - d1);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  return diffDays;
};

/**
 * Calculate days until a date
 * @param {Date|string} date - Future date
 * @returns {number} - Days remaining (negative if past)
 */
exports. daysUntil = (date) => {
  const targetDate = new Date(date);
  const today = new Date();
  
  targetDate.setHours(0, 0, 0, 0);
  today.setHours(0, 0, 0, 0);
  
  const diffTime = targetDate - today;
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  return diffDays;
};

/**
 * Check if date is today
 * @param {Date|string} date - Date to check
 * @returns {boolean} - True if today
 */
exports.isToday = (date) => {
  const d = new Date(date);
  const today = new Date();
  
  return (
    d.getDate() === today.getDate() &&
    d.getMonth() === today.getMonth() &&
    d.getFullYear() === today.getFullYear()
  );
};

/**
 * Check if date is in the past
 * @param {Date|string} date - Date to check
 * @returns {boolean} - True if past
 */
exports.isPastDate = (date) => {
  const d = new Date(date);
  const today = new Date();
  
  d.setHours(0, 0, 0, 0);
  today.setHours(0, 0, 0, 0);
  
  return d < today;
};

/**
 * Check if date is in the future
 * @param {Date|string} date - Date to check
 * @returns {boolean} - True if future
 */
exports.isFutureDate = (date) => {
  const d = new Date(date);
  const today = new Date();
  
  d.setHours(0, 0, 0, 0);
  today.setHours(0, 0, 0, 0);
  
  return d > today;
};

/**
 * Add days to a date
 * @param {Date|string} date - Starting date
 * @param {number} days - Days to add
 * @returns {Date} - New date
 */
exports.addDays = (date, days) => {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
};

/**
 * Subtract days from a date
 * @param {Date|string} date - Starting date
 * @param {number} days - Days to subtract
 * @returns {Date} - New date
 */
exports.subtractDays = (date, days) => {
  return exports.addDays(date, -days);
};

/**
 * Get start of day (00:00:00)
 * @param {Date|string} date - Date
 * @returns {Date} - Start of day
 */
exports.startOfDay = (date) => {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
};

/**
 * Get end of day (23:59:59)
 * @param {Date|string} date - Date
 * @returns {Date} - End of day
 */
exports.endOfDay = (date) => {
  const d = new Date(date);
  d.setHours(23, 59, 59, 999);
  return d;
};

/**
 * Get start of month
 * @param {Date|string} date - Date
 * @returns {Date} - Start of month
 */
exports.startOfMonth = (date) => {
  const d = new Date(date);
  return new Date(d.getFullYear(), d.getMonth(), 1);
};

/**
 * Get end of month
 * @param {Date|string} date - Date
 * @returns {Date} - End of month
 */
exports.endOfMonth = (date) => {
  const d = new Date(date);
  return new Date(d.getFullYear(), d.getMonth() + 1, 0, 23, 59, 59, 999);
};

/**
 * Get expiry status based on days left
 * @param {Date|string} expiryDate - Expiry date
 * @returns {object} - { status, daysLeft, color, urgency }
 */
exports. getExpiryStatus = (expiryDate) => {
  const daysLeft = exports.daysUntil(expiryDate);
  
  let status, color, urgency;
  
  if (daysLeft < 0) {
    status = 'expired';
    color = '#F44336';
    urgency = 'critical';
  } else if (daysLeft === 0) {
    status = 'expires_today';
    color = '#FF5722';
    urgency = 'critical';
  } else if (daysLeft <= 2) {
    status = 'critical';
    color = '#FF9800';
    urgency = 'high';
  } else if (daysLeft <= 5) {
    status = 'warning';
    color = '#FFC107';
    urgency = 'medium';
  } else if (daysLeft <= 10) {
    status = 'attention';
    color = '#FFEB3B';
    urgency = 'low';
  } else {
    status = 'fresh';
    color = '#4CAF50';
    urgency = 'none';
  }
  
  return {
    status,
    daysLeft,
    color,
    urgency,
    message: exports.getExpiryMessage(daysLeft)
  };
};

/**
 * Get human-readable expiry message
 * @param {number} daysLeft - Days until expiry
 * @returns {string} - Message
 */
exports.getExpiryMessage = (daysLeft) => {
  if (daysLeft < 0) {
    return `Expired ${Math.abs(daysLeft)} day(s) ago`;
  } else if (daysLeft === 0) {
    return 'Expires today! ';
  } else if (daysLeft === 1) {
    return 'Expires tomorrow';
  } else {
    return `Expires in ${daysLeft} days`;
  }
};

/**
 * Get relative time string (e.g., "2 hours ago")
 * @param {Date|string} date - Date to compare
 * @returns {string} - Relative time string
 */
exports.timeAgo = (date) => {
  const d = new Date(date);
  const now = new Date();
  const seconds = Math.floor((now - d) / 1000);
  
  const intervals = {
    year: 31536000,
    month: 2592000,
    week: 604800,
    day: 86400,
    hour: 3600,
    minute: 60,
    second: 1
  };
  
  for (const [unit, secondsInUnit] of Object.entries(intervals)) {
    const interval = Math.floor(seconds / secondsInUnit);
    
    if (interval >= 1) {
      return interval === 1
        ? `1 ${unit} ago`
        : `${interval} ${unit}s ago`;
    }
  }
  
  return 'Just now';
};

/**
 * Get month name
 * @param {number} monthNumber - Month number (0-11)
 * @returns {string} - Month name
 */
exports.getMonthName = (monthNumber) => {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[monthNumber] || 'Invalid';
};

/**
 * Get day name
 * @param {Date|string} date - Date
 * @returns {string} - Day name
 */
exports. getDayName = (date) => {
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const d = new Date(date);
  return days[d.getDay()];
};

/**
 * Parse date string to Date object
 * @param {string} dateString - Date string
 * @returns {Date|null} - Date object or null if invalid
 */
exports.parseDate = (dateString) => {
  const date = new Date(dateString);
  return isNaN(date.getTime()) ? null : date;
};

/**
 * Get date range for period (week, month, year)
 * @param {string} period - 'week', 'month', 'year'
 * @returns {object} - { startDate, endDate }
 */
exports.getDateRange = (period) => {
  const today = new Date();
  let startDate;
  
  switch (period. toLowerCase()) {
    case 'week':
      startDate = exports.subtractDays(today, 7);
      break;
    case 'month':
      startDate = exports.startOfMonth(today);
      break;
    case 'year': 
      startDate = new Date(today.getFullYear(), 0, 1);
      break;
    default:
      startDate = today;
  }
  
  return {
    startDate:  exports.startOfDay(startDate),
    endDate: exports.endOfDay(today)
  };
};