import 'dart:async';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'native_timer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerService extends ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final NotificationService _notificationService = NotificationService();
  final NativeTimerService _nativeTimerService = NativeTimerService();

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
    // Only reset if there's an active timer running
    if (_isTimerRunning) {
      resetTimer();
    }

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

    _isTimerRunning = true;
    _currentBookId = bookId;

    try {
      // Start native Android service - this handles everything
      await _nativeTimerService.startTimer(
        _totalSeconds,
        bookTitle: 'Current Book',
      );

      debugPrint('🔔 Started native timer service (single source of truth)');
    } catch (e) {
      debugPrint('❌ Native timer failed: $e');
      _isTimerRunning = false;
      notifyListeners();
      return;
    }

    // Persist timer metadata for stateless resume (non-blocking)
    _persistTimerState(
      isRunning: true,
      startEpochMs: DateTime.now().millisecondsSinceEpoch,
      totalSeconds: _totalSeconds,
      bookId: _currentBookId!,
    );

    // Start UI sync timer after a short delay to let native service initialize
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isTimerRunning) {
        _startUISyncTimer();
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

    // Stop UI sync timer
    _timer?.cancel();
    _timer = null;
    _isTimerRunning = false;

    // Stop native service (handles everything)
    _nativeTimerService.stopTimer().catchError((e) {
      debugPrint('⚠️ Failed to stop native timer: $e');
    });

    // Clear persisted state
    _clearPersistedTimerState();

    notifyListeners();
  }

  void resetTimer() {
    // Stop native service (handles notifications)
    _nativeTimerService.stopTimer().catchError((e) {
      debugPrint('⚠️ Failed to stop native timer: $e');
    });

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

  /// Start UI sync timer - syncs with native service for UI updates
  void _startUISyncTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        // Get current state from native service
        final nativeState = await _nativeTimerService.getTimerState();

        if (nativeState != null) {
          final isRunning = nativeState['isRunning'] as bool? ?? false;
          final remainingSeconds = nativeState['remainingSeconds'] as int? ?? 0;

          debugPrint(
            '🔄 Native state: isRunning=$isRunning, remaining=$remainingSeconds, total=$_totalSeconds',
          );

          // Update Flutter state to match native
          _remainingSeconds = remainingSeconds;
          _isTimerRunning = isRunning;

          // Only handle completion if:
          // 1. Timer is not running AND
          // 2. Remaining seconds is 0 AND
          // 3. We had a valid total time AND
          // 4. We haven't already handled completion
          if (!isRunning &&
              remainingSeconds == 0 &&
              _totalSeconds > 0 &&
              !_completionHandled) {
            debugPrint('🎯 Timer completion detected from native service');
            _handleTimerCompletion();
          }

          notifyListeners();
        } else {
          debugPrint('⚠️ Native state is null, using Flutter fallback');
          // Fallback: use Flutter timer logic
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
            notifyListeners();
          } else if (_totalSeconds > 0 && !_completionHandled) {
            _handleTimerCompletion();
          }
        }
      } catch (e) {
        debugPrint('⚠️ Failed to sync with native timer: $e');
        // Fallback: use Flutter timer logic
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else if (_totalSeconds > 0 && !_completionHandled) {
          _handleTimerCompletion();
        }
      }
    });
  }

  /// Handle timer completion (called when native service reports completion)
  void _handleTimerCompletion() {
    if (_completionHandled) return; // Prevent multiple calls

    _completionHandled = true;
    _isTimerRunning = false;
    _timer?.cancel();
    _timer = null;

    debugPrint('⏰ Reading session completed!');

    // Clear persisted state
    _clearPersistedTimerState();

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
      _handleTimerCompletion();
      notifyListeners();
      return;
    }

    // Restore in-memory state
    _currentBookId = bookId;
    _totalSeconds = totalSeconds;
    _remainingSeconds = remaining;
    _isTimerRunning = true;

    // Start UI sync timer to sync with native service
    _startUISyncTimer();

    notifyListeners();
  }
}
