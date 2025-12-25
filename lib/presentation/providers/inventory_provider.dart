import 'package:flutter/foundation.dart';
import '../../data/models/grocery_item_model.dart';
import '../../data/services/grocery_service.dart';
import '../../domain/entities/grocery_item.dart';

class InventoryProvider with ChangeNotifier {
  final GroceryService _groceryService = GroceryService();

  List<GroceryItemModel> _inventoryItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<GroceryItemModel> get inventoryItems => _inventoryItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all inventory items
  Future<void> fetchInventory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _inventoryItems = await GroceryService.getAllItems();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an item
  Future<bool> deleteItem(String itemId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await GroceryService.deleteItem(itemId);

      if (result) {
        _inventoryItems.removeWhere((item) => item.id == itemId);
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update stock quantity
  Future<bool> updateStock(String itemId, int quantity) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _inventoryItems.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        // Convert GroceryItemModel to GroceryItem entity
        final currentItem = _inventoryItems[index];
        final updatedGroceryItem = GroceryItem(
          userId: currentItem.userId,
          name: currentItem.name,
          id: currentItem.id,
          quantity: quantity,
          expiryDate: currentItem.expiryDate,
          category: currentItem.categoryId ?? '',
          createdAt: currentItem.createdAt ?? DateTime.now(),
          // Add other required fields from your GroceryItem entity
        );

        // FIX 1: Use the correct static method with id and item
        final result =
            await GroceryService.updateItem(itemId, updatedGroceryItem);

        if (result) {
          // Update local list with new quantity
          _inventoryItems[index] =
              currentItem.copyWith(quantity: quantity.toDouble());
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get low stock items (quantity < 5)
  List<GroceryItemModel> getLowStockItems() {
    return _inventoryItems.where((item) => item.quantity < 5).toList();
  }

  /// Get out of stock items
  List<GroceryItemModel> getOutOfStockItems() {
    return _inventoryItems.where((item) => item.quantity == 0).toList();
  }

  /// Get total inventory value
  /// FIX 2: Remove price calculation since GroceryItemModel doesn't have price
  double getTotalInventoryValue() {
    return _inventoryItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity), // Just sum quantities
    );
  }

  /// Get inventory by category
  Map<String, List<GroceryItemModel>> getInventoryByCategory() {
    final Map<String, List<GroceryItemModel>> grouped = {};

    for (var item in _inventoryItems) {
      final categoryKey = item.categoryId ?? 'Uncategorized';

      if (!grouped.containsKey(categoryKey)) {
        grouped[categoryKey] = [];
      }
      grouped[categoryKey]!.add(item);
    }

    return grouped;
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
