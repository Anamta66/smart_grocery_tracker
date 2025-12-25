import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/api_config.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount =>
      _notifications.where((n) => n.status == NotificationStatus.unread).length;

  /// Fetch all notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to fetch from API
      try {
        final response = await ApiService.get(ApiConfig.notifications);

        if (response['success'] == true && response['data'] is List) {
          _notifications = (response['data'] as List)
              .map((json) => NotificationModel.fromJson(json))
              .toList();

          // Sort by timestamp (newest first)
          _notifications = _notifications.sortByTime();

          if (kDebugMode) {
            print('✅ Fetched ${_notifications.length} notifications from API');
          }
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('⚠️ API error fetching notifications: $apiError');
        }
        // Keep existing local notifications if API fails
        _notifications = _notifications.sortByTime();
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ Error fetching notifications: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new notification
  Future<void> addNotification(NotificationModel notification) async {
    try {
      // Add to local list first (optimistic update)
      _notifications.insert(0, notification);
      notifyListeners();

      // Show local notification
      await NotificationService.showNotification(
        notification.title,
        notification.message,
      );

      // Save to backend
      try {
        final response = await ApiService.post(
          ApiConfig.notifications,
          notification.toJson(),
        );

        if (response['success'] == true && response['data'] != null) {
          // Update with server-generated data (ID, timestamps, etc.)
          final savedNotification =
              NotificationModel.fromJson(response['data']);
          final index =
              _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = savedNotification;
          }

          if (kDebugMode) {
            print('✅ Notification saved to backend');
          }
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('⚠️ Failed to save notification to backend: $apiError');
        }
        // Keep local notification even if API fails
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Error adding notification: $e');
      }
    }
  }

  /// Create and add expiry warning notification
  Future<void> addExpiryWarning({
    required String groceryItemName,
    required String groceryItemId,
    required DateTime expiryDate,
    required int daysUntilExpiry,
  }) async {
    final notification = NotificationModel.expiryWarning(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id', // TODO: Get from AuthProvider
      groceryItemName: groceryItemName,
      groceryItemId: groceryItemId,
      expiryDate: expiryDate,
      daysUntilExpiry: daysUntilExpiry,
    );

    await addNotification(notification);
  }

  /// Create and add expiry alert notification
  Future<void> addExpiryAlert({
    required String groceryItemName,
    required String groceryItemId,
    required DateTime expiryDate,
  }) async {
    final notification = NotificationModel.expiryAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id', // TODO: Get from AuthProvider
      groceryItemName: groceryItemName,
      groceryItemId: groceryItemId,
      expiryDate: expiryDate,
    );

    await addNotification(notification);
  }

  /// Create and add low stock notification
  Future<void> addLowStockAlert({
    required String groceryItemName,
    required String groceryItemId,
    required int currentQuantity,
    required int minQuantity,
  }) async {
    final notification = NotificationModel.lowStock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id', // TODO: Get from AuthProvider
      groceryItemName: groceryItemName,
      groceryItemId: groceryItemId,
      currentQuantity: currentQuantity,
      minQuantity: minQuantity,
    );

    await addNotification(notification);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Optimistic update
        _notifications[index] = _notifications[index].copyWith(
          status: NotificationStatus.read,
        );
        notifyListeners();

        // Update in backend
        try {
          await ApiService.put(
            '${ApiConfig.notifications}/$notificationId',
            {'status': 'read'},
          );

          if (kDebugMode) {
            print('✅ Notification marked as read in backend');
          }
        } catch (apiError) {
          if (kDebugMode) {
            print(
                '⚠️ Failed to update notification status in backend: $apiError');
          }
          // Keep local update even if API fails
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Error marking notification as read: $e');
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Optimistic update
      _notifications = _notifications.map((n) {
        return n.copyWith(status: NotificationStatus.read);
      }).toList();
      notifyListeners();

      // Batch update in backend
      try {
        await ApiService.put(
          '${ApiConfig.notifications}/mark-all-read',
          {},
        );

        if (kDebugMode) {
          print('✅ All notifications marked as read in backend');
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('⚠️ Failed to mark all as read in backend: $apiError');
        }
        // Keep local update even if API fails
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Error marking all as read: $e');
      }
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Optimistic delete
      final deletedNotification =
          _notifications.firstWhere((n) => n.id == notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      // Delete from backend
      try {
        await ApiService.delete('${ApiConfig.notifications}/$notificationId');

        if (kDebugMode) {
          print('✅ Notification deleted from backend');
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('⚠️ Failed to delete from backend: $apiError');
        }
        // Rollback if API fails
        _notifications.insert(0, deletedNotification);
        notifyListeners();
        _errorMessage = 'Failed to delete notification';
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Error deleting notification: $e');
      }
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      // Backup for rollback
      final backup = List<NotificationModel>.from(_notifications);

      // Optimistic clear
      _notifications.clear();
      notifyListeners();

      // Clear from backend
      try {
        await ApiService.delete('${ApiConfig.notifications}/clear-all');

        if (kDebugMode) {
          print('✅ All notifications cleared from backend');
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('⚠️ Failed to clear from backend: $apiError');
        }
        // Rollback if API fails
        _notifications = backup;
        notifyListeners();
        _errorMessage = 'Failed to clear notifications';
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Error clearing notifications: $e');
      }
    }
  }

  /// Archive notification
  Future<void> archiveNotification(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Optimistic update
        _notifications[index] = _notifications[index].copyWith(
          status: NotificationStatus.archived,
        );
        notifyListeners();

        // Update in backend
        try {
          await ApiService.put(
            '${ApiConfig.notifications}/$notificationId',
            {'status': 'archived'},
          );

          if (kDebugMode) {
            print('✅ Notification archived in backend');
          }
        } catch (apiError) {
          if (kDebugMode) {
            print('⚠️ Failed to archive in backend: $apiError');
          }
          // Keep local update even if API fails
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Error archiving notification:  $e');
      }
    }
  }

  /// Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications
        .where(
          (n) => n.status == NotificationStatus.unread,
        )
        .toList();
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get urgent notifications
  List<NotificationModel> getUrgentNotifications() {
    return _notifications.where((n) => n.isUrgent()).toList();
  }

  /// Get today's notifications
  List<NotificationModel> getTodayNotifications() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _notifications
        .where(
          (n) => n.timestamp.isAfter(startOfDay),
        )
        .toList();
  }

  /// Get recent notifications (last 24 hours)
  List<NotificationModel> getRecentNotifications() {
    return _notifications.where((n) => n.isRecent()).toList();
  }

  /// Filter notifications by priority
  List<NotificationModel> getNotificationsByPriority(
      NotificationPriority priority) {
    return _notifications.where((n) => n.priority == priority).toList();
  }

  /// Get expiry-related notifications
  List<NotificationModel> getExpiryNotifications() {
    return _notifications
        .where((n) =>
            n.type == NotificationType.expiryWarning ||
            n.type == NotificationType.expiryAlert)
        .toList();
  }

  /// Get stock-related notifications
  List<NotificationModel> getStockNotifications() {
    return _notifications
        .where((n) =>
            n.type == NotificationType.lowStock ||
            n.type == NotificationType.restock)
        .toList();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear read notifications (cleanup)
  Future<void> clearReadNotifications() async {
    try {
      // Backup for rollback
      final toDelete = _notifications
          .where((n) => n.status == NotificationStatus.read)
          .toList();

      // Optimistic delete
      _notifications.removeWhere(
        (n) => n.status == NotificationStatus.read,
      );
      notifyListeners();

      // Delete from backend
      try {
        await ApiService.delete('${ApiConfig.notifications}/clear-read');

        if (kDebugMode) {
          print('✅ Read notifications cleared from backend');
        }
      } catch (apiError) {
        if (kDebugMode) {
          print(
              '⚠️ Failed to clear read notifications from backend: $apiError');
        }
        // Rollback if API fails
        _notifications.addAll(toDelete);
        _notifications = _notifications.sortByTime();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Error clearing read notifications:  $e');
      }
    }
  }

  /// Clear old notifications (older than 30 days)
  Future<void> clearOldNotifications({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      // Backup for rollback
      final toDelete = _notifications
          .where((n) => n.timestamp.isBefore(cutoffDate))
          .toList();

      // Optimistic delete
      _notifications.removeWhere(
        (n) => n.timestamp.isBefore(cutoffDate),
      );
      notifyListeners();

      // Delete from backend
      try {
        await ApiService.delete(
          '${ApiConfig.notifications}/clear-old?daysOld=${daysOld.toString()}',
        );

        if (kDebugMode) {
          print('✅ Old notifications cleared from backend');
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('⚠️ Failed to clear old notifications from backend: $apiError');
        }
        // Rollback if API fails
        _notifications.addAll(toDelete);
        _notifications = _notifications.sortByTime();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Error clearing old notifications: $e');
      }
    }
  }

  /// Get notification statistics
  Map<String, int> getStatistics() {
    return {
      'total': _notifications.length,
      'unread': getUnreadNotifications().length,
      'urgent': getUrgentNotifications().length,
      'today': getTodayNotifications().length,
      'expiry': getExpiryNotifications().length,
      'stock': getStockNotifications().length,
    };
  }

  /// Dismiss notification (mark as read and optionally archive)
  Future<void> dismissNotification(String notificationId,
      {bool archive = false}) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Optimistic update
        _notifications[index] = _notifications[index].copyWith(
          status:
              archive ? NotificationStatus.archived : NotificationStatus.read,
        );
        notifyListeners();

        // Update in backend
        try {
          await ApiService.put(
            '${ApiConfig.notifications}/$notificationId',
            {'status': archive ? 'archived' : 'read'},
          );

          if (kDebugMode) {
            print('✅ Notification dismissed in backend');
          }
        } catch (apiError) {
          if (kDebugMode) {
            print('⚠️ Failed to dismiss notification in backend: $apiError');
          }
          // Keep local update even if API fails
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Error dismissing notification: $e');
      }
    }
  }

  /// Refresh notifications from server
  Future<void> refresh() async {
    await fetchNotifications();
  }
}
