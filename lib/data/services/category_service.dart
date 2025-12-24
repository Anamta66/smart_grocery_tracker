/// category_service.dart
/// Service layer for category-related operations
/// Handles API calls for category CRUD operations with caching support
/// Implements error handling and offline fallback mechanisms

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../data/models/category_model.dart';
import 'local_storage_service.dart';

class CategoryService {
  // Singleton pattern for single instance across the app
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  // HTTP client for API calls
  final http.Client _client = http.Client();

  // Local storage service for caching
  final LocalStorageService _storage = LocalStorageService();

  // In-memory cache for quick access
  List<CategoryModel>? _cachedCategories;
  DateTime? _lastCacheTime;

  /// Gets the base URL based on platform (emulator/device)
  String get _baseUrl {
    // You can add platform detection logic here
    // For now, using the default base URL
    return AppConstants.baseUrl;
  }

  /// Gets the full endpoint URL for categories
  String get _categoriesUrl => '$_baseUrl${AppConstants.categoryEndpoint}';

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
        if (AppConstants.enableDebugLogs) {
          print('📦 Using cached categories');
        }
        return _cachedCategories!;
      }

      // Fetch from API
      if (AppConstants.enableDebugLogs) {
        print('🌐 Fetching categories from API.. .');
      }

      final response = await _client
          .get(
            Uri.parse(_categoriesUrl),
            headers: await _getHeaders(),
          )
          .timeout(AppConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> categoriesJson = jsonResponse['data'] ?? [];

        final List<CategoryModel> categories =
            categoriesJson.map((json) => CategoryModel.fromJson(json)).toList();

        // Update cache
        await _updateCache(categories);

        if (AppConstants.enableDebugLogs) {
          print('✅ Successfully fetched ${categories.length} categories');
        }

        return categories;
      } else if (response.statusCode == 401) {
        throw Exception(AppConstants.errorUnauthorized);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error fetching categories: $e');
      }

      // Try to return cached data if available
      final cachedData = await _getCachedCategories();
      if (cachedData != null && cachedData.isNotEmpty) {
        if (AppConstants.enableDebugLogs) {
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
      if (AppConstants.enableDebugLogs) {
        print('🌐 Fetching category with ID: $id');
      }

      final response = await _client
          .get(
            Uri.parse('$_categoriesUrl/$id'),
            headers: await _getHeaders(),
          )
          .timeout(AppConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final categoryJson = jsonResponse['data'];

        if (categoryJson != null) {
          return CategoryModel.fromJson(categoryJson);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception(AppConstants.errorUnauthorized);
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error fetching category: $e');
      }
      rethrow;
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
      if (AppConstants.enableDebugLogs) {
        print('🌐 Creating new category: $name');
      }

      final Map<String, dynamic> categoryData = {
        'name': name.trim(),
        if (description != null && description.isNotEmpty)
          'description': description.trim(),
        if (icon != null && icon.isNotEmpty) 'icon': icon,
        if (color != null && color.isNotEmpty) 'color': color,
      };

      final response = await _client
          .post(
            Uri.parse(_categoriesUrl),
            headers: await _getHeaders(),
            body: json.encode(categoryData),
          )
          .timeout(AppConstants.connectionTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final categoryJson = jsonResponse['data'];

        final CategoryModel newCategory = CategoryModel.fromJson(categoryJson);

        // Invalidate cache to force refresh
        await _invalidateCache();

        if (AppConstants.enableDebugLogs) {
          print('✅ Category created successfully: ${newCategory.id}');
        }

        return newCategory;
      } else if (response.statusCode == 401) {
        throw Exception(AppConstants.errorUnauthorized);
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        throw Exception(errorResponse['message'] ?? 'Invalid category data');
      } else {
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
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
      if (AppConstants.enableDebugLogs) {
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

      final response = await _client
          .put(
            Uri.parse('$_categoriesUrl/$id'),
            headers: await _getHeaders(),
            body: json.encode(updateData),
          )
          .timeout(AppConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final categoryJson = jsonResponse['data'];

        final CategoryModel updatedCategory =
            CategoryModel.fromJson(categoryJson);

        // Invalidate cache
        await _invalidateCache();

        if (AppConstants.enableDebugLogs) {
          print('✅ Category updated successfully');
        }

        return updatedCategory;
      } else if (response.statusCode == 401) {
        throw Exception(AppConstants.errorUnauthorized);
      } else if (response.statusCode == 404) {
        throw Exception('Category not found');
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error updating category: $e');
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
      if (AppConstants.enableDebugLogs) {
        print('🌐 Deleting category:  $id');
      }

      final response = await _client
          .delete(
            Uri.parse('$_categoriesUrl/$id'),
            headers: await _getHeaders(),
          )
          .timeout(AppConstants.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Invalidate cache
        await _invalidateCache();

        if (AppConstants.enableDebugLogs) {
          print('✅ Category deleted successfully');
        }

        return true;
      } else if (response.statusCode == 401) {
        throw Exception(AppConstants.errorUnauthorized);
      } else if (response.statusCode == 404) {
        throw Exception('Category not found');
      } else if (response.statusCode == 409) {
        throw Exception('Cannot delete category: Items exist in this category');
      } else {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
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
      final categories = await getCategories();
      final searchQuery = query.toLowerCase().trim();

      return categories.where((category) {
        return category.name.toLowerCase().contains(searchQuery) ||
            (category.description?.toLowerCase().contains(searchQuery) ??
                false);
      }).toList();
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error searching categories: $e');
      }
      rethrow;
    }
  }

  // ========================================
  // 🔧 HELPER METHODS
  // ========================================

  /// Gets HTTP headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getAccessToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Checks if cached data is still valid
  bool _isCacheValid() {
    if (_cachedCategories == null || _lastCacheTime == null) {
      return false;
    }

    final cacheAge = DateTime.now().difference(_lastCacheTime!);
    final validityDuration = Duration(
      hours: AppConstants.categoryCacheValidityHours,
    );

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
        AppConstants.keyCategoriesCache,
        json.encode(categoriesJson),
      );
      await _storage.saveString(
        AppConstants.keyCategoriesCacheTime,
        _lastCacheTime!.toIso8601String(),
      );
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('⚠️ Failed to save categories to cache: $e');
      }
    }
  }

  /// Gets categories from persistent cache
  Future<List<CategoryModel>?> _getCachedCategories() async {
    try {
      final cachedJson =
          await _storage.getString(AppConstants.keyCategoriesCache);
      if (cachedJson == null) return null;

      final List<dynamic> categoriesJson = json.decode(cachedJson);
      return categoriesJson
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('⚠️ Failed to load cached categories: $e');
      }
      return null;
    }
  }

  /// Invalidates cache (forces refresh on next call)
  Future<void> _invalidateCache() async {
    _cachedCategories = null;
    _lastCacheTime = null;

    await _storage.remove(AppConstants.keyCategoriesCache);
    await _storage.remove(AppConstants.keyCategoriesCacheTime);
  }

  /// Clears all cache
  Future<void> clearCache() async {
    await _invalidateCache();
    if (AppConstants.enableDebugLogs) {
      print('🗑️ Category cache cleared');
    }
  }

  /// Disposes resources
  void dispose() {
    _client.close();
  }
}
