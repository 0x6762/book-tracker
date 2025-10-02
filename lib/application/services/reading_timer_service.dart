import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Foreground service for reading timer functionality
class ReadingTimerService {
  static const MethodChannel _channel = MethodChannel('reading_timer_service');
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
          description: 'Reading timer foreground service',
          importance: Importance.low,
          enableVibration: false,
          playSound: false,
        ),
      );
    }
  }

  /// Start reading timer with foreground service
  Future<void> startTimer(int totalSeconds) async {
    if (_isRunning) {
      await stopTimer();
    }

    _remainingSeconds = totalSeconds;
    _isRunning = true;

    // Start foreground service
    await _startForegroundService();

    // Start countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      _updateNotification();

      if (_remainingSeconds <= 0) {
        _onTimerComplete();
      }
    });
  }

  /// Start foreground service
  Future<void> _startForegroundService() async {
    try {
      await _notifications.show(
        _notificationId,
        '📚 Reading Session in Progress',
        'Time remaining: ${_formatTime(_remainingSeconds)} • Tap to open app',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Reading timer foreground service',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            showWhen: false,
            icon: '@drawable/ic_stat_name',
            actions: [
              const AndroidNotificationAction(
                'stop_timer',
                'Stop Timer',
                showsUserInterface: true,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to start foreground service: $e');
    }
  }

  /// Update notification with remaining time
  Future<void> _updateNotification() async {
    if (!_isRunning) return;

    try {
      await _notifications.show(
        _notificationId,
        '📚 Reading Session in Progress',
        'Time remaining: ${_formatTime(_remainingSeconds)} • Tap to open app',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Reading timer foreground service',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            showWhen: false,
            icon: '@drawable/ic_stat_name',
            actions: [
              const AndroidNotificationAction(
                'stop_timer',
                'Stop Timer',
                showsUserInterface: true,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to update notification: $e');
    }
  }

  /// Handle timer completion
  Future<void> _onTimerComplete() async {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;

    // Stop foreground service (no completion notification needed)
    await _stopForegroundService();

    debugPrint('🔔 Timer completed - foreground service stopped');
  }

  /// Stop foreground service
  Future<void> _stopForegroundService() async {
    try {
      await _notifications.cancel(_notificationId);
    } catch (e) {
      debugPrint('❌ Failed to stop foreground service: $e');
    }
  }

  /// Stop the timer
  Future<void> stopTimer() async {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    await _stopForegroundService();
  }

  /// Check if timer is running
  bool get isRunning => _isRunning;

  /// Get remaining seconds
  int get remainingSeconds => _remainingSeconds;

  /// Format time in MM:SS format
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
