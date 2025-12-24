import 'api_service.dart';

/// Service for managing inventory and stock levels
class InventoryService {
  /// Get current inventory summary
  static Future<Map<String, dynamic>> getInventorySummary() async {
    try {
      final response = await ApiService.get('inventory/summary');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch inventory summary: $e');
    }
  }

  /// Update stock level for an item
  static Future<bool> updateStock(String itemId, int quantity) async {
    try {
      await ApiService.put('inventory/$itemId/stock', {'quantity': quantity});
      return true;
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  /// Get low-stock items
  static Future<List<dynamic>> getLowStockItems() async {
    try {
      final response = await ApiService.get('inventory/low-stock');
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch low-stock items: $e');
    }
  }
}
