// app_colors. dart - Centralized color definitions for consistent theming
// All colors used throughout the app are defined here for easy maintenance

import 'package:flutter/material.dart';

/// AppColors contains all color constants used in the application
/// Following Material 3 design guidelines with a fresh, modern palette
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary brand colors - Fresh green theme for grocery app
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF81C784);
  static const Color primaryVariant = Color(0xFF388E3C);

  // Secondary accent colors - Warm orange for highlights
  static const Color secondaryLight = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFFFB74D);
  static const Color secondaryVariant = Color(0xFFF57C00);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Status colors for alerts and notifications
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Expiry status colors
  static const Color expiryNear = Color(0xFFFF9800); // Orange - expiring soon
  static const Color expiryExpired = Color(0xFFF44336); // Red - expired
  static const Color expiryFresh = Color(0xFF4CAF50); // Green - fresh

  // Low stock indicator
  static const Color lowStock = Color(0xFFFF5722);
  static const Color inStock = Color(0xFF4CAF50);

  // Category colors for visual distinction
  static const List<Color> categoryColors = [
    Color(0xFF4CAF50), // Fruits
    Color(0xFF8BC34A), // Vegetables
    Color(0xFF03A9F4), // Dairy
    Color(0xFFFF9800), // Bakery
    Color(0xFFE91E63), // Meat
    Color(0xFF9C27B0), // Beverages
    Color(0xFF795548), // Grains
    Color(0xFF607D8B), // Frozen
  ];

  // Card and container colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Border and divider colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Shimmer loading effect colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
