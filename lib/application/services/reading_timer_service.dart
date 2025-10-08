import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Foreground service for reading timer functionality
class ReadingTimerService {
  static const String _channelId = 'reading_timer_status';
  static const String _channelName = 'Reading Timer Status';
  static const int _notificationId = 1001;

  static final ReadingTimerService _instance = ReadingTimerService._internal();
  factory ReadingTimerService() => _instance;
  ReadingTimerService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  /// Initialize the service
  Future<void> initialize() async {
    await _createNotificationChannel();
  }

  /// Create notification channel for foreground service
  Future<void> _createNotificationChannel() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Reading timer status',
          importance: Importance.low,
          enableVibration: false,
          playSound: false,
        ),
      );
    }
  }

  /// Start reading timer (show one-time static notification)
  Future<void> startTimer(int totalSeconds) async {
    if (_isRunning) {
      await stopTimer();
    }

    _remainingSeconds = totalSeconds;
    _isRunning = true;

    // Show a single, static notification to inform the user
    await _showStaticTimerNotification();
  }

  /// Show static notification that the timer is set and running
  Future<void> _showStaticTimerNotification() async {
    try {
      await _notifications.show(
        _notificationId,
        '📚 Reading Timer Started',
        'Your timer is set and running. We\'ll notify you when it completes.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Reading timer status',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: false,
            showWhen: true,
            icon: '@drawable/ic_stat_name',
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to show static timer notification: $e');
    }
  }

  /// Cancel the static timer notification
  Future<void> _cancelStaticTimerNotification() async {
    try {
      await _notifications.cancel(_notificationId);
    } catch (e) {
      debugPrint('❌ Failed to cancel static timer notification: $e');
    }
  }

  /// Stop the timer
  Future<void> stopTimer() async {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    await _cancelStaticTimerNotification();
  }

  /// Check if timer is running
  bool get isRunning => _isRunning;

  /// Get remaining seconds
  int get remainingSeconds => _remainingSeconds;

  /// Format time in MM:SS format

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
