/**
 * ============================================
 * Logger Utility
 * ============================================
 * Application-wide logging utility
 * 
 * Features:
 * - Different log levels
 * - Timestamp formatting
 * - Color-coded console output
 * - File logging (optional)
 * ============================================
 */

const fs = require('fs');
const path = require('path');

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m'
};

class Logger {
  constructor() {
    this.logDir = path.join(__dirname, '../../logs');
    this.ensureLogDirectory();
  }

  /**
   * Ensure logs directory exists
   */
  ensureLogDirectory() {
    if (!fs.existsSync(this.logDir)) {
      fs.mkdirSync(this. logDir, { recursive: true });
    }
  }

  /**
   * Get formatted timestamp
   */
  getTimestamp() {
    return new Date().toISOString();
  }

  /**
   * Format log message
   */
  formatMessage(level, message, data = null) {
    const timestamp = this.getTimestamp();
    let formatted = `[${timestamp}] [${level. toUpperCase()}] ${message}`;
    
    if (data) {
      formatted += `\nData: ${JSON.stringify(data, null, 2)}`;
    }
    
    return formatted;
  }

  /**
   * Write to log file
   */
  writeToFile(level, message) {
    const logFile = path.join(this.logDir, `${level}.log`);
    const logMessage = message + '\n';
    
    fs.appendFile(logFile, logMessage, (err) => {
      if (err) console.error('Failed to write to log file:', err);
    });
  }

  /**
   * Info log
   */
  info(message, data = null) {
    const formatted = this.formatMessage('info', message, data);
    console.log(`${colors.blue}${formatted}${colors.reset}`);
    
    if (process.env. ENABLE_FILE_LOGGING === 'true') {
      this.writeToFile('info', formatted);
    }
  }

  /**
   * Success log
   */
  success(message, data = null) {
    const formatted = this.formatMessage('success', message, data);
    console.log(`${colors.green}${formatted}${colors. reset}`);
    
    if (process.env.ENABLE_FILE_LOGGING === 'true') {
      this.writeToFile('success', formatted);
    }
  }

  /**
   * Warning log
   */
  warn(message, data = null) {
    const formatted = this.formatMessage('warn', message, data);
    console.warn(`${colors.yellow}${formatted}${colors.reset}`);
    
    if (process.env.ENABLE_FILE_LOGGING === 'true') {
      this.writeToFile('warn', formatted);
    }
  }

  /**
   * Error log
   */
  error(message, error = null) {
    const data = error ? {
      message:  error.message,
      stack: error.stack
    } : null;
    
    const formatted = this.formatMessage('error', message, data);
    console.error(`${colors.red}${formatted}${colors. reset}`);
    
    if (process.env.ENABLE_FILE_LOGGING === 'true') {
      this.writeToFile('error', formatted);
    }
  }

  /**
   * Debug log (only in development)
   */
  debug(message, data = null) {
    if (process.env.NODE_ENV === 'development') {
      const formatted = this.formatMessage('debug', message, data);
      console.log(`${colors.magenta}${formatted}${colors. reset}`);
    }
  }

  /**
   * HTTP request log
   */
  http(method, url, statusCode, duration) {
    const message = `${method} ${url} - ${statusCode} (${duration}ms)`;
    const color = statusCode >= 500 ?  colors.red : 
                  statusCode >= 400 ? colors.yellow :
                  statusCode >= 300 ? colors.cyan :
                  colors.green;
    
    console.log(`${color}[${this.getTimestamp()}] [HTTP] ${message}${colors.reset}`);
  }
}

module.exports = new Logger();