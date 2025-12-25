// lib/domain/usecases/grocery_usecases.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_grocery_tracker/data/models/grocery_item_model.dart';

import '../entities/grocery_item.dart';
import '../../data/repositories/grocery_repository.dart';

/// UseCase: Get All Grocery Items
class GetGroceryItemsUseCase {
  final GroceryRepository repository;

  GetGroceryItemsUseCase(this.repository);

  Future<List<GroceryItemModel>> call(String id) async {
    return await repository.getGroceryItems(id);
  }
}

/// UseCase: Add Grocery Item
class AddGroceryItemUseCase {
  final GroceryRepository repository;

  AddGroceryItemUseCase(this.repository);

  Future<void> call(String userId, GroceryItemModel item) async {
    // Validate item
    if (item.name.isEmpty) {
      throw Exception('Item name cannot be empty');
    }

    if (item.quantity <= 0) {
      throw Exception('Quantity must be greater than zero');
    }

    await repository.addGroceryItem(userId: userId, item: item);
  }
}

/// UseCase: Update Grocery Item
class UpdateGroceryItemUseCase {
  final GroceryRepository repository;

  UpdateGroceryItemUseCase(this.repository);

  Future<void> call(String userId, GroceryItemModel item) async {
    // Validate item
    if (item.id.isEmpty) {
      throw Exception('Item ID cannot be empty');
    }

    if (item.name.isEmpty) {
      throw Exception('Item name cannot be empty');
    }

    if (item.quantity < 0) {
      throw Exception('Quantity cannot be negative');
    }

    await repository.updateGroceryItem(userId: userId, item: item);
  }
}

/// UseCase: Delete Grocery Item
class DeleteGroceryItemUseCase {
  final GroceryRepository repository;

  DeleteGroceryItemUseCase(this.repository);

  Future<void> call(String userId, String itemId) async {
    if (itemId.isEmpty) {
      throw Exception('Item ID cannot be empty');
    }

    return await repository.deleteGroceryItem(userId: userId, itemId: itemId);
  }
}

/// UseCase: Search Grocery Items
class SearchGroceryItemsUseCase {
  final GroceryRepository repository;

  SearchGroceryItemsUseCase(this.repository);

  Future<List<GroceryItemModel>> call(String userId, String query) async {
    if (query.isEmpty) {
      return await repository.getGroceryItems(userId);
    }

    return await repository.searchItems(userId: userId, query: query);
  }
}

/// UseCase: Filter Items by Category
class FilterItemsByCategoryUseCase {
  final GroceryRepository repository;

  FilterItemsByCategoryUseCase(this.repository);

  Future<List<GroceryItemModel>> call(String userId, String category) async {
    if (category.isEmpty) {
      return await repository.getGroceryItems(userId);
    }

    return await repository.getItemsByCategory(
        userId: userId, categoryId: category);
  }
}

/// UseCase: Get Items Expiring Soon
class GetExpiringItemsUseCase {
  final GroceryRepository repository;

  GetExpiringItemsUseCase(this.repository);

  Future<List<GroceryItemModel>> call(
      {required String userId, int daysThreshold = 7}) async {
    return await repository.getExpiringItems(
        userId: userId, daysAhead: daysThreshold);
  }
}
