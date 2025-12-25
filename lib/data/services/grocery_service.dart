// lib/data/services/grocery_service.dart

import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_config.dart';
import '../models/grocery_item_model.dart';

class GroceryService {
  // ========================================
  // 📥 FETCH GROCERIES
  // ========================================

  /// Fetch all grocery items
  static Future<List<GroceryItemModel>> getAllItems() async {
    try {
      if (kDebugMode) {
        print('🌐 Fetching all grocery items.. .');
      }

      final response = await ApiService.get(ApiConfig.groceries);

      if (response['success'] == true || response['data'] != null) {
        final List<dynamic> data = response['data'] is List
            ? response['data']
            : (response['data']['groceries'] ?? []);

        final items =
            data.map((json) => GroceryItemModel.fromJson(json)).toList();

        if (kDebugMode) {
          print('✅ Fetched ${items.length} grocery items');
        }

        return items;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching groceries: $e');
      }
      throw Exception('Failed to fetch groceries: $e');
    }
  }

  /// Fetch a single grocery item by ID
  static Future<GroceryItemModel?> getItemById(String id) async {
    try {
      if (kDebugMode) {
        print('🌐 Fetching grocery item with ID: $id');
      }

      final response = await ApiService.get('${ApiConfig.groceries}/$id');

      if (response['success'] == true && response['data'] != null) {
        if (kDebugMode) {
          print('✅ Grocery item fetched successfully');
        }
        return GroceryItemModel.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching grocery item: $e');
      }
      return null;
    }
  }

  /// Get user's grocery items (my groceries)
  static Future<List<GroceryItemModel>> getMyItems() async {
    try {
      if (kDebugMode) {
        print('🌐 Fetching my grocery items...');
      }

      final response =
          await ApiService.get('${ApiConfig.groceries}/my-groceries');

      if (response['success'] == true || response['data'] != null) {
        final List<dynamic> data = response['data'] is List
            ? response['data']
            : (response['data']['groceries'] ?? []);

        final items =
            data.map((json) => GroceryItemModel.fromJson(json)).toList();

        if (kDebugMode) {
          print('✅ Fetched ${items.length} my grocery items');
        }

        return items;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching my groceries: $e');
      }
      throw Exception('Failed to fetch my groceries: $e');
    }
  }

  // ========================================
  // ➕ CREATE GROCERY
  // ========================================

  /// Add new grocery item
  static Future<GroceryItemModel> addItem(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('🌐 Adding new grocery item:  ${data['name']}');
      }

      final response = await ApiService.post(ApiConfig.groceries, data);

      if (response['success'] == true && response['data'] != null) {
        if (kDebugMode) {
          print('✅ Grocery item added successfully');
        }
        return GroceryItemModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to add item');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding item: $e');
      }
      throw Exception('Failed to add item: $e');
    }
  }

  // ========================================
  // ✏️ UPDATE GROCERY
  // ========================================

  /// Update grocery item
  static Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('🌐 Updating grocery item: $id');
      }

      final response = await ApiService.put('${ApiConfig.groceries}/$id', data);

      if (response['success'] == true) {
        if (kDebugMode) {
          print('✅ Grocery item updated successfully');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating item: $e');
      }
      throw Exception('Failed to update item: $e');
    }
  }

  /// Update item quantity
  static Future<bool> updateQuantity(String id, double quantity) async {
    try {
      if (kDebugMode) {
        print('🌐 Updating quantity for item: $id to $quantity');
      }

      final response = await ApiService.put(
        '${ApiConfig.groceries}/$id',
        {'quantity': quantity},
      );

      if (response['success'] == true) {
        if (kDebugMode) {
          print('✅ Quantity updated successfully');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating quantity: $e');
      }
      throw Exception('Failed to update quantity: $e');
    }
  }

  // ========================================
  // 🗑️ DELETE GROCERY
  // ========================================

  /// Delete grocery item
  static Future<bool> deleteItem(String id) async {
    try {
      if (kDebugMode) {
        print('🌐 Deleting grocery item: $id');
      }

      final response = await ApiService.delete('${ApiConfig.groceries}/$id');

      if (response['success'] == true) {
        if (kDebugMode) {
          print('✅ Grocery item deleted successfully');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting item:  $e');
      }
      throw Exception('Failed to delete item:  $e');
    }
  }

  /// Delete multiple items
  static Future<bool> deleteMultipleItems(List<String> ids) async {
    try {
      if (kDebugMode) {
        print('🌐 Deleting ${ids.length} grocery items');
      }

      final response = await ApiService.post(
        '${ApiConfig.groceries}/delete-multiple',
        {'ids': ids},
      );

      if (response['success'] == true) {
        if (kDebugMode) {
          print('✅ Multiple items deleted successfully');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting multiple items: $e');
      }
      throw Exception('Failed to delete items: $e');
    }
  }

  // ========================================
  // 🔍 SEARCH & FILTER
  // ========================================

  /// Search groceries
  static Future<List<GroceryItemModel>> searchItems(String query) async {
    try {
      if (kDebugMode) {
        print('🌐 Searching groceries:  $query');
      }

      final response = await ApiService.get(
        '${ApiConfig.search}/groceries',
        params: {'q': query},
      );

      if (response['success'] == true || response['data'] != null) {
        final List<dynamic> data = response['data'] is List
            ? response['data']
            : (response['data']['results'] ?? []);

        final items =
            data.map((json) => GroceryItemModel.fromJson(json)).toList();

        if (kDebugMode) {
          print('✅ Found ${items.length} items matching "$query"');
        }

        return items;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Search failed: $e');
      }
      throw Exception('Search failed: $e');
    }
  }

  /// Filter items by category
  static Future<List<GroceryItemModel>> getItemsByCategory(
      String categoryId) async {
    try {
      if (kDebugMode) {
        print('🌐 Fetching items for category: $categoryId');
      }

      final response = await ApiService.get(
        ApiConfig.groceries,
        params: {'category': categoryId},
      );

      if (response['success'] == true || response['data'] != null) {
        final List<dynamic> data = response['data'] is List
            ? response['data']
            : (response['data']['groceries'] ?? []);

        final items =
            data.map((json) => GroceryItemModel.fromJson(json)).toList();

        if (kDebugMode) {
          print('✅ Found ${items.length} items in category');
        }

        return items;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching by category: $e');
      }
      throw Exception('Failed to fetch items by category: $e');
    }
  }

  // ========================================
  // ⏰ EXPIRY TRACKING
  // ========================================

  /// Get expiring items
  static Future<List<GroceryItemModel>> getExpiringItems({int days = 7}) async {
    try {
      if (kDebugMode) {
        print('🌐 Fetching items expiring in $days days.. .');
      }

      final response = await ApiService.get(
        '${ApiConfig.expiry}/expiring-soon',
        params: {'days': days.toString()},
      );

      if (response['success'] == true || response['data'] != null) {
        final List<dynamic> data = response['data'] is List
            ? response['data']
            : (response['data']['items'] ?? []);

        final items =
            data.map((json) => GroceryItemModel.fromJson(json)).toList();

        if (kDebugMode) {
          print('✅ Found ${items.length} items expiring soon');
        }

        return items;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching expiring items:  $e');
      }
      throw Exception('Failed to fetch expiring items: $e');
    }
  }

  /// Get expired items
  static Future<List<GroceryItemModel>> getExpiredItems() async {
    try {
      if (kDebugMode) {
        print('🌐 Fetching expired items...');
      }

      final response = await ApiService.get('${ApiConfig.expiry}/expired');

      if (response['success'] == true || response['data'] != null) {
        final List<dynamic> data = response['data'] is List
            ? response['data']
            : (response['data']['items'] ?? []);

        final items =
            data.map((json) => GroceryItemModel.fromJson(json)).toList();

        if (kDebugMode) {
          print('✅ Found ${items.length} expired items');
        }

        return items;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching expired items: $e');
      }
      throw Exception('Failed to fetch expired items: $e');
    }
  }

  // ========================================
  // 📊 STATISTICS
  // ========================================

  /// Get grocery statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      if (kDebugMode) {
        print('🌐 Fetching grocery statistics...');
      }

      final response = await ApiService.get('${ApiConfig.groceries}/stats');

      if (response['success'] == true && response['data'] != null) {
        if (kDebugMode) {
          print('✅ Statistics fetched successfully');
        }
        return response['data'];
      }

      return {};
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching statistics: $e');
      }
      return {};
    }
  }

  // ========================================
  // 📦 BULK OPERATIONS
  // ========================================

  /// Add multiple items at once
  static Future<List<GroceryItemModel>> addMultipleItems(
    List<Map<String, dynamic>> items,
  ) async {
    try {
      if (kDebugMode) {
        print('🌐 Adding ${items.length} items.. .');
      }

      final response = await ApiService.post(
        '${ApiConfig.groceries}/bulk-add',
        {'items': items},
      );

      if (response['success'] == true && response['data'] is List) {
        final addedItems = (response['data'] as List)
            .map((json) => GroceryItemModel.fromJson(json))
            .toList();

        if (kDebugMode) {
          print('✅ ${addedItems.length} items added successfully');
        }

        return addedItems;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding multiple items: $e');
      }
      throw Exception('Failed to add multiple items: $e');
    }
  }

  /// Update multiple items at once
  static Future<bool> updateMultipleItems(
    List<Map<String, dynamic>> updates,
  ) async {
    try {
      if (kDebugMode) {
        print('🌐 Updating ${updates.length} items...');
      }

      final response = await ApiService.put(
        '${ApiConfig.groceries}/bulk-update',
        {'updates': updates},
      );

      if (response['success'] == true) {
        if (kDebugMode) {
          print('✅ Multiple items updated successfully');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating multiple items: $e');
      }
      throw Exception('Failed to update multiple items: $e');
    }
  }
}
