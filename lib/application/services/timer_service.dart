import 'dart:async';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Persistence keys
  static const String _prefsKeyIsRunning = 'timer_is_running';
  static const String _prefsKeyStartEpochMs = 'timer_start_epoch_ms';
  static const String _prefsKeyTotalSeconds = 'timer_total_seconds';
  static const String _prefsKeyBookId = 'timer_book_id';

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

    // Persist timer metadata for stateless resume
    await _persistTimerState(
      isRunning: true,
      startEpochMs: DateTime.now().millisecondsSinceEpoch,
      totalSeconds: _totalSeconds,
      bookId: _currentBookId!,
    );

    // Show timer start notification
    await _notificationService.showTimerStartNotification();

    // Schedule static "timer running" and completion notification
    await _notificationService.scheduleTimerNotification(_totalSeconds);
    final completionAt = DateTime.now().add(
      Duration(seconds: _remainingSeconds),
    );
    await _notificationService.scheduleCompletionNotificationAt(completionAt);

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
    _notificationService.cancelScheduledCompletionNotification();

    _timer?.cancel();
    _timer = null;
    _isTimerRunning = false;
    // Clear persisted state
    _clearPersistedTimerState();

    // Trigger completion flow for manual stop
    _onTimerCompleted();
  }

  void resetTimer() {
    // Cancel notification
    _notificationService.cancelTimerNotification();
    _notificationService.cancelScheduledCompletionNotification();

    _timer?.cancel();
    _timer = null;
    _isTimerRunning = false;
    _currentBookId = null;
    _totalSeconds = 0;
    _remainingSeconds = 0;
    _wasManuallyStopped = false;
    _completionHandled = false;
    _clearPersistedTimerState();
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

    // Clear persisted state
    _clearPersistedTimerState();

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

  // --- Persistence & Restore ---
  Future<void> _persistTimerState({
    required bool isRunning,
    required int startEpochMs,
    required int totalSeconds,
    required int bookId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyIsRunning, isRunning);
    await prefs.setInt(_prefsKeyStartEpochMs, startEpochMs);
    await prefs.setInt(_prefsKeyTotalSeconds, totalSeconds);
    await prefs.setInt(_prefsKeyBookId, bookId);
  }

  Future<void> _clearPersistedTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyIsRunning);
    await prefs.remove(_prefsKeyStartEpochMs);
    await prefs.remove(_prefsKeyTotalSeconds);
    await prefs.remove(_prefsKeyBookId);
  }

  Future<void> restoreFromPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(_prefsKeyIsRunning) ?? false;
    final startEpochMs = prefs.getInt(_prefsKeyStartEpochMs);
    final totalSeconds = prefs.getInt(_prefsKeyTotalSeconds);
    final bookId = prefs.getInt(_prefsKeyBookId);

    if (!isRunning ||
        startEpochMs == null ||
        totalSeconds == null ||
        bookId == null) {
      return;
    }

    final start = DateTime.fromMillisecondsSinceEpoch(startEpochMs);
    final elapsed = DateTime.now().difference(start).inSeconds;
    final remaining = totalSeconds - elapsed;

    if (remaining <= 0) {
      // Consider it completed
      _currentBookId = bookId;
      _totalSeconds = totalSeconds;
      _remainingSeconds = 0;
      _isTimerRunning = false;
      _onTimerCompleted();
      notifyListeners();
      return;
    }

    // Restore in-memory state and restart ticking
    _currentBookId = bookId;
    _totalSeconds = totalSeconds;
    _remainingSeconds = remaining;
    _isTimerRunning = true;

    // Ensure notifications are scheduled appropriately
    _notificationService.scheduleTimerNotification(_remainingSeconds);
    final completionAt = DateTime.now().add(
      Duration(seconds: _remainingSeconds),
    );
    _notificationService.scheduleCompletionNotificationAt(completionAt);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _timer = null;
        _isTimerRunning = false;
        notifyListeners();
        _onTimerCompleted();
      }
    });

    notifyListeners();
  }
}
