import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Timer state for notifications
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

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

    // Timer service is now handled internally

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
        888, // Timer completion notification ID
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

  /// Schedule notification for timer completion
  Future<void> scheduleTimerNotification(
    int totalSeconds, {
    String bookTitle = '',
  }) async {
    try {
      if (_isRunning) {
        await cancelTimerNotification();
      }

      _remainingSeconds = totalSeconds;
      _isRunning = true;

      // Show initial notification
      await _showTimerNotification(bookTitle);

      // Start countdown timer that updates notification
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _updateTimerNotification(bookTitle);
        } else {
          _onTimerCompleted();
        }
      });

      debugPrint('🔔 Started reading timer notification');
    } catch (e) {
      debugPrint('⚠️ Could not start reading timer: $e');
      debugPrint(
        '📱 Timer service unavailable - reading session will continue without timer',
      );
    }
  }

  /// Show the in-progress timer notification
  Future<void> _showTimerNotification(String bookTitle) async {
    try {
      await _notifications.show(
        1001, // Timer notification ID
        '📚 Reading Timer',
        _getTimerNotificationText(bookTitle),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer_foreground',
            'Reading Timer',
            channelDescription: 'Ongoing reading timer notifications',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            showWhen: false,
            icon: '@drawable/ic_stat_name',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to show timer notification: $e');
    }
  }

  /// Update the timer notification with current time
  Future<void> _updateTimerNotification(String bookTitle) async {
    try {
      await _notifications.show(
        1001, // Same ID to update existing notification
        '📚 Reading Timer',
        _getTimerNotificationText(bookTitle),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_timer_foreground',
            'Reading Timer',
            channelDescription: 'Ongoing reading timer notifications',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            showWhen: false,
            icon: '@drawable/ic_stat_name',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to update timer notification: $e');
    }
  }

  /// Get notification text with current time
  String _getTimerNotificationText(String bookTitle) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} remaining';

    if (bookTitle.isNotEmpty) {
      return 'Reading: $bookTitle - $timeText';
    } else {
      return 'Reading Timer - $timeText';
    }
  }

  /// Cancel timer notification
  Future<void> cancelTimerNotification() async {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;

    // Actually cancel the notification
    try {
      await _notifications.cancel(1001);
      debugPrint('🔔 Timer notification cancelled');
    } catch (e) {
      debugPrint('❌ Failed to cancel timer notification: $e');
    }
  }

  /// Handle timer completion
  void _onTimerCompleted() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    debugPrint('⏰ Reading timer completed');
    // The completion notification will be handled by TimerService
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
