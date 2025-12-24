/**
 * ============================================
 * File Helpers Utility
 * ============================================
 * File system operations and helpers
 * 
 * Features:
 * - File size formatting
 * - File extension handling
 * - MIME type detection
 * - File path utilities
 * ============================================
 */

const path = require('path');
const fs = require('fs').promises;

/**
 * Format file size to human-readable format
 * @param {number} bytes - File size in bytes
 * @returns {string} - Formatted size
 */
exports.formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

/**
 * Get file extension
 * @param {string} filename - File name
 * @returns {string} - Extension without dot
 */
exports.getFileExtension = (filename) => {
  return path.extname(filename).toLowerCase().replace('. ', '');
};

/**
 * Get MIME type from extension
 * @param {string} extension - File extension
 * @returns {string} - MIME type
 */
exports.getMimeType = (extension) => {
  const mimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'svg': 'image/svg+xml',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd. ms-excel',
    'xlsx': 'application/vnd. openxmlformats-officedocument.spreadsheetml. sheet',
    'csv': 'text/csv',
    'txt': 'text/plain',
    'json': 'application/json',
    'xml': 'application/xml',
    'zip': 'application/zip'
  };
  
  return mimeTypes[extension. toLowerCase()] || 'application/octet-stream';
};

/**
 * Generate unique filename
 * @param {string} originalName - Original file name
 * @returns {string} - Unique filename
 */
exports.generateUniqueFilename = (originalName) => {
  const extension = exports.getFileExtension(originalName);
  const timestamp = Date.now();
  const random = Math.round(Math.random() * 1E9);
  
  return `file-${timestamp}-${random}. ${extension}`;
};

/**
 * Check if file exists
 * @param {string} filePath - Path to file
 * @returns {Promise<boolean>} - True if exists
 */
exports.fileExists = async (filePath) => {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
};

/**
 * Ensure directory exists
 * @param {string} dirPath - Directory path
 */
exports.ensureDirectory = async (dirPath) => {
  try {
    await fs.mkdir(dirPath, { recursive: true });
  } catch (error) {
    console.error('Error creating directory:', error);
  }
};

/**
 * Delete file if exists
 * @param {string} filePath - Path to file
 */
exports.deleteFile = async (filePath) => {
  try {
    if (await exports.fileExists(filePath)) {
      await fs.unlink(filePath);
      return true;
    }
    return false;
  } catch (error) {
    console.error('Error deleting file:', error);
    return false;
  }
};

/**
 * Get file stats
 * @param {string} filePath - Path to file
 * @returns {Promise<object>} - File stats
 */
exports.getFileStats = async (filePath) => {
  try {
    const stats = await fs.stat(filePath);
    return {
      size: stats. size,
      sizeFormatted: exports.formatFileSize(stats.size),
      created: stats.birthtime,
      modified: stats.mtime,
      isFile: stats.isFile(),
      isDirectory: stats.isDirectory()
    };
  } catch (error) {
    return null;
  }
};