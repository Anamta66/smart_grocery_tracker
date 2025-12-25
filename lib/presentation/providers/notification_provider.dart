import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  // Use static methods from NotificationService
  // No need for instance since all methods are static

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
  /// Since NotificationService doesn't have getAllNotifications,
  /// we'll manage notifications locally
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Fetch from Firebase/API when backend is ready
      // For now, notifications are managed locally
      // _notifications = await fetchFromBackend();

      // Sort by timestamp (newest first)
      _notifications = _notifications.sortByTime();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new notification
  Future<void> addNotification(NotificationModel notification) async {
    try {
      // Add to local list
      _notifications.insert(0, notification);

      // Show local notification
      await NotificationService.showNotification(
        notification.title,
        notification.message,
      );

      // TODO: Save to Firebase/Backend when ready
      // await saveToBackend(notification);

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
        // Update notification status
        _notifications[index] = _notifications[index].copyWith(
          status: NotificationStatus.read,
        );

        // TODO: Update in Firebase/Backend
        // await updateInBackend(notificationId, {'status': 'read'});

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Update all notifications
      _notifications = _notifications.map((n) {
        return n.copyWith(status: NotificationStatus.read);
      }).toList();

      // TODO:  Batch update in Firebase/Backend
      // await batchUpdateInBackend();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);

      // TODO:  Delete from Firebase/Backend
      // await deleteFromBackend(notificationId);

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      // Clear local list
      _notifications.clear();

      // TODO:  Clear from Firebase/Backend
      // await clearAllFromBackend();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Archive notification
  Future<void> archiveNotification(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          status: NotificationStatus.archived,
        );

        // TODO: Update in Firebase/Backend

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
      _notifications.removeWhere(
        (n) => n.status == NotificationStatus.read,
      );

      // TODO: Delete from Firebase/Backend

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Clear old notifications (older than 30 days)
  Future<void> clearOldNotifications({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      _notifications.removeWhere(
        (n) => n.timestamp.isBefore(cutoffDate),
      );

      // TODO: Delete from Firebase/Backend

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
        _notifications[index] = _notifications[index].copyWith(
          status:
              archive ? NotificationStatus.archived : NotificationStatus.read,
        );

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
