/// 👤 User Entity
/// Represents a user in the Smart Grocery Management System
/// Used for authentication and profile management
library;

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String role; // 'user' or 'admin'
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.role = 'user',
    required this.createdAt,
    this.updatedAt,
  });

  /// 🔄 CopyWith method for immutability
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 📋 Convert to Map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 📥 Create from Map (for deserialization)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      role: map['role'] ?? 'user',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name:  $name, email: $email, role: $role)';
  }
}
