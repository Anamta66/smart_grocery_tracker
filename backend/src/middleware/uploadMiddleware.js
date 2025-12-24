/**
 * ============================================
 * File Upload Middleware
 * ============================================
 * Handles file uploads using Multer
 * Supports image uploads for grocery items
 * ============================================
 */

const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

/**
 * Configure storage
 */
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file. originalname);
    const filename = `${file.fieldname}-${uniqueSuffix}${ext}`;
    cb(null, filename);
  }
});

/**
 * File filter - Only allow images
 */
const imageFilter = (req, file, cb) => {
  // Allowed file types
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  
  // Check extension
  const extname = allowedTypes.test(
    path.extname(file. originalname).toLowerCase()
  );
  
  // Check mimetype
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Only image files are allowed (jpeg, jpg, png, gif, webp)'));
  }
};

/**
 * Configure multer
 */
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max file size
  },
  fileFilter: imageFilter
});

/**
 * @desc    Upload single image
 * @field   image
 */
exports.uploadSingleImage = upload.single('image');

/**
 * @desc    Upload multiple images (max 5)
 * @field   images
 */
exports. uploadMultipleImages = upload. array('images', 5);

/**
 * @desc    Upload with custom field names
 */
exports.uploadFields = upload.fields([
  { name: 'groceryImage', maxCount: 1 },
  { name: 'receiptImage', maxCount: 1 }
]);

/**
 * @desc    Process uploaded file
 * @middleware
 */
exports.processUpload = (req, res, next) => {
  try {
    if (req.file) {
      // Add file URL to request
      req.fileUrl = `/uploads/${req.file.filename}`;
      
      // Add file info
      req.uploadedFile = {
        filename: req.file.filename,
        originalName: req.file.originalname,
        size: req.file.size,
        mimetype: req.file.mimetype,
        url: req.fileUrl
      };
    }

    next();
  } catch (error) {
    console.error('File processing error:', error);
    next(error);
  }
};

/**
 * @desc    Delete file
 * @param   {string} filename - File name to delete
 */
exports. deleteFile = (filename) => {
  try {
    const filePath = path.join(uploadsDir, filename);
    
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
      console.log(`File deleted: ${filename}`);
      return true;
    }
    
    return false;
  } catch (error) {
    console.error('File deletion error:', error);
    return false;
  }
};

/**
 * @desc    Handle upload errors
 * @middleware
 */
exports.handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'File size too large. Maximum allowed size is 5MB.'
      });
    }
    
    if (err. code === 'LIMIT_UNEXPECTED_FILE') {
      return res.status(400).json({
        success: false,
        message: 'Unexpected file field.  Please check your upload.'
      });
    }

    return res.status(400).json({
      success: false,
      message: `Upload error: ${err.message}`
    });
  }

  if (err) {
    return res.status(400).json({
      success: false,
      message: err.message || 'File upload failed'
    });
  }

  next();
};