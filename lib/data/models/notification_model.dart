import 'package:flutter/material.dart';

/// Enum for different notification types
enum NotificationType {
  expiryWarning, // Item about to expire
  expiryAlert, // Item expired
  lowStock, // Stock running low
  restock, // Reminder to restock
  categoryUpdate, // Category-related update
  system, // System notifications
  reminder, // Custom reminders
}

/// Enum for notification priority levels
enum NotificationPriority { low, medium, high, critical }

/// Enum for notification status
enum NotificationStatus { unread, read, archived, deleted }

/// Main Notification Model
/// Handles all types of notifications in the Smart Grocery System
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationStatus status;
  final DateTime timestamp;
  final DateTime? createdAt;
  final DateTime? expiryDate;
  final String? groceryItemId;
  final String? groceryItemName;
  final String? categoryId;
  final String? categoryName;
  final Map<String, dynamic>? metadata;
  final String? actionUrl;
  final bool isActionable;
  final DateTime? scheduledFor;
  final bool isRecurring;
  final String? recurrencePattern;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.medium,
    this.status = NotificationStatus.unread,
    required this.timestamp,
    this.createdAt,
    this.expiryDate,
    this.groceryItemId,
    this.groceryItemName,
    this.categoryId,
    this.categoryName,
    this.metadata,
    this.actionUrl,
    this.isActionable = false,
    this.scheduledFor,
    this.isRecurring = false,
    this.recurrencePattern,
    this.isRead = false,
  });

  // --------------------- Factory Constructors ---------------------

  /// Create notification from JSON (Firebase/API response)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: _parseNotificationType(json['type']),
      priority: _parseNotificationPriority(json['priority']),
      status: _parseNotificationStatus(json['status']),
      timestamp: _parseDateTime(json['timestamp']) ?? DateTime.now(),
      expiryDate: _parseDateTime(json['expiryDate']),
      groceryItemId: json['groceryItemId'],
      groceryItemName: json['groceryItemName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      actionUrl: json['actionUrl'],
      isActionable: json['isActionable'] ?? false,
      scheduledFor: _parseDateTime(json['scheduledFor']),
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern'],
      isRead: (json['status'] ?? '').toString().toLowerCase() == 'read',
    );
  }

  /// Factory constructor for expiry warning notifications
  factory NotificationModel.expiryWarning({
    required String id,
    required String userId,
    required String groceryItemName,
    required String groceryItemId,
    required DateTime expiryDate,
    required int daysUntilExpiry,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: '⚠️ Expiry Warning',
      message:
          '$groceryItemName will expire in $daysUntilExpiry ${daysUntilExpiry == 1 ? 'day' : 'days'}',
      type: NotificationType.expiryWarning,
      priority: daysUntilExpiry <= 2
          ? NotificationPriority.high
          : NotificationPriority.medium,
      timestamp: DateTime.now(),
      expiryDate: expiryDate,
      groceryItemId: groceryItemId,
      groceryItemName: groceryItemName,
      isActionable: true,
      actionUrl: '/grocery-details/$groceryItemId',
      metadata: {'daysUntilExpiry': daysUntilExpiry, 'action': 'view_item'},
    );
  }

  /// Factory constructor for expired item notifications
  factory NotificationModel.expiryAlert({
    required String id,
    required String userId,
    required String groceryItemName,
    required String groceryItemId,
    required DateTime expiryDate,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: '🚨 Item Expired',
      message: '$groceryItemName has expired. Please remove it.',
      type: NotificationType.expiryAlert,
      priority: NotificationPriority.critical,
      timestamp: DateTime.now(),
      expiryDate: expiryDate,
      groceryItemId: groceryItemId,
      groceryItemName: groceryItemName,
      isActionable: true,
      actionUrl: '/grocery-details/$groceryItemId',
      metadata: {
        'action': 'remove_item',
        'daysExpired': DateTime.now().difference(expiryDate).inDays,
      },
    );
  }

  /// Factory constructor for low stock notifications
  factory NotificationModel.lowStock({
    required String id,
    required String userId,
    required String groceryItemName,
    required String groceryItemId,
    required int currentQuantity,
    required int minQuantity,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: '📉 Low Stock Alert',
      message: '$groceryItemName is running low ($currentQuantity left)',
      type: NotificationType.lowStock,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now(),
      groceryItemId: groceryItemId,
      groceryItemName: groceryItemName,
      isActionable: true,
      actionUrl: '/grocery-details/$groceryItemId',
      metadata: {
        'currentQuantity': currentQuantity,
        'minQuantity': minQuantity,
        'action': 'restock_item',
      },
    );
  }

  /// Factory constructor for restock reminders
  factory NotificationModel.restockReminder({
    required String id,
    required String userId,
    required String groceryItemName,
    required String groceryItemId,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: '🛒 Restock Reminder',
      message: 'Don\'t forget to restock $groceryItemName',
      type: NotificationType.restock,
      priority: NotificationPriority.low,
      timestamp: DateTime.now(),
      groceryItemId: groceryItemId,
      groceryItemName: groceryItemName,
      isActionable: true,
      actionUrl: '/add-grocery',
      metadata: {'action': 'add_to_shopping_list'},
    );
  }

  // --------------------- Conversion Methods ---------------------

  /// Convert to JSON for Firebase/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'groceryItemId': groceryItemId,
      'groceryItemName': groceryItemName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'metadata': metadata,
      'actionUrl': actionUrl,
      'isActionable': isActionable,
      'scheduledFor': scheduledFor?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
    };
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp,
      'expiryDate': expiryDate,
      'groceryItemId': groceryItemId,
      'groceryItemName': groceryItemName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'metadata': metadata,
      'actionUrl': actionUrl,
      'isActionable': isActionable,
      'scheduledFor': scheduledFor,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
    };
  }

  // --------------------- Copy With Method ---------------------

  /// Create a copy with modified fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationStatus? status,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? expiryDate,
    String? groceryItemId,
    String? groceryItemName,
    String? categoryId,
    String? categoryName,
    Map<String, dynamic>? metadata,
    String? actionUrl,
    bool? isActionable,
    DateTime? scheduledFor,
    bool? isRecurring,
    String? recurrencePattern,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      groceryItemId: groceryItemId ?? this.groceryItemId,
      groceryItemName: groceryItemName ?? this.groceryItemName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      metadata: metadata ?? this.metadata,
      actionUrl: actionUrl ?? this.actionUrl,
      isActionable: isActionable ?? this.isActionable,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
    );
  }

  // --------------------- Helper Methods ---------------------

  /// Get notification icon based on type
  IconData getIcon() {
    switch (type) {
      case NotificationType.expiryWarning:
        return Icons.warning_amber_rounded;
      case NotificationType.expiryAlert:
        return Icons.error_outline_rounded;
      case NotificationType.lowStock:
        return Icons.inventory_2_outlined;
      case NotificationType.restock:
        return Icons.shopping_cart_outlined;
      case NotificationType.categoryUpdate:
        return Icons.category_outlined;
      case NotificationType.system:
        return Icons.info_outline_rounded;
      case NotificationType.reminder:
        return Icons.notifications_active_outlined;
    }
  }

  /// Get notification color based on priority
  Color getColor() {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.blue;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.high:
        return Colors.deepOrange;
      case NotificationPriority.critical:
        return Colors.red;
    }
  }

  /// Get formatted timestamp
  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Check if notification is recent (within 24 hours)
  bool isRecent() {
    return DateTime.now().difference(timestamp).inHours < 24;
  }

  /// Check if notification is urgent
  bool isUrgent() {
    return priority == NotificationPriority.critical ||
        priority == NotificationPriority.high;
  }

  /// Mark notification as read
  NotificationModel markAsRead() {
    return copyWith(status: NotificationStatus.read);
  }

  /// Mark notification as archived
  NotificationModel markAsArchived() {
    return copyWith(status: NotificationStatus.archived);
  }

  // --------------------- Private Helper Methods ---------------------

  /// Parse notification type from string
  static NotificationType _parseNotificationType(dynamic type) {
    if (type == null) return NotificationType.system;

    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'expirywarning':
        return NotificationType.expiryWarning;
      case 'expiryalert':
        return NotificationType.expiryAlert;
      case 'lowstock':
        return NotificationType.lowStock;
      case 'restock':
        return NotificationType.restock;
      case 'categoryupdate':
        return NotificationType.categoryUpdate;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.system;
    }
  }

  /// Parse notification priority from string
  static NotificationPriority _parseNotificationPriority(dynamic priority) {
    if (priority == null) return NotificationPriority.medium;

    final priorityStr = priority.toString().toLowerCase();
    switch (priorityStr) {
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      case 'critical':
        return NotificationPriority.critical;
      default:
        return NotificationPriority.medium;
    }
  }

  /// Parse notification status from string
  static NotificationStatus _parseNotificationStatus(dynamic status) {
    if (status == null) return NotificationStatus.unread;

    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'read':
        return NotificationStatus.read;
      case 'archived':
        return NotificationStatus.archived;
      case 'deleted':
        return NotificationStatus.deleted;
      default:
        return NotificationStatus.unread;
    }
  }

  /// Parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;

    try {
      if (dateTime is DateTime) {
        return dateTime;
      } else if (dateTime is String) {
        return DateTime.parse(dateTime);
      } else if (dateTime is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateTime);
      }
    } catch (e) {
      debugPrint('Error parsing DateTime: $e');
    }

    return null;
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, priority: $priority, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.message == message &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, title, message, type);
  }
}

/// Extension for batch operations on notifications
extension NotificationListExtension on List<NotificationModel> {
  /// Get all unread notifications
  List<NotificationModel> get unread =>
      where((n) => n.status == NotificationStatus.unread).toList();

  /// Get all urgent notifications
  List<NotificationModel> get urgent => where((n) => n.isUrgent()).toList();

  /// Get notifications by type
  List<NotificationModel> byType(NotificationType type) =>
      where((n) => n.type == type).toList();

  /// Get notifications from today
  List<NotificationModel> get today {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return where((n) => n.timestamp.isAfter(startOfDay)).toList();
  }

  /// Mark all as read
  List<NotificationModel> markAllAsRead() =>
      map((n) => n.markAsRead()).toList();

  /// Sort by priority (critical first)
  List<NotificationModel> sortByPriority() {
    final sorted = List<NotificationModel>.from(this);
    sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return sorted;
  }

  /// Sort by timestamp (newest first)
  List<NotificationModel> sortByTime() {
    final sorted = List<NotificationModel>.from(this);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }
}
