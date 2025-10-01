import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int _timerStartId = 777;
  static const int _timerCompleteId = 888;
  static const int _testNotificationId = 999;

  // Timer state
  Timer? _notificationTimer;
  int _notificationId = 1;

  /// Initialize the notification service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_name',
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

    // Request notification permissions
    await _requestNotificationPermissions();
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
        print('🔔 Notification permission granted: $notificationPermission');

        // Request exact alarm permission for Android 12+
        final exactAlarmPermission = await androidPlugin
            .requestExactAlarmsPermission();
        print('🔔 Exact alarm permission granted: $exactAlarmPermission');
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  /// Ensure notification permissions are granted
  Future<void> ensurePermissions() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final hasPermission = await androidPlugin.areNotificationsEnabled();
        print('🔔 Notifications enabled: $hasPermission');

        if (hasPermission == false) {
          print('🔔 Requesting notification permission...');
          await androidPlugin.requestNotificationsPermission();
        }
      }
    } catch (e) {
      print('❌ Error checking/requesting permissions: $e');
    }
  }

  /// Show timer start notification
  Future<void> showTimerStartNotification() async {
    try {
      await _notifications.show(
        _timerStartId,
        'Reading Timer Started',
        'Timer is running. Check back when done!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer_start',
            'Reading Timer Start',
            channelDescription: 'Notifications for reading timer start',
            importance: Importance.low,
            priority: Priority.low,
            silent: true,
            icon: '@drawable/ic_stat_name',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            sound: null,
          ),
        ),
      );
    } catch (e) {
      print('❌ Timer start notification failed: $e');
    }
  }

  /// Show timer completion notification
  Future<void> showTimerCompleteNotification() async {
    try {
      // Clear the start notification first
      await _notifications.cancel(_timerStartId);

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
    } catch (e) {
      print('❌ Completion notification failed: $e');
    }
  }

  /// Schedule notification for timer completion
  Future<void> scheduleTimerNotification(int totalSeconds) async {
    try {
      final endTime = tz.TZDateTime.now(
        tz.local,
      ).add(Duration(seconds: totalSeconds));

      await _notifications.zonedSchedule(
        _notificationId,
        'Reading Session Complete!',
        'Your reading timer has finished. Tap to update your progress.',
        endTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer',
            'Reading Timer',
            channelDescription: 'Notifications for reading timer completion',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Start updating notification every 5 minutes
      _startNotificationUpdates(totalSeconds);
    } catch (e) {
      print('⚠️ Could not schedule exact alarm notification: $e');
      print('📱 Notifications will work but may not be exact timing');
      // Fallback: Show immediate notification
      await showTimerStartNotification();
    }
  }

  /// Start updating notification every 5 minutes
  void _startNotificationUpdates(int totalSeconds) {
    _notificationTimer?.cancel();

    _notificationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      final remainingMinutes = totalSeconds ~/ 60;

      if (remainingMinutes > 0) {
        _updateTimerNotification(remainingMinutes);
      } else {
        timer.cancel();
      }
    });
  }

  /// Update the notification with remaining time
  Future<void> _updateTimerNotification(int remainingMinutes) async {
    try {
      await _notifications.show(
        _notificationId,
        'Reading Timer Running',
        'Time remaining: ${remainingMinutes} minutes',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer',
            'Reading Timer',
            channelDescription: 'Notifications for reading timer',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            icon: '@drawable/ic_stat_name',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
          ),
        ),
      );
    } catch (e) {
      print('❌ Update notification failed: $e');
    }
  }

  /// Cancel timer notification
  Future<void> cancelTimerNotification() async {
    await _notifications.cancel(_notificationId);
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  /// Test notification method (for debugging)
  Future<void> showTestNotification() async {
    try {
      await _notifications.show(
        _testNotificationId,
        'Test Notification',
        'If you see this, notifications are working!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notifications',
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
      print('🔔 Test notification sent successfully');
    } catch (e) {
      print('❌ Test notification failed: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationTimer?.cancel();
  }
}
