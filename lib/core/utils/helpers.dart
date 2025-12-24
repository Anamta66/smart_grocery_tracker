// helpers.dart - Utility helper functions used throughout the app
// Contains date formatting, calculations, and other common utilities

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

/// Helpers class contains utility methods for common operations
class Helpers {
  Helpers._();

  /// Format date to readable string (e.g., "Dec 25, 2024")
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date for short display (e.g., "25/12/24")
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  /// Format date and time (e.g., "Dec 25, 2024 at 10:30 AM")
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(dateTime);
  }

  /// Calculate days until expiry
  static int daysUntilExpiry(DateTime expiryDate) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final expiryOnly = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );
    return expiryOnly.difference(todayOnly).inDays;
  }

  /// Get expiry status text
  static String getExpiryStatusText(DateTime expiryDate) {
    final days = daysUntilExpiry(expiryDate);

    if (days < 0) {
      return 'Expired ${-days} days ago';
    } else if (days == 0) {
      return 'Expires today';
    } else if (days == 1) {
      return 'Expires tomorrow';
    } else if (days <= 7) {
      return 'Expires in $days days';
    } else {
      return 'Fresh - $days days left';
    }
  }

  /// Get color based on expiry status
  static Color getExpiryColor(DateTime expiryDate) {
    final days = daysUntilExpiry(expiryDate);

    if (days < 0) {
      return AppColors.expiryExpired; // Red - expired
    } else if (days <= 3) {
      return AppColors.expiryNear; // Orange - expiring very soon
    } else if (days <= 7) {
      return AppColors.warning; // Yellow - expiring soon
    } else {
      return AppColors.expiryFresh; // Green - fresh
    }
  }

  /// Get stock status color
  static Color getStockColor(int quantity, int threshold) {
    if (quantity <= 0) {
      return AppColors.error; // Red - out of stock
    } else if (quantity <= threshold) {
      return AppColors.lowStock; // Orange - low stock
    } else {
      return AppColors.inStock; // Green - in stock
    }
  }

  /// Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Capitalize first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Show snackbar with message
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Parse voice input to extract item name and quantity
  /// Example: "Add milk, 2 liters" -> {name: "milk", quantity: 2, unit: "liters"}
  static Map<String, dynamic>? parseVoiceInput(String input) {
    // Remove common phrases like "add", "insert", etc.
    String cleanInput = input
        .toLowerCase()
        .replaceAll(RegExp(r'\badd\b'), '')
        .replaceAll(RegExp(r'\binsert\b'), '')
        .replaceAll(RegExp(r'\bput\b'), '')
        .trim();

    // Try to extract quantity and unit
    final quantityRegex = RegExp(r'(\d+(? :\.\d+)?)\s*(\w+)?');
    final match = quantityRegex.firstMatch(cleanInput);

    if (match != null) {
      final quantity = double.tryParse(match.group(1) ?? '1') ?? 1;
      final possibleUnit = match.group(2);

      // Remove quantity and unit from string to get item name
      String itemName = cleanInput
          .replaceFirst(match.group(0) ?? '', '')
          .replaceAll(RegExp(r'[,.]'), '')
          .trim();

      // Common units
      final units = [
        'kg',
        'g',
        'liter',
        'liters',
        'ml',
        'piece',
        'pieces',
        'pack',
        'packs',
        'dozen',
      ];
      String? unit;

      if (possibleUnit != null && units.contains(possibleUnit.toLowerCase())) {
        unit = possibleUnit;
      }

      return {
        'name': capitalizeWords(itemName),
        'quantity': quantity.toInt(),
        'unit': unit ?? 'piece',
      };
    }

    // If no quantity found, return just the item name
    return {
      'name': capitalizeWords(cleanInput),
      'quantity': 1,
      'unit': 'piece',
    };
  }
}
