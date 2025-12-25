import 'package:flutter/foundation.dart';

/// Enum representing the storage location of an inventory item
enum StorageLocation { refrigerator, freezer, pantry, cabinet, counter, other }

/// Enum representing the status of an inventory item
enum InventoryStatus { inStock, lowStock, outOfStock, expired, expiringSoon }

/// Extension to get display names for StorageLocation
extension StorageLocationExtension on StorageLocation {
  String get displayName {
    switch (this) {
      case StorageLocation.refrigerator:
        return 'Refrigerator';
      case StorageLocation.freezer:
        return 'Freezer';
      case StorageLocation.pantry:
        return 'Pantry';
      case StorageLocation.cabinet:
        return 'Cabinet';
      case StorageLocation.counter:
        return 'Counter';
      case StorageLocation.other:
        return 'Other';
    }
  }

  /// Get icon name for the storage location
  String get iconName {
    switch (this) {
      case StorageLocation.refrigerator:
        return 'kitchen';
      case StorageLocation.freezer:
        return 'ac_unit';
      case StorageLocation.pantry:
        return 'shelves';
      case StorageLocation.cabinet:
        return 'door_sliding';
      case StorageLocation.counter:
        return 'countertops';
      case StorageLocation.other:
        return 'inventory_2';
    }
  }
}

/// Extension to get display names and colors for InventoryStatus
extension InventoryStatusExtension on InventoryStatus {
  String get displayName {
    switch (this) {
      case InventoryStatus.inStock:
        return 'In Stock';
      case InventoryStatus.lowStock:
        return 'Low Stock';
      case InventoryStatus.outOfStock:
        return 'Out of Stock';
      case InventoryStatus.expired:
        return 'Expired';
      case InventoryStatus.expiringSoon:
        return 'Expiring Soon';
    }
  }

  /// Get color code for status (hex string)
  String get colorCode {
    switch (this) {
      case InventoryStatus.inStock:
        return '#4CAF50'; // Green
      case InventoryStatus.lowStock:
        return '#FF9800'; // Orange
      case InventoryStatus.outOfStock:
        return '#F44336'; // Red
      case InventoryStatus.expired:
        return '#9E9E9E'; // Grey
      case InventoryStatus.expiringSoon:
        return '#FFC107'; // Amber
    }
  }
}

/// Model class representing an item in the user's inventory/pantry
///
/// This model tracks items that the user currently has at home,
/// including quantity tracking, expiry management, and consumption patterns
@immutable
class InventoryItemModel {
  /// Unique identifier for the inventory item
  final String id;

  /// Name of the inventory item
  final String name;

  /// Description or notes about the item
  final String? description;

  /// Current quantity available
  final double currentQuantity;

  /// Minimum quantity threshold for low stock alert
  final double minimumQuantity;

  /// Maximum/full stock quantity
  final double? maximumQuantity;

  /// Unit of measurement (same as GroceryUnit)
  final String unit;

  /// Category ID this item belongs to
  final String categoryId;

  /// Category name for display purposes
  final String? categoryName;

  /// Storage location of the item
  final StorageLocation storageLocation;

  /// Creation date of the item
  final DateTime createdAt;

  /// Expiry date of the item
  final DateTime? expiryDate;

  /// Date when the item was added to inventory
  final DateTime dateAdded;

  /// Date when the item was last updated
  final DateTime lastUpdated;

  /// Date of last consumption/usage
  final DateTime? lastConsumedDate;

  /// Purchase price of the item
  final double? purchasePrice;

  /// Brand of the item
  final String? brand;

  /// URL or path to the item's image
  final String? imageUrl;

  /// Barcode of the item
  final String? barcode;

  /// User ID who owns this inventory item
  final String userId;

  /// Whether to auto-add to shopping list when low
  final bool autoAddToShoppingList;

  /// Average consumption rate per day
  final double? averageConsumptionPerDay;

  /// Notes about the item
  final String? notes;

  /// Tags for easy filtering
  final List<String> tags;

  /// Constructor for InventoryItemModel
  const InventoryItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.currentQuantity,
    this.minimumQuantity = 1,
    this.maximumQuantity,
    required this.unit,
    required this.categoryId,
    this.categoryName,
    this.storageLocation = StorageLocation.pantry,
    required this.createdAt,
    this.expiryDate,
    required this.dateAdded,
    required this.lastUpdated,
    this.lastConsumedDate,
    this.purchasePrice,
    this.brand,
    this.imageUrl,
    this.barcode,
    required this.userId,
    this.autoAddToShoppingList = true,
    this.averageConsumptionPerDay,
    this.notes,
    this.tags = const [],
  });

  /// Calculate the current status of the inventory item
  InventoryStatus get status {
    // Check expiry first
    if (isExpired) return InventoryStatus.expired;
    if (isExpiringSoon) return InventoryStatus.expiringSoon;

    // Check quantity
    if (currentQuantity <= 0) return InventoryStatus.outOfStock;
    if (currentQuantity <= minimumQuantity) return InventoryStatus.lowStock;

    return InventoryStatus.inStock;
  }

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

  /// Check if stock is low
  bool get isLowStock =>
      currentQuantity <= minimumQuantity && currentQuantity > 0;

  /// Check if out of stock
  bool get isOutOfStock => currentQuantity <= 0;

  /// Get stock percentage (0-100)
  double get stockPercentage {
    if (maximumQuantity == null || maximumQuantity == 0) {
      // If no max set, use minimum as reference
      if (currentQuantity >= minimumQuantity * 3) return 100;
      return (currentQuantity / (minimumQuantity * 3)) * 100;
    }
    return (currentQuantity / maximumQuantity!) * 100;
  }

  /// Estimated days until empty based on consumption rate
  int? get estimatedDaysUntilEmpty {
    if (averageConsumptionPerDay == null || averageConsumptionPerDay == 0) {
      return null;
    }
    return (currentQuantity / averageConsumptionPerDay!).ceil();
  }

  /// Get formatted quantity with unit
  String get formattedQuantity {
    if (currentQuantity == currentQuantity.roundToDouble()) {
      return '${currentQuantity.toInt()} $unit';
    }
    return '${currentQuantity.toStringAsFixed(1)} $unit';
  }

  /// Create a copy of the model with updated fields
  InventoryItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? currentQuantity,
    double? minimumQuantity,
    double? maximumQuantity,
    String? unit,
    String? categoryId,
    String? categoryName,
    StorageLocation? storageLocation,
    DateTime? expiryDate,
    DateTime? dateAdded,
    DateTime? lastUpdated,
    DateTime? lastConsumedDate,
    double? purchasePrice,
    String? brand,
    String? imageUrl,
    String? barcode,
    String? userId,
    bool? autoAddToShoppingList,
    double? averageConsumptionPerDay,
    String? notes,
    List<String>? tags,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      maximumQuantity: maximumQuantity ?? this.maximumQuantity,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      storageLocation: storageLocation ?? this.storageLocation,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastConsumedDate: lastConsumedDate ?? this.lastConsumedDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      userId: userId ?? this.userId,
      autoAddToShoppingList:
          autoAddToShoppingList ?? this.autoAddToShoppingList,
      averageConsumptionPerDay:
          averageConsumptionPerDay ?? this.averageConsumptionPerDay,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  /// Convert model to JSON map for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'currentQuantity': currentQuantity,
      'minimumQuantity': minimumQuantity,
      'maximumQuantity': maximumQuantity,
      'unit': unit,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'storageLocation': storageLocation.name,
      'expiryDate': expiryDate?.toIso8601String(),
      'dateAdded': dateAdded.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'lastConsumedDate': lastConsumedDate?.toIso8601String(),
      'purchasePrice': purchasePrice,
      'brand': brand,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'userId': userId,
      'autoAddToShoppingList': autoAddToShoppingList,
      'averageConsumptionPerDay': averageConsumptionPerDay,
      'notes': notes,
      'tags': tags,
    };
  }

  /// Create model from JSON map (API response)
  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      currentQuantity: (json['currentQuantity'] as num).toDouble(),
      minimumQuantity: (json['minimumQuantity'] as num?)?.toDouble() ?? 1,
      maximumQuantity: (json['maximumQuantity'] as num?)?.toDouble(),
      unit: json['unit'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String?,
      storageLocation: StorageLocation.values.firstWhere(
        (e) => e.name == json['storageLocation'],
        orElse: () => StorageLocation.pantry,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      lastConsumedDate: json['lastConsumedDate'] != null
          ? DateTime.parse(json['lastConsumedDate'] as String)
          : null,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      brand: json['brand'] as String?,
      imageUrl: json['imageUrl'] as String?,
      barcode: json['barcode'] as String?,
      userId: json['userId'] as String,
      autoAddToShoppingList: json['autoAddToShoppingList'] as bool? ?? true,
      averageConsumptionPerDay:
          (json['averageConsumptionPerDay'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Create an empty inventory item with default values
  factory InventoryItemModel.empty({required String userId}) {
    final now = DateTime.now();
    return InventoryItemModel(
      id: '',
      name: '',
      currentQuantity: 0,
      unit: 'pieces',
      categoryId: '',
      userId: userId,
      createdAt: now,
      dateAdded: now,
      lastUpdated: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'InventoryItemModel(id:  $id, name:  $name, quantity: $formattedQuantity, '
        'status: ${status.displayName}, location: ${storageLocation.displayName})';
  }
}
