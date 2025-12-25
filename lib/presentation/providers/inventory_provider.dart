// lib/presentation/providers/inventory_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/models/grocery_item_model.dart';
import '../../data/services/grocery_service.dart';

class InventoryProvider with ChangeNotifier {
  List<GroceryItemModel> _inventoryItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<GroceryItemModel> get inventoryItems => _inventoryItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get unique categories from inventory
  List<String> get categories {
    final categorySet = <String>{};
    for (var item in _inventoryItems) {
      if (item.categoryId != null && item.categoryId!.isNotEmpty) {
        categorySet.add(item.categoryId!);
      }
    }
    return categorySet.toList()..sort();
  }

  /// Fetch all inventory items
  Future<void> fetchInventory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _inventoryItems = await GroceryService.getAllItems();

      if (kDebugMode) {
        print('✅ Fetched ${_inventoryItems.length} inventory items');
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);

      if (kDebugMode) {
        print('❌ Error fetching inventory: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new inventory item
  Future<bool> addItem(Map<String, dynamic> itemData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItem = await GroceryService.addItem(itemData);
      _inventoryItems.insert(0, newItem);

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('✅ Added new item: ${newItem.name}');
      }

      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error adding item: $e');
      }

      return false;
    }
  }

  /// Update inventory item
  Future<bool> updateItem(String itemId, Map<String, dynamic> itemData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await GroceryService.updateItem(itemId, itemData);

      if (success) {
        // Refresh the inventory list
        await fetchInventory();
      }

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('✅ Updated item: $itemId');
      }

      return success;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error updating item: $e');
      }

      return false;
    }
  }

  /// Update stock quantity (quick update)
  Future<bool> updateStock(String itemId, int quantity) async {
    try {
      final index = _inventoryItems.indexWhere((i) => i.id == itemId);

      if (index == -1) {
        _errorMessage = 'Item not found';
        notifyListeners();
        return false;
      }

      final currentItem = _inventoryItems[index];

      // Prepare update data
      final updateData = {
        'quantity': quantity.toDouble(),
      };

      // Call API to update
      final success = await GroceryService.updateItem(itemId, updateData);

      if (success) {
        // Update local list
        _inventoryItems[index] = currentItem.copyWith(
          quantity: quantity.toDouble(),
        );
        notifyListeners();

        if (kDebugMode) {
          print('✅ Updated stock for ${currentItem.name}:  $quantity');
        }
      }

      return success;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error updating stock: $e');
      }

      return false;
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

        if (kDebugMode) {
          print('✅ Deleted item: $itemId');
        }
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error deleting item: $e');
      }

      return false;
    }
  }

  /// Get low stock items (quantity < 5)
  List<GroceryItemModel> getLowStockItems() {
    return _inventoryItems
        .where((item) => item.quantity < 5 && item.quantity > 0)
        .toList();
  }

  /// Get out of stock items
  List<GroceryItemModel> getOutOfStockItems() {
    return _inventoryItems.where((item) => item.quantity == 0).toList();
  }

  /// Get expiring soon items (within 7 days)
  List<GroceryItemModel> getExpiringSoonItems({int days = 7}) {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));

    return _inventoryItems.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.isAfter(now) &&
          item.expiryDate!.isBefore(threshold);
    }).toList();
  }

  /// Get expired items
  List<GroceryItemModel> getExpiredItems() {
    final now = DateTime.now();

    return _inventoryItems.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.isBefore(now);
    }).toList();
  }

  /// Get total inventory count
  int getTotalItemCount() {
    return _inventoryItems.length;
  }

  /// Get total quantity across all items
  double getTotalQuantity() {
    return _inventoryItems.fold(
      0.0,
      (sum, item) => sum + item.quantity,
    );
  }

  /// Get inventory value (if items have price)
  /// Returns total quantity if no price field exists
  double getTotalInventoryValue() {
    // Check if GroceryItemModel has price field
    // If not, just return total quantity
    try {
      return _inventoryItems.fold(
        0.0,
        (sum, item) {
          // Try to access price, if it doesn't exist, use quantity
          try {
            return sum + (item.price * item.quantity);
          } catch (e) {
            return sum + item.quantity;
          }
        },
      );
    } catch (e) {
      // Fallback to just quantity sum
      return getTotalQuantity();
    }
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

  /// Get inventory statistics
  Map<String, dynamic> getInventoryStats() {
    return {
      'totalItems': getTotalItemCount(),
      'totalQuantity': getTotalQuantity(),
      'lowStockCount': getLowStockItems().length,
      'outOfStockCount': getOutOfStockItems().length,
      'expiringSoonCount': getExpiringSoonItems().length,
      'expiredCount': getExpiredItems().length,
      'totalValue': getTotalInventoryValue(),
      'categoryCount': categories.length,
    };
  }

  /// Search inventory items
  List<GroceryItemModel> searchItems(String query) {
    if (query.isEmpty) return _inventoryItems;

    final lowerQuery = query.toLowerCase();

    return _inventoryItems.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          (item.categoryId?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter items by category
  List<GroceryItemModel> filterByCategory(String category) {
    if (category == 'All') return _inventoryItems;

    return _inventoryItems.where((item) {
      return item.categoryId == category;
    }).toList();
  }

  /// Sort items
  List<GroceryItemModel> sortItems(String sortBy, {bool ascending = true}) {
    final sorted = List<GroceryItemModel>.from(_inventoryItems);

    switch (sortBy) {
      case 'name':
        sorted.sort((a, b) =>
            ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case 'quantity':
        sorted.sort((a, b) => ascending
            ? a.quantity.compareTo(b.quantity)
            : b.quantity.compareTo(a.quantity));
        break;
      case 'expiry':
        sorted.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return ascending
              ? a.expiryDate!.compareTo(b.expiryDate!)
              : b.expiryDate!.compareTo(a.expiryDate!);
        });
        break;
      case 'category':
        sorted.sort((a, b) {
          final catA = a.categoryId ?? 'Uncategorized';
          final catB = b.categoryId ?? 'Uncategorized';
          return ascending ? catA.compareTo(catB) : catB.compareTo(catA);
        });
        break;
    }

    return sorted;
  }

  /// Refresh inventory (alias for fetchInventory)
  Future<void> refresh() async {
    await fetchInventory();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all inventory data (logout/reset)
  void clearInventory() {
    _inventoryItems.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Extract user-friendly error message
  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      return message.replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  /// Debug:  Print inventory state
  void debugPrintState() {
    if (!kDebugMode) return;

    print('═══════════════════════════════════════');
    print('📊 INVENTORY PROVIDER STATE');
    print('═══════════════════════════════════════');
    print('Total Items: ${getTotalItemCount()}');
    print('Total Quantity: ${getTotalQuantity()}');
    print('Low Stock: ${getLowStockItems().length}');
    print('Out of Stock: ${getOutOfStockItems().length}');
    print('Expiring Soon: ${getExpiringSoonItems().length}');
    print('Expired: ${getExpiredItems().length}');
    print('Categories: ${categories.length}');
    print('Is Loading: $_isLoading');
    print('Error: $_errorMessage');
    print('═══════════════════════════════════════');
  }
}
