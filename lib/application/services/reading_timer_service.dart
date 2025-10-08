import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Foreground service for reading timer functionality
class ReadingTimerService {
  static const String _channelId = 'reading_timer_foreground';
  static const String _channelName = 'Reading Timer';
  static const int _notificationId = 1001;

  static final ReadingTimerService _instance = ReadingTimerService._internal();
  factory ReadingTimerService() => _instance;
  ReadingTimerService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  String _bookTitle = '';

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
          description: 'Ongoing reading timer notifications',
          importance: Importance.low,
          enableVibration: false,
          playSound: false,
        ),
      );
    }
  }

  /// Start reading timer with foreground service
  Future<void> startTimer(int totalSeconds, {String bookTitle = ''}) async {
    if (_isRunning) {
      await stopTimer();
    }

    _totalSeconds = totalSeconds;
    _remainingSeconds = totalSeconds;
    _bookTitle = bookTitle;
    _isRunning = true;

    // Start the foreground service with periodic updates
    await _startForegroundService();

    // Start the countdown timer
    _startCountdownTimer();
  }

  /// Start foreground service with ongoing notification
  Future<void> _startForegroundService() async {
    try {
      await _notifications.show(
        _notificationId,
        '📚 Reading Timer',
        _getNotificationText(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
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
      debugPrint('🔔 Foreground service started');
    } catch (e) {
      debugPrint('❌ Failed to start foreground service: $e');
    }
  }

  /// Start countdown timer that updates notification
  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _updateNotification();
      } else {
        _onTimerCompleted();
      }
    });
  }

  /// Update the ongoing notification with current time
  Future<void> _updateNotification() async {
    try {
      await _notifications.show(
        _notificationId,
        '📚 Reading Timer',
        _getNotificationText(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
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
      debugPrint('❌ Failed to update notification: $e');
    }
  }

  /// Get notification text with current time
  String _getNotificationText() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} remaining';

    if (_bookTitle.isNotEmpty) {
      return 'Reading: $_bookTitle - $timeText';
    } else {
      return 'Reading Timer - $timeText';
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

  /// Stop the timer and cancel notification
  Future<void> stopTimer() async {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    await _notifications.cancel(_notificationId);
    debugPrint('🔔 Foreground service stopped');
  }

  /// Check if timer is running
  bool get isRunning => _isRunning;

  /// Get remaining seconds
  int get remainingSeconds => _remainingSeconds;

  /// Get total seconds
  int get totalSeconds => _totalSeconds;

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
