/**
 * ============================================
 * Storage Service
 * ============================================
 * Handles file uploads and cloud storage
 * Supports local storage and AWS S3
 * 
 * Features:
 * - Upload images
 * - Delete files
 * - Generate signed URLs
 * - Image optimization
 * ============================================
 */

const fs = require('fs').promises;
const path = require('path');
const sharp = require('sharp');
const AWS = require('aws-sdk');

class StorageService {
  constructor() {
    this.storageType = process.env.STORAGE_TYPE || 'local'; // 'local' or 's3'
    this.uploadsDir = path.join(__dirname, '../../uploads');

    // Initialize S3 if configured
    if (this.storageType === 's3') {
      this.s3 = new AWS.S3({
        accessKeyId: process. env.AWS_ACCESS_KEY_ID,
        secretAccessKey:  process.env.AWS_SECRET_ACCESS_KEY,
        region:  process.env.AWS_REGION
      });
      this.bucketName = process.env.AWS_S3_BUCKET;
      console.log('✅ AWS S3 storage initialized');
    } else {
      console.log('✅ Local storage initialized');
    }
  }

  /**
   * Upload image with optimization
   */
  async uploadImage(file, folder = 'groceries') {
    try {
      // Optimize image
      const optimizedBuffer = await sharp(file.path)
        .resize(800, 800, {
          fit: 'inside',
          withoutEnlargement: true
        })
        .jpeg({ quality: 85 })
        .toBuffer();

      const filename = `${folder}/${Date.now()}-${file.originalname}`;

      if (this.storageType === 's3') {
        return await this.uploadToS3(optimizedBuffer, filename, file.mimetype);
      } else {
        return await this.uploadLocally(optimizedBuffer, filename);
      }
    } catch (error) {
      console.error('❌ Upload image error:', error);
      throw error;
    }
  }

  /**
   * Upload to local storage
   */
  async uploadLocally(buffer, filename) {
    try {
      const filepath = path.join(this.uploadsDir, filename);
      const dir = path.dirname(filepath);

      // Ensure directory exists
      await fs. mkdir(dir, { recursive: true });

      // Write file
      await fs.writeFile(filepath, buffer);

      const url = `/uploads/${filename}`;
      
      console.log(`📁 File uploaded locally: ${filename}`);
      
      return {
        success: true,
        url,
        filename,
        storage: 'local'
      };
    } catch (error) {
      console.error('❌ Local upload error:', error);
      throw error;
    }
  }

  /**
   * Upload to AWS S3
   */
  async uploadToS3(buffer, filename, mimetype) {
    try {
      const params = {
        Bucket: this.bucketName,
        Key: filename,
        Body: buffer,
        ContentType: mimetype,
        ACL: 'public-read'
      };

      const result = await this.s3.upload(params).promise();

      console.log(`☁️  File uploaded to S3: ${filename}`);

      return {
        success: true,
        url: result.Location,
        filename:  result.Key,
        storage: 's3'
      };
    } catch (error) {
      console.error('❌ S3 upload error:', error);
      throw error;
    }
  }

  /**
   * Delete file
   */
  async deleteFile(filename) {
    try {
      if (this.storageType === 's3') {
        return await this.deleteFromS3(filename);
      } else {
        return await this.deleteLocally(filename);
      }
    } catch (error) {
      console.error('❌ Delete file error:', error);
      return false;
    }
  }

  /**
   * Delete from local storage
   */
  async deleteLocally(filename) {
    try {
      const filepath = path.join(this.uploadsDir, filename);
      await fs.unlink(filepath);
      
      console.log(`🗑️  File deleted locally: ${filename}`);
      return true;
    } catch (error) {
      if (error.code === 'ENOENT') {
        console.log(`⚠️  File not found:  ${filename}`);
        return true;
      }
      throw error;
    }
  }

  /**
   * Delete from AWS S3
   */
  async deleteFromS3(filename) {
    try {
      const params = {
        Bucket: this.bucketName,
        Key: filename
      };

      await this.s3.deleteObject(params).promise();
      
      console.log(`🗑️  File deleted from S3: ${filename}`);
      return true;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Generate signed URL (for S3)
   */
  async getSignedUrl(filename, expiresIn = 3600) {
    if (this.storageType !== 's3') {
      return `/uploads/${filename}`;
    }

    try {
      const params = {
        Bucket: this.bucketName,
        Key: filename,
        Expires:  expiresIn
      };

      const url = await this.s3.getSignedUrlPromise('getObject', params);
      return url;
    } catch (error) {
      console.error('❌ Generate signed URL error:', error);
      throw error;
    }
  }
}

module.exports = new StorageService();