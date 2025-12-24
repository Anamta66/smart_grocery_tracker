// lib/domain/usecases/inventory_usecases.dart

import '../entities/grocery_item.dart';
import '../repositories/grocery_repository.dart';

/// UseCase: Get Inventory Summary
class GetInventorySummaryUseCase {
  final GroceryRepository repository;

  GetInventorySummaryUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    final items = await repository.getGroceryItems();

    int totalItems = items.length;
    int totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);
    int lowStockItems = items.where((item) => item.quantity < 5).length;
    int expiringSoon = items.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.difference(DateTime.now()).inDays <= 7;
    }).length;

    return {
      'totalItems': totalItems,
      'totalQuantity': totalQuantity,
      'lowStockItems': lowStockItems,
      'expiringSoon': expiringSoon,
    };
  }
}

/// UseCase: Get Low Stock Items
class GetLowStockItemsUseCase {
  final GroceryRepository repository;

  GetLowStockItemsUseCase(this.repository);

  Future<List<GroceryItem>> call({int threshold = 5}) async {
    final items = await repository.getGroceryItems();
    return items.where((item) => item.quantity < threshold).toList();
  }
}

/// UseCase: Update Stock Quantity
class UpdateStockQuantityUseCase {
  final GroceryRepository repository;

  UpdateStockQuantityUseCase(this.repository);

  Future<void> call(String itemId, int newQuantity) async {
    if (itemId.isEmpty) {
      throw Exception('Item ID cannot be empty');
    }

    if (newQuantity < 0) {
      throw Exception('Quantity cannot be negative');
    }

    // Get item first
    final items = await repository.getGroceryItems();
    final item = items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    // Update quantity
    final updatedItem = item.copyWith(quantity: newQuantity);
    return await repository.updateGroceryItem(updatedItem);
  }
}

/// UseCase: Track Item Usage
class TrackItemUsageUseCase {
  final GroceryRepository repository;

  TrackItemUsageUseCase(this.repository);

  Future<void> call(String itemId, int usedQuantity) async {
    if (itemId.isEmpty) {
      throw Exception('Item ID cannot be empty');
    }

    if (usedQuantity <= 0) {
      throw Exception('Used quantity must be greater than zero');
    }

    // Get item
    final items = await repository.getGroceryItems();
    final item = items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    // Calculate new quantity
    int newQuantity = item.quantity - usedQuantity;
    if (newQuantity < 0) {
      throw Exception('Insufficient quantity');
    }

    // Update item
    final updatedItem = item.copyWith(quantity: newQuantity);
    return await repository.updateGroceryItem(updatedItem);
  }
}

/// UseCase:  Restock Item
class RestockItemUseCase {
  final GroceryRepository repository;

  RestockItemUseCase(this.repository);

  Future<void> call(String itemId, int addQuantity) async {
    if (itemId.isEmpty) {
      throw Exception('Item ID cannot be empty');
    }

    if (addQuantity <= 0) {
      throw Exception('Add quantity must be greater than zero');
    }

    // Get item
    final items = await repository.getGroceryItems();
    final item = items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    // Calculate new quantity
    int newQuantity = item.quantity + addQuantity;

    // Update item
    final updatedItem = item.copyWith(quantity: newQuantity);
    return await repository.updateGroceryItem(updatedItem);
  }
}

/// UseCase: Get Items by Expiry Date Range
class GetItemsByExpiryRangeUseCase {
  final GroceryRepository repository;

  GetItemsByExpiryRangeUseCase(this.repository);

  Future<List<GroceryItem>> call(DateTime start, DateTime end) async {
    final items = await repository.getGroceryItems();
    return items.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.isAfter(start) && item.expiryDate!.isBefore(end);
    }).toList();
  }
}

/// UseCase: Auto-Suggest Restock
class AutoSuggestRestockUseCase {
  final GroceryRepository repository;

  AutoSuggestRestockUseCase(this.repository);

  Future<List<GroceryItem>> call() async {
    final items = await repository.getGroceryItems();

    // Suggest items with quantity < 5 or items used frequently
    return items.where((item) => item.quantity < 5).toList();
  }
}
