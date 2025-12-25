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

  /// Fetch all grocery items
  Future<void> fetchGroceryItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConfig.groceries);

      if (response['success'] == true) {
        final List<dynamic> data = response['data']['groceries'];
        _groceryItems =
            data.map((json) => GroceryItemModel.fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new grocery item
  Future<bool> addGroceryItem(GroceryItemModel item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConfig.groceries,
        body: item.toJson(),
      );

      if (response['success'] == true) {
        final newItem = GroceryItemModel.fromJson(response['data']);
        _groceryItems.add(newItem);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update grocery item
  Future<bool> updateGroceryItem(GroceryItemModel item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        ApiConfig.groceryById(item.id),
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
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<GroceryItemModel> getExpiringSoonItems() {
    final now = DateTime.now();
    return _groceryItems.where((item) {
      if (item.expiryDate == null) return false;
      final difference = item.expiryDate!.difference(now).inDays;
      return difference <= 3 && difference >= 0;
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

  /// Delete grocery item
  Future<bool> deleteGroceryItem(String itemId) async {
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
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
