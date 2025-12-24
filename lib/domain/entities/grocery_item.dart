/// 🛒 Grocery Item Entity
/// Represents a grocery item in the shopping list
/// Core entity for grocery management features
library;

class GroceryItem {
  final String id;
  final String userId; // Owner of the item
  final String name;
  final String category;
  final int quantity;
  final String unit; // 'kg', 'liters', 'pieces', etc.
  final DateTime? expiryDate;
  final String? notes;
  final bool isPurchased;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GroceryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.quantity,
    this.unit = 'pieces',
    this.expiryDate,
    this.notes,
    this.isPurchased = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// 🔄 CopyWith method for immutability
  GroceryItem copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    DateTime? expiryDate,
    String? notes,
    bool? isPurchased,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ⏰ Check if item is expiring soon (within 3 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 3;
  }

  /// 🚫 Check if item is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// Alias for toMap to support JSON serialization
  Map<String, dynamic> toJson() {
    return toMap();
  }

  /// 📋 Convert to Map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'isPurchased': isPurchased,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Alias for fromMap to support JSON deserialization
  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem.fromMap(json);
  }

  /// 📥 Create from Map (for deserialization)
  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Other',
      quantity: map['quantity'] ?? 1,
      unit: map['unit'] ?? 'pieces',
      expiryDate:
          map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      notes: map['notes'],
      isPurchased: map['isPurchased'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  @override
  String toString() {
    return 'GroceryItem(id:  $id, name: $name, quantity: $quantity, category: $category)';
  }
}
