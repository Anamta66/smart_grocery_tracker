// lib/data/repositories/grocery_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/grocery_item_model.dart';

/// Repository for grocery item CRUD operations
/// Handles all database interactions for grocery management
class GroceryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to user's grocery collection
  CollectionReference _groceryCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('groceries');
  }

  /// Add new grocery item to database
  ///
  /// Auto-generates unique ID and sets createdAt timestamp
  ///
  /// Returns created [GroceryItemModel]
  Future<GroceryItemModel> addGroceryItem({
    required String userId,
    required GroceryItemModel item,
  }) async {
    try {
      // Create document reference with auto-generated ID
      final docRef = _groceryCollection(userId).doc();

      // Create item with generated ID
      final newItem = item.copyWith(id: docRef.id, createdAt: DateTime.now());

      // Save to Firestore
      await docRef.set(newItem.toJson());

      return newItem;
    } catch (e) {
      throw Exception('Failed to add grocery item: $e');
    }
  }

  /// Get all grocery items for a user
  ///
  /// Returns list of [GroceryItemModel] sorted by creation date
  Future<List<GroceryItemModel>> getGroceryItems(String userId) async {
    try {
      final snapshot = await _groceryCollection(
        userId,
      ).orderBy('createdAt', descending: true).get();

      return snapshot.docs
          .map(
            (doc) =>
                GroceryItemModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch grocery items: $e');
    }
  }

  /// Stream of real-time grocery updates
  ///
  /// Automatically updates UI when data changes
  Stream<List<GroceryItemModel>> streamGroceryItems(String userId) {
    return _groceryCollection(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                GroceryItemModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  /// Update existing grocery item
  ///
  /// Merges new data with existing document
  Future<void> updateGroceryItem({
    required String userId,
    required GroceryItemModel item,
  }) async {
    try {
      await _groceryCollection(userId).doc(item.id).update(item.toJson());
    } catch (e) {
      throw Exception('Failed to update grocery item: $e');
    }
  }

  /// Delete grocery item from database
  Future<void> deleteGroceryItem({
    required String userId,
    required String itemId,
  }) async {
    try {
      await _groceryCollection(userId).doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete grocery item: $e');
    }
  }

  /// Get grocery items by category
  ///
  /// Filters items belonging to specific category
  Future<List<GroceryItemModel>> getItemsByCategory({
    required String userId,
    required String categoryId,
  }) async {
    try {
      final snapshot = await _groceryCollection(userId)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                GroceryItemModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items by category: $e');
    }
  }

  /// Get expiring items (within next N days)
  ///
  /// Returns items expiring in specified number of days
  Future<List<GroceryItemModel>> getExpiringItems({
    required String userId,
    int daysAhead = 7,
  }) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));

      final snapshot = await _groceryCollection(userId)
          .where('expiryDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .where(
            'expiryDate',
            isLessThanOrEqualTo: futureDate.toIso8601String(),
          )
          .orderBy('expiryDate')
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                GroceryItemModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch expiring items: $e');
    }
  }

  /// Search grocery items by name
  ///
  /// Case-insensitive search in item names
  Future<List<GroceryItemModel>> searchItems({
    required String userId,
    required String query,
  }) async {
    try {
      final snapshot = await _groceryCollection(userId).get();

      // Client-side filtering (Firestore doesn't support full-text search)
      final items = snapshot.docs
          .map(
            (doc) =>
                GroceryItemModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .where(
            (item) => item.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      return items;
    } catch (e) {
      throw Exception('Failed to search items: $e');
    }
  }

  /// Get low stock items (quantity below threshold)
  ///
  /// Returns items where current quantity < minimum quantity
  Future<List<GroceryItemModel>> getLowStockItems(String userId) async {
    try {
      final snapshot = await _groceryCollection(userId).get();

      // Filter items with low stock
      final items = snapshot.docs
          .map(
            (doc) =>
                GroceryItemModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .where((item) => item.quantity < item.minQuantity)
          .toList();

      return items;
    } catch (e) {
      throw Exception('Failed to fetch low stock items: $e');
    }
  }

  /// Batch delete multiple items
  ///
  /// Useful for clearing expired items
  Future<void> deleteMultipleItems({
    required String userId,
    required List<String> itemIds,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final itemId in itemIds) {
        batch.delete(_groceryCollection(userId).doc(itemId));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete multiple items:  $e');
    }
  }
}
