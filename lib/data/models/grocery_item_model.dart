import 'package:flutter/foundation.dart';

/// Enum representing the priority level of a grocery item
enum GroceryPriority { low, medium, high, urgent }

/// Enum representing the unit of measurement for grocery items
enum GroceryUnit {
  pieces,
  kg,
  grams,
  liters,
  ml,
  dozen,
  pack,
  bottle,
  can,
  box,
}

/// Extension to get display names for GroceryPriority
extension GroceryPriorityExtension on GroceryPriority {
  String get displayName {
    switch (this) {
      case GroceryPriority.low:
        return 'Low';
      case GroceryPriority.medium:
        return 'Medium';
      case GroceryPriority.high:
        return 'High';
      case GroceryPriority.urgent:
        return 'Urgent';
    }
  }

  /// Get color code for priority (hex string)
  String get colorCode {
    switch (this) {
      case GroceryPriority.low:
        return '#4CAF50'; // Green
      case GroceryPriority.medium:
        return '#FF9800'; // Orange
      case GroceryPriority.high:
        return '#F44336'; // Red
      case GroceryPriority.urgent:
        return '#9C27B0'; // Purple
    }
  }
}

/// Extension to get display names for GroceryUnit
extension GroceryUnitExtension on GroceryUnit {
  String get displayName {
    switch (this) {
      case GroceryUnit.pieces:
        return 'Pieces';
      case GroceryUnit.kg:
        return 'Kg';
      case GroceryUnit.grams:
        return 'Grams';
      case GroceryUnit.liters:
        return 'Liters';
      case GroceryUnit.ml:
        return 'mL';
      case GroceryUnit.dozen:
        return 'Dozen';
      case GroceryUnit.pack:
        return 'Pack';
      case GroceryUnit.bottle:
        return 'Bottle';
      case GroceryUnit.can:
        return 'Can';
      case GroceryUnit.box:
        return 'Box';
    }
  }

  String get abbreviation {
    switch (this) {
      case GroceryUnit.pieces:
        return 'pcs';
      case GroceryUnit.kg:
        return 'kg';
      case GroceryUnit.grams:
        return 'g';
      case GroceryUnit.liters:
        return 'L';
      case GroceryUnit.ml:
        return 'ml';
      case GroceryUnit.dozen:
        return 'dz';
      case GroceryUnit.pack:
        return 'pk';
      case GroceryUnit.bottle:
        return 'btl';
      case GroceryUnit.can:
        return 'can';
      case GroceryUnit.box:
        return 'box';
    }
  }
}

/// Model class representing a grocery item in the shopping list
///
/// This model handles all grocery item data including:
/// - Basic item information (name, quantity, unit)
/// - Category association
/// - Expiry tracking
/// - Purchase status
/// - Price information
@immutable
class GroceryItemModel {
  /// Unique identifier for the grocery item
  final String id;

  /// Name of the grocery item
  final String name;

  /// Description or notes about the item
  final String? description;

  /// Quantity of the item needed
  final double quantity;

  /// Unit of measurement
  final GroceryUnit unit;

  /// Category ID this item belongs to
  final String categoryId;

  /// Category name for display purposes
  final String? categoryName;

  /// Priority level of the item
  final GroceryPriority priority;

  /// Whether the item has been purchased
  final bool isPurchased;

  /// Date when the item was purchased
  final DateTime? purchaseDate;

  /// Expiry date of the item (if applicable)
  final DateTime? expiryDate;

  /// Estimated price of the item
  final double? estimatedPrice;

  /// Actual price paid for the item
  final double? actualPrice;

  /// Brand preference for the item
  final String? brand;

  /// Store where the item should be bought
  final String? preferredStore;

  /// URL or path to the item's image
  final String? imageUrl;

  /// Barcode of the item (for scanning feature)
  final String? barcode;

  /// User ID who created this item
  final String userId;

  /// Shopping list ID this item belongs to
  final String? shoppingListId;

  /// Date when the item was created
  final DateTime createdAt;

  /// Date when the item was last updated
  final DateTime updatedAt;

  /// Whether this item is a recurring/frequent purchase
  final bool isRecurring;

  /// Frequency of recurring purchase in days
  final int? recurringIntervalDays;

  /// Notes or special instructions for this item
  final String? notes;

  /// Constructor for GroceryItemModel
  const GroceryItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    this.unit = GroceryUnit.pieces,
    required this.categoryId,
    this.categoryName,
    this.priority = GroceryPriority.medium,
    this.isPurchased = false,
    this.purchaseDate,
    this.expiryDate,
    this.estimatedPrice,
    this.actualPrice,
    this.brand,
    this.preferredStore,
    this.imageUrl,
    this.barcode,
    required this.userId,
    this.shoppingListId,
    required this.createdAt,
    required this.updatedAt,
    this.isRecurring = false,
    this.recurringIntervalDays,
    this.notes,
  });

  /// Check if the item is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Check if the item is expiring soon (within 3 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 3;
  }

  /// Get days until expiry (negative if already expired)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Get formatted quantity with unit
  String get formattedQuantity {
    if (quantity == quantity.roundToDouble()) {
      return '${quantity.toInt()} ${unit.abbreviation}';
    }
    return '${quantity.toStringAsFixed(1)} ${unit.abbreviation}';
  }

  /// Get formatted price
  String? get formattedEstimatedPrice {
    if (estimatedPrice == null) return null;
    return '\$${estimatedPrice!.toStringAsFixed(2)}';
  }

  String? get formattedActualPrice {
    if (actualPrice == null) return null;
    return '\$${actualPrice!.toStringAsFixed(2)}';
  }

  /// Create a copy of the model with updated fields
  GroceryItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? quantity,
    GroceryUnit? unit,
    String? categoryId,
    String? categoryName,
    GroceryPriority? priority,
    bool? isPurchased,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? estimatedPrice,
    double? actualPrice,
    String? brand,
    String? preferredStore,
    String? imageUrl,
    String? barcode,
    String? userId,
    String? shoppingListId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    int? recurringIntervalDays,
    String? notes,
  }) {
    return GroceryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      priority: priority ?? this.priority,
      isPurchased: isPurchased ?? this.isPurchased,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      brand: brand ?? this.brand,
      preferredStore: preferredStore ?? this.preferredStore,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      userId: userId ?? this.userId,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringIntervalDays:
          recurringIntervalDays ?? this.recurringIntervalDays,
      notes: notes ?? this.notes,
    );
  }

  /// Convert model to JSON map for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit.name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'priority': priority.name,
      'isPurchased': isPurchased,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'estimatedPrice': estimatedPrice,
      'actualPrice': actualPrice,
      'brand': brand,
      'preferredStore': preferredStore,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'userId': userId,
      'shoppingListId': shoppingListId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringIntervalDays': recurringIntervalDays,
      'notes': notes,
    };
  }

  /// Create model from JSON map (API response)
  factory GroceryItemModel.fromJson(Map<String, dynamic> json) {
    return GroceryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: GroceryUnit.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => GroceryUnit.pieces,
      ),
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String?,
      priority: GroceryPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => GroceryPriority.medium,
      ),
      isPurchased: json['isPurchased'] as bool? ?? false,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      actualPrice: (json['actualPrice'] as num?)?.toDouble(),
      brand: json['brand'] as String?,
      preferredStore: json['preferredStore'] as String?,
      imageUrl: json['imageUrl'] as String?,
      barcode: json['barcode'] as String?,
      userId: json['userId'] as String,
      shoppingListId: json['shoppingListId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringIntervalDays: json['recurringIntervalDays'] as int?,
      notes: json['notes'] as String?,
    );
  }

  /// Create an empty grocery item with default values
  factory GroceryItemModel.empty({required String userId, String? categoryId}) {
    final now = DateTime.now();
    return GroceryItemModel(
      id: '',
      name: '',
      quantity: 1,
      unit: GroceryUnit.pieces,
      categoryId: categoryId ?? '',
      priority: GroceryPriority.medium,
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroceryItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GroceryItemModel(id: $id, name: $name, quantity: $formattedQuantity, '
        'category: $categoryName, priority: ${priority.displayName}, '
        'isPurchased: $isPurchased)';
  }
}
