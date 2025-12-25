// lib/data/services/grocery_service. dart

import 'api_service.dart';
import 'api_config.dart';
import '../models/grocery_item_model.dart';

class GroceryService {
  /// Fetch all grocery items
  static Future<List<GroceryItemModel>> getAllItems() async {
    try {
      final response = await ApiService.get(ApiConfig.groceries);

      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => GroceryItemModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch groceries: $e');
    }
  }

  /// Add new grocery item
  static Future<GroceryItemModel> addItem(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post(ApiConfig.groceries, data);
      return GroceryItemModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  /// Update grocery item
  static Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await ApiService.put('${ApiConfig.groceries}/$id', data);
      return true;
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  /// Delete grocery item
  static Future<bool> deleteItem(String id) async {
    try {
      await ApiService.delete('${ApiConfig.groceries}/$id');
      return true;
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  /// Search groceries
  static Future<List<GroceryItemModel>> searchItems(String query) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.search}/groceries',
        params: {'q': query},
      );

      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => GroceryItemModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Get expiring items
  static Future<List<GroceryItemModel>> getExpiringItems({int days = 7}) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.expiry}/expiring-soon',
        params: {'days': days.toString()},
      );

      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => GroceryItemModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch expiring items: $e');
    }
  }
}
