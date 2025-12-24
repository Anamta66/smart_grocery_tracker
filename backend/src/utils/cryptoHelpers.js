/**
 * ============================================
 * Crypto Helpers Utility
 * ============================================
 * Cryptography and security functions
 * 
 * Features:
 * - Token generation
 * - Hash generation
 * - Encryption/Decryption
 * - Random string generation
 * ============================================
 */

const crypto = require('crypto');

/**
 * Generate random token
 * @param {number} length - Token length
 * @returns {string} - Random token
 */
exports.generateToken = (length = 32) => {
  return crypto.randomBytes(length).toString('hex');
};

/**
 * Generate random numeric code
 * @param {number} length - Code length
 * @returns {string} - Numeric code
 */
exports. generateNumericCode = (length = 6) => {
  const max = Math.pow(10, length) - 1;
  const min = Math.pow(10, length - 1);
  return Math.floor(Math.random() * (max - min + 1) + min).toString();
};

/**
 * Generate hash (SHA256)
 * @param {string} data - Data to hash
 * @returns {string} - Hash
 */
exports.generateHash = (data) => {
  return crypto. createHash('sha256').update(data).digest('hex');
};

/**
 * Generate MD5 hash
 * @param {string} data - Data to hash
 * @returns {string} - MD5 hash
 */
exports.generateMD5 = (data) => {
  return crypto.createHash('md5').update(data).digest('hex');
};

/**
 * Compare hash
 * @param {string} data - Original data
 * @param {string} hash - Hash to compare
 * @returns {boolean} - True if match
 */
exports.compareHash = (data, hash) => {
  const dataHash = exports.generateHash(data);
  return dataHash === hash;
};

/**
 * Encrypt data
 * @param {string} text - Text to encrypt
 * @param {string} key - Encryption key
 * @returns {string} - Encrypted text
 */
exports.encrypt = (text, key) => {
  const algorithm = 'aes-256-cbc';
  const keyBuffer = crypto.scryptSync(key, 'salt', 32);
  const iv = crypto.randomBytes(16);
  
  const cipher = crypto.createCipheriv(algorithm, keyBuffer, iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  return iv.toString('hex') + ':' + encrypted;
};

/**
 * Decrypt data
 * @param {string} encryptedText - Encrypted text
 * @param {string} key - Decryption key
 * @returns {string} - Decrypted text
 */
exports.decrypt = (encryptedText, key) => {
  const algorithm = 'aes-256-cbc';
  const keyBuffer = crypto.scryptSync(key, 'salt', 32);
  
  const parts = encryptedText.split(':');
  const iv = Buffer.from(parts[0], 'hex');
  const encrypted = parts[1];
  
  const decipher = crypto.createDecipheriv(algorithm, keyBuffer, iv);
  let decrypted = decipher. update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
};

/**
 * Generate UUID v4
 * @returns {string} - UUID
 */
exports.generateUUID = () => {
  return crypto.randomUUID();
};

/**
 * Generate random alphanumeric string
 * @param {number} length - String length
 * @returns {string} - Random string
 */
exports.generateRandomString = (length = 16) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  
  return result;
};