// lib/data/repositories/notification_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/models/notification_model. dart';

/// Repository handling push notifications and notification history
/// Manages FCM tokens, local notifications, and notification storage
class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Reference to user's notifications collection
  CollectionReference _notificationCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  /// Initialize notification services
  ///
  /// Requests permissions and sets up local notifications
  Future<void> initialize() async {
    try {
      // Request notification permissions
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      // Initialize local notifications (Android)
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(settings);
    } catch (e) {
      throw Exception('Failed to initialize notifications:  $e');
    }
  }

  /// Get and save FCM token for push notifications
  ///
  /// Stores device token in Firestore for targeted notifications
  Future<String?> getAndSaveFCMToken(String userId) async {
    try {
      final token = await _messaging.getToken();

      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      return token;
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }

  /// Show local notification
  ///
  /// Displays notification on device without server interaction
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'grocery_channel',
        'Grocery Notifications',
        channelDescription: 'Notifications for grocery expiry and low stock',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      throw Exception('Failed to show notification: $e');
    }
  }

  /// Save notification to history
  ///
  /// Stores notification in Firestore for later viewing
  Future<NotificationModel> saveNotification({
    required String userId,
    required NotificationModel notification,
  }) async {
    try {
      final docRef = _notificationCollection(userId).doc();

      final newNotification = notification.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
      );

      await docRef.set(newNotification.toMap());

      return newNotification;
    } catch (e) {
      throw Exception('Failed to save notification: $e');
    }
  }

  /// Get all notifications for user
  ///
  /// Returns sorted list with unread first
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final snapshot = await _notificationCollection(
        userId,
      ).orderBy('createdAt', descending: true).get();

      return snapshot.docs
          .map(
            (doc) =>
                NotificationModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Stream of real-time notifications
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _notificationCollection(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                NotificationModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  /// Mark notification as read
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _notificationCollection(
        userId,
      ).doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read:  $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();

      final snapshot = await _notificationCollection(
        userId,
      ).where('isRead', isEqualTo: false).get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _notificationCollection(userId).doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _notificationCollection(
        userId,
      ).where('isRead', isEqualTo: false).get();

      return snapshot.size;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();

      final snapshot = await _notificationCollection(userId).get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear notifications: $e');
    }
  }

  /// Schedule daily expiry check notification
  ///
  /// Sends notification at specified time if items are expiring
  Future<void> scheduleDailyExpiryCheck({
    required int hour,
    required int minute,
  }) async {
    try {
      // Schedule daily notification at specific time
      await _localNotifications.zonedSchedule(
        0,
        'Daily Grocery Check',
        'Check your expiring items today! ',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_check',
            'Daily Checks',
            channelDescription: 'Daily grocery expiry reminders',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      throw Exception('Failed to schedule daily check: $e');
    }
  }

  /// Helper:  Calculate next instance of specified time
  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
