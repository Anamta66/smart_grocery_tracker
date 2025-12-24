import 'package:flutter/foundation.dart';
import '../../data/models/grocery_item_model.dart';
import '../../data/services/grocery_service.dart';

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
      _inventoryItems = await _groceryService.getAllGroceryItems();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
        final updatedItem = _inventoryItems[index].copyWith(quantity: quantity);
        final result = await _groceryService.updateGroceryItem(updatedItem);
        _inventoryItems[index] = result;
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
  double getTotalInventoryValue() {
    return _inventoryItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  /// Get inventory by category
  Map<String, List<GroceryItemModel>> getInventoryByCategory() {
    final Map<String, List<GroceryItemModel>> grouped = {};

    for (var item in _inventoryItems) {
      if (!grouped.containsKey(item.categoryId)) {
        grouped[item.categoryId] = [];
      }
      grouped[item.categoryId]!.add(item);
    }

    return grouped;
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
