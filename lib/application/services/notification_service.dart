import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'reading_timer_service.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int _timerCompleteId = 888;

  // Foreground service for reading timer
  final ReadingTimerService _readingTimerService = ReadingTimerService();

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

    // Initialize reading timer service
    await _readingTimerService.initialize();

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

      // (test channel removed)
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

  /// Show timer start notification (now handled by foreground service)
  Future<void> showTimerStartNotification() async {
    // Timer start notification is now handled by the foreground service
    // which shows a persistent notification with timer progress
    debugPrint('🔔 Timer start notification handled by foreground service');
  }

  /// Show timer completion notification
  Future<void> showTimerCompleteNotification() async {
    try {
      // Ensure the static timer notification is cleared to avoid duplicates
      await cancelTimerNotification();

      await _notifications.show(
        _timerCompleteId,
        'Reading Session Complete!',
        'Your reading timer has finished. Tap to update your progress.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer_complete',
            'Reading Timer Complete',
            channelDescription: 'Notifications for reading timer completion',
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
      debugPrint('🔔 Timer completion notification shown');
    } catch (e) {
      debugPrint('❌ Completion notification failed: $e');
    }
  }

  /// Schedule notification for timer completion using foreground service
  Future<void> scheduleTimerNotification(int totalSeconds) async {
    try {
      // Use foreground service for reading timer
      await _readingTimerService.startTimer(totalSeconds);
      debugPrint('🔔 Started reading timer with foreground service');
    } catch (e) {
      debugPrint('⚠️ Could not start reading timer: $e');
      debugPrint(
        '📱 Timer service unavailable - reading session will continue without timer',
      );
      // Fallback: Continue without timer (user can still track reading manually)
    }
  }

  /// Schedule a completion notification at a specific local DateTime
  Future<void> scheduleCompletionNotificationAt(DateTime whenLocal) async {
    try {
      final tzWhen = tz.TZDateTime.from(whenLocal, tz.local);
      await _notifications.zonedSchedule(
        _timerCompleteId,
        'Reading Session Complete!',
        'Your reading timer has finished. Tap to update your progress.',
        tzWhen,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer_complete',
            'Reading Timer Complete',
            channelDescription: 'Notifications for reading timer completion',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_stat_name',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('🔔 Completion notification scheduled at $whenLocal');
    } catch (e) {
      debugPrint('❌ Scheduling completion notification failed: $e');
    }
  }

  /// Cancel any scheduled completion notification
  Future<void> cancelScheduledCompletionNotification() async {
    try {
      await _notifications.cancel(_timerCompleteId);
    } catch (e) {
      debugPrint('❌ Cancel scheduled completion notification failed: $e');
    }
  }

  /// Cancel timer notification
  Future<void> cancelTimerNotification() async {
    await _readingTimerService.stopTimer();
  }

  /// Dispose resources
  void dispose() {}
}
