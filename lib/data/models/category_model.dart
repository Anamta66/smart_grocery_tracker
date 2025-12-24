// category_model. dart - Data model for grocery categories
// Used for organizing groceries and inventory items

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// CategoryModel represents a category for organizing items
class CategoryModel {
  final String id;
  final String name;
  final String? icon; // Icon name or emoji
  final Color color;
  final int itemCount;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    required this.color,
    this.itemCount = 0,
    this.description,
  });

  /// Create CategoryModel from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      color: Color(json['color'] ?? 0xFF4CAF50),
      itemCount: json['itemCount'] ?? 0,
      description: json['description'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'itemCount': itemCount,
      'description': description,
    };
  }

  /// Create copy with updated fields
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    int? itemCount,
    String? description,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      itemCount: itemCount ?? this.itemCount,
      description: description ?? this.description,
    );
  }

  /// Get default categories
  static List<CategoryModel> get defaultCategories {
    return [
      CategoryModel(
        id: '1',
        name: 'Fruits',
        icon: '🍎',
        color: AppColors.categoryColors[0],
      ),
      CategoryModel(
        id: '2',
        name: 'Vegetables',
        icon: '🥕',
        color: AppColors.categoryColors[1],
      ),
      CategoryModel(
        id: '3',
        name: 'Dairy',
        icon: '🥛',
        color: AppColors.categoryColors[2],
      ),
      CategoryModel(
        id: '4',
        name: 'Bakery',
        icon: '🍞',
        color: AppColors.categoryColors[3],
      ),
      CategoryModel(
        id: '5',
        name: 'Meat',
        icon: '🥩',
        color: AppColors.categoryColors[4],
      ),
      CategoryModel(
        id: '6',
        name: 'Beverages',
        icon: '🥤',
        color: AppColors.categoryColors[5],
      ),
      CategoryModel(
        id: '7',
        name: 'Grains',
        icon: '🌾',
        color: AppColors.categoryColors[6],
      ),
      CategoryModel(
        id: '8',
        name: 'Frozen',
        icon: '❄️',
        color: AppColors.categoryColors[7],
      ),
    ];
  }
}
