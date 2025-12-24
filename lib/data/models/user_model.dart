// user_model. dart - Data model for User entity
// Represents both Customer and Store Owner roles

/// UserRole enum to distinguish between Customer and StoreOwner
enum UserRole { customer, storeOwner }

/// UserModel represents a user in the system
/// Supports both Customer and Store Owner roles as per requirements
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final UserRole role;
  final String? profileImageUrl;
  final String? storeId; // Only for store owners
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    this.profileImageUrl,
    this.storeId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if user is a customer
  bool get isCustomer => role == UserRole.customer;

  /// Check if user is a store owner
  bool get isStoreOwner => role == UserRole.storeOwner;

  /// Create UserModel from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      role: json['role'] == 'storeOwner'
          ? UserRole.storeOwner
          : UserRole.customer,
      profileImageUrl: json['profileImageUrl'],
      storeId: json['storeId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convert UserModel to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role == UserRole.storeOwner ? 'storeOwner' : 'customer',
      'profileImageUrl': profileImageUrl,
      'storeId': storeId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    UserRole? role,
    String? profileImageUrl,
    String? storeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }
}
