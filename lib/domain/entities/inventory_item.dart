/// 📦 Inventory Item Entity
/// Represents items currently in inventory/pantry
/// Used for tracking stock and expiry management
library;

class InventoryItem {
  final String id;
  final String userId;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String? location; // 'Fridge', 'Pantry', 'Freezer'
  final String? notes;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String barcode;
  final int? lowStockThreshold;
  final double? price;
  final DateTime? lastUpdated;

  InventoryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.quantity,
    this.unit = 'pieces',
    this.purchaseDate,
    this.expiryDate,
    this.location,
    this.notes,
    this.description,
    required this.createdAt,
    this.updatedAt,
    required this.barcode,
    this.lowStockThreshold,
    this.price,
    this.lastUpdated,
  });

  /// 🔄 CopyWith method
  InventoryItem copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? location,
    String? notes,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? barcode,
    int? lowStockThreshold,
    double? price,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      barcode: barcode ?? this.barcode,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      price: price ?? this.price,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// ⏰ Check if item is expiring soon
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 7;
  }

  /// 🚫 Check if item is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// 📊 Get days until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// 📋 Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'location': location,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'barcode': barcode,
      'lowStockThreshold': lowStockThreshold,
      'price': price,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// 📥 Create from Map
  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Other',
      quantity: map['quantity'] ?? 1,
      unit: map['unit'] ?? 'pieces',
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.parse(map['purchaseDate'])
          : null,
      expiryDate:
          map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      location: map['location'],
      notes: map['notes'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      barcode: map['barcode'],
      lowStockThreshold: map['lowStockThreshold'],
      price: map['price'] != null
          ? double.tryParse(map['price'].toString())
          : null,
    );
  }

  @override
  String toString() {
    return 'InventoryItem(id: $id, name: $name, quantity: $quantity, location: $location)';
  }
}
