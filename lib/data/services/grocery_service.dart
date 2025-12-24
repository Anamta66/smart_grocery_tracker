import 'api_service.dart';
import '../../domain/entities/grocery_item.dart';

/// Service for managing grocery items
class GroceryService {
  /// Fetch all grocery items
  static Future<List<GroceryItem>> getAllItems() async {
    try {
      final response = await ApiService.get('groceries');
      if (response is List) {
        return response.map((json) => GroceryItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch grocery items: $e');
    }
  }

  /// Add a new grocery item
  static Future<bool> addItem(GroceryItem item) async {
    try {
      await ApiService.post('groceries', item.toJson());
      return true;
    } catch (e) {
      throw Exception('Failed to add grocery item:  $e');
    }
  }

  /// Update an existing grocery item
  static Future<bool> updateItem(String id, GroceryItem item) async {
    try {
      await ApiService.put('groceries/$id', item.toJson());
      return true;
    } catch (e) {
      throw Exception('Failed to update grocery item: $e');
    }
  }

  /// Delete a grocery item
  static Future<bool> deleteItem(String id) async {
    try {
      await ApiService.delete('groceries/$id');
      return true;
    } catch (e) {
      throw Exception('Failed to delete grocery item: $e');
    }
  }

  /// Search grocery items by query
  static Future<List<GroceryItem>> searchItems(String query) async {
    try {
      final response = await ApiService.get('groceries/search? q=$query');
      if (response is List) {
        return response.map((json) => GroceryItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search grocery items: $e');
    }
  }
}
