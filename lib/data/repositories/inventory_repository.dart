// lib/data/repositories/inventory_repository.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/category_model.dart';

/// Repository managing inventory categories
/// Handles category CRUD operations
class InventoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to user's categories collection
  CollectionReference _categoryCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  /// Add new category
  ///
  /// Creates category with auto-generated ID
  Future<CategoryModel> addCategory({
    required String userId,
    required CategoryModel category,
  }) async {
    try {
      final docRef = _categoryCollection(userId).doc();

      final newCategory = category.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
      );

      await docRef.set(newCategory.toJson());

      return newCategory;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  /// Get all categories for user
  ///
  /// Returns sorted list of categories
  Future<List<CategoryModel>> getCategories(String userId) async {
    try {
      final snapshot = await _categoryCollection(userId).orderBy('name').get();

      return snapshot.docs
          .map(
            (doc) => CategoryModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Stream of real-time category updates
  Stream<List<CategoryModel>> streamCategories(String userId) {
    return _categoryCollection(userId).orderBy('name').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map(
            (doc) => CategoryModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  /// Update existing category
  Future<void> updateCategory({
    required String userId,
    required CategoryModel category,
  }) async {
    try {
      await _categoryCollection(
        userId,
      ).doc(category.id).update(category.toJson());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete category
  ///
  /// WARNING: Should check if category has items before deleting
  Future<void> deleteCategory({
    required String userId,
    required String categoryId,
  }) async {
    try {
      await _categoryCollection(userId).doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category:  $e');
    }
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById({
    required String userId,
    required String categoryId,
  }) async {
    try {
      final doc = await _categoryCollection(userId).doc(categoryId).get();

      if (!doc.exists) {
        return null;
      }

      return CategoryModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  /// Initialize default categories for new users
  ///
  /// Creates standard categories:  Fruits, Vegetables, Dairy, etc.
  Future<void> initializeDefaultCategories(String userId) async {
    try {
      final defaultCategories = [
        CategoryModel(
          id: '',
          name: 'Fruits',
          icon: '🍎',
          color: const Color(0xFFFF6B6B),
          createdAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Vegetables',
          icon: '🥬',
          color: const Color(0xFF4ECDC4),
          createdAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Dairy',
          icon: '🥛',
          color: const Color(0xFFFFE66D),
          createdAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Meat & Seafood',
          icon: '🍖',
          color: const Color(0xFFFF6B9D),
          createdAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Bakery',
          icon: '🍞',
          color: const Color(0xFFC9A0DC),
          createdAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Beverages',
          icon: '🥤',
          color: const Color(0xFF95E1D3),
          createdAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Snacks',
          icon: '🍿',
          color: const Color(0xFFFFA07A),
          createdAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Others',
          icon: '📦',
          color: const Color(0xFF9B9B9B),
          createdAt: DateTime.now(),
        ),
      ];

      // Batch write for efficiency
      final batch = _firestore.batch();

      for (final category in defaultCategories) {
        final docRef = _categoryCollection(userId).doc();
        final newCategory = category.copyWith(id: docRef.id);
        batch.set(docRef, newCategory.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to initialize categories:  $e');
    }
  }
}
