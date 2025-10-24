import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Simplified notification service for app-level notifications
/// Timer notifications are handled by the native Android service
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Create notification channels for Android
    await _createNotificationChannels();

    // Request notification permissions
    await _requestNotificationPermissions();
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Timer completion channel (for foreground service completion)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'reading_timer_complete',
          'Reading Timer Complete',
          description: 'Notifications for reading timer completion',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );

      // Timer foreground channel (for in-progress timer)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'reading_timer_foreground',
          'Reading Timer',
          description: 'Ongoing reading timer notifications',
          importance: Importance.low,
          enableVibration: false,
          playSound: false,
        ),
      );
    }
  }

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Request notification permission
        final notificationPermission = await androidPlugin
            .requestNotificationsPermission();
        debugPrint(
          '🔔 Notification permission granted: $notificationPermission',
        );

        // Check if notifications are available
        final canScheduleNotifications = await androidPlugin
            .areNotificationsEnabled();
        debugPrint('🔔 Notifications enabled: $canScheduleNotifications');
      }
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
    }
  }

  /// Ensure notification permissions are granted
  Future<bool> ensurePermissions() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final hasPermission = await androidPlugin.areNotificationsEnabled();
        debugPrint('🔔 Notifications enabled: $hasPermission');

        if (hasPermission == false) {
          debugPrint('🔔 Requesting notification permission...');
          final granted = await androidPlugin.requestNotificationsPermission();
          debugPrint('🔔 Permission request result: $granted');
          return granted ?? false;
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error checking/requesting permissions: $e');
      return false;
    }
  }

  /// Show a general app notification (for non-timer use cases)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
  }) async {
    try {
      await _notifications.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId ?? 'general',
            'General Notifications',
            channelDescription: 'General app notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_stat_name',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
          ),
        ),
      );
      debugPrint('🔔 Notification shown: $title');
    } catch (e) {
      debugPrint('❌ Notification failed: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('🔔 Notification cancelled: $id');
    } catch (e) {
      debugPrint('❌ Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('🔔 All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Failed to cancel all notifications: $e');
    }
  }
}
