// lib/domain/usecases/grocery_usecases.dart

import '../entities/grocery_item.dart';
import '../repositories/grocery_repository.dart';

/// UseCase: Get All Grocery Items
class GetGroceryItemsUseCase {
  final GroceryRepository repository;

  GetGroceryItemsUseCase(this.repository);

  Future<List<GroceryItem>> call() async {
    return await repository.getGroceryItems();
  }
}

/// UseCase: Add Grocery Item
class AddGroceryItemUseCase {
  final GroceryRepository repository;

  AddGroceryItemUseCase(this.repository);

  Future<void> call(GroceryItem item) async {
    // Validate item
    if (item.name.isEmpty) {
      throw Exception('Item name cannot be empty');
    }

    if (item.quantity <= 0) {
      throw Exception('Quantity must be greater than zero');
    }

    return await repository.addGroceryItem(item);
  }
}

/// UseCase: Update Grocery Item
class UpdateGroceryItemUseCase {
  final GroceryRepository repository;

  UpdateGroceryItemUseCase(this.repository);

  Future<void> call(GroceryItem item) async {
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

    return await repository.updateGroceryItem(item);
  }
}

/// UseCase: Delete Grocery Item
class DeleteGroceryItemUseCase {
  final GroceryRepository repository;

  DeleteGroceryItemUseCase(this.repository);

  Future<void> call(String itemId) async {
    if (itemId.isEmpty) {
      throw Exception('Item ID cannot be empty');
    }

    return await repository.deleteGroceryItem(itemId);
  }
}

/// UseCase: Search Grocery Items
class SearchGroceryItemsUseCase {
  final GroceryRepository repository;

  SearchGroceryItemsUseCase(this.repository);

  Future<List<GroceryItem>> call(String query) async {
    if (query.isEmpty) {
      return await repository.getGroceryItems();
    }

    return await repository.searchGroceryItems(query);
  }
}

/// UseCase: Filter Items by Category
class FilterItemsByCategoryUseCase {
  final GroceryRepository repository;

  FilterItemsByCategoryUseCase(this.repository);

  Future<List<GroceryItem>> call(String category) async {
    if (category.isEmpty) {
      return await repository.getGroceryItems();
    }

    return await repository.filterByCategory(category);
  }
}

/// UseCase: Get Items Expiring Soon
class GetExpiringItemsUseCase {
  final GroceryRepository repository;

  GetExpiringItemsUseCase(this.repository);

  Future<List<GroceryItem>> call({int daysThreshold = 7}) async {
    return await repository.getExpiringItems(daysThreshold);
  }
}
