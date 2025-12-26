import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../core/config/api_config.dart';
import '../../data/models/grocery_item_model.dart';

class GroceryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<GroceryItemModel> _groceryItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GroceryItemModel> get groceryItems => _groceryItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get unique categories from groceries
  List<String> get categories {
    final categorySet = <String>{};
    for (var item in _groceryItems) {
      if (item.categoryId != null && item.categoryId!.isNotEmpty) {
        categorySet.add(item.categoryId!);
      }
    }
    final categories = categorySet.toList()..sort();
    return ['All', ...categories];
  }

  /// Fetch all grocery items
  Future<void> fetchGroceryItems() async {
    // ========================================
    // TEMPORARY MOCK FOR DEMO - REMOVE LATER
    // ========================================
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500)); // Simulate API call

    // Start with empty list - items will be added when user creates them
    _groceryItems = [];

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();

    if (kDebugMode) {
      print('✅ Mock groceries loaded (${_groceryItems.length} items)');
    }

    return;
    // ========================================
    // END MOCK - ORIGINAL CODE BELOW
    // ========================================

    /* COMMENT OUT FOR DEMO
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConfig.groceries);

      if (response['success'] == true) {
        final List<dynamic> data =
            response['data']['groceries'] ??  response['data'];
        _groceryItems =
            data.map((json) => GroceryItemModel. fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ Error fetching groceries: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    */
  }

  /// Add new grocery item
  Future<bool> addGroceryItem(GroceryItemModel item) async {
    // ========================================
    // TEMPORARY MOCK FOR DEMO - REMOVE LATER
    // ========================================
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500)); // Simulate API call

    // Create new item with generated ID
    final newItem = GroceryItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: item.name,
      categoryId: item.categoryId,
      quantity: item.quantity,
      unit: item.unit,
      price: item.price,
      expiryDate: item.expiryDate,
      userId: item.userId.isEmpty ? 'mock_user_id' : item.userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      minQuantity: item.minQuantity,
    );

    _groceryItems.add(newItem);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();

    if (kDebugMode) {
      print('✅ Mock item added:  ${newItem.name}');
    }

    return true;
    // ========================================
    // END MOCK - ORIGINAL CODE BELOW
    // ========================================

    /* COMMENT OUT FOR DEMO
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConfig.groceries,
        body: item.toJson(),
      );

      if (response['success'] == true) {
        final newItem = GroceryItemModel. fromJson(response['data']);
        _groceryItems.add(newItem);
        _isLoading = false;
        notifyListeners();

        if (kDebugMode) {
          print('✅ Item added successfully');
        }
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error adding item:  $e');
      }
      return false;
    }
    */
  }

  /// Update grocery item
  Future<bool> updateGroceryItem(GroceryItemModel item) async {
    // ========================================
    // TEMPORARY MOCK FOR DEMO - REMOVE LATER
    // ========================================
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500)); // Simulate API call

    final index = _groceryItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      final updatedItem = GroceryItemModel(
        id: item.id,
        name: item.name,
        categoryId: item.categoryId,
        quantity: item.quantity,
        unit: item.unit,
        price: item.price,
        expiryDate: item.expiryDate,
        userId: item.userId,
        createdAt: _groceryItems[index].createdAt,
        updatedAt: DateTime.now(),
        minQuantity: item.minQuantity,
      );

      _groceryItems[index] = updatedItem;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) {
        print('✅ Mock item updated: ${updatedItem.name}');
      }

      return true;
    }

    _isLoading = false;
    _errorMessage = 'Item not found';
    notifyListeners();
    return false;
    // ========================================
    // END MOCK - ORIGINAL CODE BELOW
    // ========================================

    /* COMMENT OUT FOR DEMO
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        ApiConfig. groceryById(item.id),
        body: item.toJson(),
      );

      if (response['success'] == true) {
        final updatedItem = GroceryItemModel.fromJson(response['data']);
        final index = _groceryItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _groceryItems[index] = updatedItem;
        }
        _isLoading = false;
        notifyListeners();

        if (kDebugMode) {
          print('✅ Item updated successfully');
        }
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error updating item: $e');
      }
      return false;
    }
    */
  }

  /// Delete grocery item
  Future<bool> deleteGroceryItem(String itemId) async {
    // ========================================
    // TEMPORARY MOCK FOR DEMO - REMOVE LATER
    // ========================================
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 300)); // Simulate API call

    final itemToDelete = _groceryItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => _groceryItems.first, // Fallback
    );

    _groceryItems.removeWhere((i) => i.id == itemId);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();

    if (kDebugMode) {
      print('✅ Mock item deleted:  ${itemToDelete.name}');
    }

    return true;
    // ========================================
    // END MOCK - ORIGINAL CODE BELOW
    // ========================================

    /* COMMENT OUT FOR DEMO
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete(
        ApiConfig.groceryById(itemId),
      );

      if (response['success'] == true) {
        _groceryItems.removeWhere((i) => i.id == itemId);
        _isLoading = false;
        notifyListeners();

        if (kDebugMode) {
          print('✅ Item deleted successfully');
        }
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error deleting item: $e');
      }
      return false;
    }
    */
  }

  /// Get items expiring soon (within 7 days)
  List<GroceryItemModel> getExpiringSoonItems() {
    final now = DateTime.now();
    return _groceryItems.where((item) {
      if (item.expiryDate == null) return false;
      final difference = item.expiryDate!.difference(now).inDays;
      return difference <= 7 && difference >= 0;
    }).toList();
  }

  /// Get expired items
  List<GroceryItemModel> getExpiredItems() {
    final now = DateTime.now();
    return _groceryItems.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.isBefore(now);
    }).toList();
  }

  /// Search grocery items
  List<GroceryItemModel> searchItems(String query) {
    if (query.isEmpty) return _groceryItems;

    final lowerQuery = query.toLowerCase();
    return _groceryItems.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          (item.categoryId?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter items by category
  List<GroceryItemModel> filterByCategory(String categoryId) {
    if (categoryId == 'All') return _groceryItems;
    return _groceryItems
        .where((item) => item.categoryId == categoryId)
        .toList();
  }

  /// Get item by ID
  GroceryItemModel? getItemById(String id) {
    try {
      return _groceryItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh groceries
  Future<void> refresh() async {
    await fetchGroceryItems();
  }
}
