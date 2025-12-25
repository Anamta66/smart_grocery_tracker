/// category_service.dart
/// Service layer for category-related operations
/// Handles API calls for category CRUD operations with caching support
/// Implements error handling and offline fallback mechanisms

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/models/category_model.dart';
import 'api_service.dart';
import 'api_config.dart';
import 'local_storage_service.dart';

class CategoryService {
  // Singleton pattern for single instance across the app
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  // Local storage service for caching
  final LocalStorageService _storage = LocalStorageService();

  // In-memory cache for quick access
  List<CategoryModel>? _cachedCategories;
  DateTime? _lastCacheTime;

  // Cache validity duration (in hours)
  static const int _cacheValidityHours = 1;

  // Cache keys
  static const String _categoriesCacheKey = 'categories_cache';
  static const String _categoriesCacheTimeKey = 'categories_cache_time';

  // ========================================
  // 📥 FETCH CATEGORIES
  // ========================================

  /// Fetches all categories from API with caching support
  ///
  /// Returns cached data if available and valid
  /// Otherwise fetches from API and updates cache
  ///
  /// Throws exception if API fails and no cache available
  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    try {
      // Check if we should use cache
      if (!forceRefresh && _isCacheValid()) {
        if (kDebugMode) {
          print('📦 Using cached categories');
        }
        return _cachedCategories!;
      }

      // Fetch from API
      if (kDebugMode) {
        print('🌐 Fetching categories from API.. .');
      }

      final response = await ApiService.get(ApiConfig.categories);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> categoriesJson = response['data'] is List
            ? response['data']
            : (response['data']['categories'] ?? []);

        final List<CategoryModel> categories =
            categoriesJson.map((json) => CategoryModel.fromJson(json)).toList();

        // Update cache
        await _updateCache(categories);

        if (kDebugMode) {
          print('✅ Successfully fetched ${categories.length} categories');
        }

        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching categories: $e');
      }

      // Try to return cached data if available
      final cachedData = await _getCachedCategories();
      if (cachedData != null && cachedData.isNotEmpty) {
        if (kDebugMode) {
          print('📦 Returning stale cached categories due to error');
        }
        return cachedData;
      }

      // If no cache available, rethrow error
      rethrow;
    }
  }

  /// Fetches a single category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      if (kDebugMode) {
        print('🌐 Fetching category with ID: $id');
      }

      final response = await ApiService.get('${ApiConfig.categories}/$id');

      if (response['success'] == true && response['data'] != null) {
        return CategoryModel.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching category:  $e');
      }

      // Try to find in cache
      if (_cachedCategories != null) {
        try {
          return _cachedCategories!.firstWhere((c) => c.id == id);
        } catch (_) {
          return null;
        }
      }

      return null;
    }
  }

  // ========================================
  // ➕ CREATE CATEGORY
  // ========================================

  /// Creates a new category
  ///
  /// [name] - Category name (required)
  /// [description] - Category description (optional)
  /// [icon] - Icon name (optional)
  /// [color] - Color hex code (optional)
  ///
  /// Returns the created Category object
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? icon,
    String? color,
  }) async {
    try {
      if (kDebugMode) {
        print('🌐 Creating new category: $name');
      }

      final Map<String, dynamic> categoryData = {
        'name': name.trim(),
        if (description != null && description.isNotEmpty)
          'description': description.trim(),
        if (icon != null && icon.isNotEmpty) 'icon': icon,
        if (color != null && color.isNotEmpty) 'color': color,
      };

      final response = await ApiService.post(
        ApiConfig.categories,
        categoryData,
      );

      if (response['success'] == true && response['data'] != null) {
        final CategoryModel newCategory =
            CategoryModel.fromJson(response['data']);

        // Invalidate cache to force refresh
        await _invalidateCache();

        if (kDebugMode) {
          print('✅ Category created successfully:  ${newCategory.id}');
        }

        return newCategory;
      } else {
        throw Exception(response['message'] ?? 'Failed to create category');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating category: $e');
      }
      rethrow;
    }
  }

  // ========================================
  // ✏️ UPDATE CATEGORY
  // ========================================

  /// Updates an existing category
  ///
  /// [id] - Category ID to update
  /// [name] - New category name
  /// [description] - New description
  /// [icon] - New icon
  /// [color] - New color
  ///
  /// Returns the updated Category object
  Future<CategoryModel> updateCategory({
    required String id,
    String? name,
    String? description,
    String? icon,
    String? color,
  }) async {
    try {
      if (kDebugMode) {
        print('🌐 Updating category: $id');
      }

      final Map<String, dynamic> updateData = {};

      if (name != null && name.isNotEmpty) updateData['name'] = name.trim();
      if (description != null) updateData['description'] = description.trim();
      if (icon != null) updateData['icon'] = icon;
      if (color != null) updateData['color'] = color;

      if (updateData.isEmpty) {
        throw Exception('No data provided for update');
      }

      final response = await ApiService.put(
        '${ApiConfig.categories}/$id',
        updateData,
      );

      if (response['success'] == true && response['data'] != null) {
        final CategoryModel updatedCategory =
            CategoryModel.fromJson(response['data']);

        // Invalidate cache
        await _invalidateCache();

        if (kDebugMode) {
          print('✅ Category updated successfully');
        }

        return updatedCategory;
      } else {
        throw Exception(response['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating category:  $e');
      }
      rethrow;
    }
  }

  // ========================================
  // 🗑️ DELETE CATEGORY
  // ========================================

  /// Deletes a category by ID
  ///
  /// [id] - Category ID to delete
  ///
  /// Returns true if deletion was successful
  Future<bool> deleteCategory(String id) async {
    try {
      if (kDebugMode) {
        print('🌐 Deleting category:  $id');
      }

      final response = await ApiService.delete('${ApiConfig.categories}/$id');

      if (response['success'] == true) {
        // Invalidate cache
        await _invalidateCache();

        if (kDebugMode) {
          print('✅ Category deleted successfully');
        }

        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to delete category');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting category: $e');
      }
      rethrow;
    }
  }

  // ========================================
  // 🔍 SEARCH CATEGORIES
  // ========================================

  /// Searches categories by name
  Future<List<CategoryModel>> searchCategories(String query) async {
    if (query.trim().isEmpty) {
      return await getCategories();
    }

    try {
      // Try API search first
      try {
        final response = await ApiService.get(
          '${ApiConfig.search}/categories',
          params: {'q': query.trim()},
        );

        if (response['success'] == true && response['data'] is List) {
          return (response['data'] as List)
              .map((json) => CategoryModel.fromJson(json))
              .toList();
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('⚠️ API search failed, using local search:  $apiError');
        }
      }

      // Fallback to local search
      final categories = await getCategories();
      final searchQuery = query.toLowerCase().trim();

      return categories.where((category) {
        return category.name.toLowerCase().contains(searchQuery) ||
            (category.description?.toLowerCase().contains(searchQuery) ??
                false);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching categories: $e');
      }
      rethrow;
    }
  }

  // ========================================
  // 📊 STATISTICS
  // ========================================

  /// Get category with item count
  Future<Map<String, dynamic>> getCategoryStats(String categoryId) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.categories}/$categoryId/stats',
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }

      return {};
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching category stats:  $e');
      }
      return {};
    }
  }

  // ========================================
  // 🔧 HELPER METHODS
  // ========================================

  /// Checks if cached data is still valid
  bool _isCacheValid() {
    if (_cachedCategories == null || _lastCacheTime == null) {
      return false;
    }

    final cacheAge = DateTime.now().difference(_lastCacheTime!);
    final validityDuration = Duration(hours: _cacheValidityHours);

    return cacheAge < validityDuration;
  }

  /// Updates both in-memory and persistent cache
  Future<void> _updateCache(List<CategoryModel> categories) async {
    _cachedCategories = categories;
    _lastCacheTime = DateTime.now();

    // Save to persistent storage
    try {
      final categoriesJson = categories.map((c) => c.toJson()).toList();
      await _storage.saveString(
        _categoriesCacheKey,
        json.encode(categoriesJson),
      );
      await _storage.saveString(
        _categoriesCacheTimeKey,
        _lastCacheTime!.toIso8601String(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to save categories to cache: $e');
      }
    }
  }

  /// Gets categories from persistent cache
  Future<List<CategoryModel>?> _getCachedCategories() async {
    try {
      final cachedJson = await _storage.getString(_categoriesCacheKey);
      if (cachedJson == null) return null;

      final List<dynamic> categoriesJson = json.decode(cachedJson);
      return categoriesJson
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to load cached categories: $e');
      }
      return null;
    }
  }

  /// Invalidates cache (forces refresh on next call)
  Future<void> _invalidateCache() async {
    _cachedCategories = null;
    _lastCacheTime = null;

    await _storage.remove(_categoriesCacheKey);
    await _storage.remove(_categoriesCacheTimeKey);
  }

  /// Clears all cache
  Future<void> clearCache() async {
    await _invalidateCache();
    if (kDebugMode) {
      print('🗑️ Category cache cleared');
    }
  }

  /// Refresh categories from server
  Future<void> refresh() async {
    await getCategories(forceRefresh: true);
  }
}
