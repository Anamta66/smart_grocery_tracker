/// 🔔 Notification Entity
/// Represents system notifications for expiry alerts, reminders, etc.
library;

enum NotificationType { expiryAlert, lowStock, reminder, info }

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedItemId; // ID of related grocery/inventory item

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.relatedItemId,
  });

  /// 🔄 CopyWith method
  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    String? relatedItemId,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      relatedItemId: relatedItemId ?? this.relatedItemId,
    );
  }

  /// 📋 Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'relatedItemId': relatedItemId,
    };
  }

  /// 📥 Create from Map
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: _typeFromString(map['type'] ?? 'info'),
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      relatedItemId: map['relatedItemId'],
    );
  }

  /// 🔧 Helper to convert string to NotificationType
  static NotificationType _typeFromString(String type) {
    switch (type) {
      case 'expiryAlert':
        return NotificationType.expiryAlert;
      case 'lowStock':
        return NotificationType.lowStock;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.info;
    }
  }

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, type: $type, isRead: $isRead)';
  }
}
