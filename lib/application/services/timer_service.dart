import 'dart:async';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class TimerService extends ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final NotificationService _notificationService = NotificationService();

  // Timer state
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isTimerRunning = false;
  int? _currentBookId;
  bool _wasManuallyStopped = false;
  bool _completionHandled = false;

  // Timer getters
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  bool get isTimerRunning => _isTimerRunning;
  int? get currentBookId => _currentBookId;
  bool get isTimerCompleted =>
      _remainingSeconds <= 0 && _totalSeconds > 0 && !_completionHandled;
  bool get wasManuallyStopped => _wasManuallyStopped && !_completionHandled;

  // Timer methods
  void setTimer(int bookId, int minutes) {
    resetTimer(); // Reset any existing timer

    _currentBookId = bookId;
    // Special case: 0 minutes = 5 seconds for testing
    _totalSeconds = minutes == 0 ? 5 : minutes * 60;
    _remainingSeconds = _totalSeconds;
    _isTimerRunning = false;
    _wasManuallyStopped = false;
    _completionHandled = false;
    notifyListeners();
  }

  Future<void> startTimer(int bookId) async {
    if (_isTimerRunning && _currentBookId == bookId) {
      return; // Already running for this book
    }

    if (_remainingSeconds <= 0) {
      return; // No time left
    }

    // Ensure permissions are granted before starting timer
    final hasPermission = await _notificationService.ensurePermissions();
    if (!hasPermission) {
      print(
        '⚠️ Notification permissions not granted, timer will start but notifications may not work',
      );
    }

    _isTimerRunning = true;
    _currentBookId = bookId;

    // Show timer start notification
    await _notificationService.showTimerStartNotification();

    // Schedule notification for timer completion
    await _notificationService.scheduleTimerNotification(_totalSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // Timer completed
        _timer?.cancel();
        _timer = null;
        _isTimerRunning = false;
        notifyListeners();
        _onTimerCompleted();
      }
    });

    notifyListeners();
  }

  void stopTimer() {
    // Prevent multiple calls
    if (_currentBookId == null && _totalSeconds == 0) {
      return;
    }

    // Mark as manually stopped
    _wasManuallyStopped = true;

    // Cancel notification
    _notificationService.cancelTimerNotification();

    _timer?.cancel();
    _timer = null;
    _isTimerRunning = false;

    // Trigger completion flow for manual stop
    _onTimerCompleted();
  }

  void resetTimer() {
    // Cancel notification
    _notificationService.cancelTimerNotification();

    _timer?.cancel();
    _timer = null;
    _isTimerRunning = false;
    _currentBookId = null;
    _totalSeconds = 0;
    _remainingSeconds = 0;
    _wasManuallyStopped = false;
    _completionHandled = false;
    notifyListeners();
  }

  void pauseTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      _timer = null;
      _isTimerRunning = false;
      notifyListeners();
    }
  }

  void resumeTimer() {
    if (!_isTimerRunning && _remainingSeconds > 0 && _currentBookId != null) {
      startTimer(_currentBookId!);
    }
  }

  void _onTimerCompleted() {
    print('⏰ Reading session completed!');

    // Show completion notification
    _notificationService.showTimerCompleteNotification();

    // Notify listeners that timer completed
    notifyListeners();
  }

  // Mark completion as handled to prevent multiple triggers
  void markCompletionHandled() {
    _completionHandled = true;
    notifyListeners();
  }

  // Clear completion state after handling
  void clearCompletionState() {
    _wasManuallyStopped = false;
    _completionHandled = false;
    notifyListeners();
  }

  // Format time for display
  String get formattedTime {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Get progress percentage (0.0 to 1.0)
  double get progress {
    if (_totalSeconds == 0) return 0.0;
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationService.dispose();
    super.dispose();
  }
}
