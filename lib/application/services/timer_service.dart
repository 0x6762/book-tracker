import 'dart:async';
import 'package:flutter/foundation.dart';
import 'native_timer_service.dart';

/// Simplified timer service that coordinates with native Android service
/// All timer logic and notifications are handled by the native service
class TimerService extends ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final NativeTimerService _nativeTimerService = NativeTimerService();

  // Timer state (synced from native service)
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  int? _currentBookId;
  bool _wasManuallyStopped = false;
  bool _completionHandled = false;

  // Stream subscription for native timer updates
  StreamSubscription<Map<String, dynamic>>? _timerStateSubscription;

  // Timer getters
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  bool get isTimerRunning => _isTimerRunning;
  bool get isTimerPaused => _isTimerPaused;
  int? get currentBookId => _currentBookId;
  bool get isTimerCompleted =>
      _remainingSeconds <= 0 && _totalSeconds > 0 && !_completionHandled;
  bool get wasManuallyStopped => _wasManuallyStopped && !_completionHandled;
  bool get hasTimerJustCompleted => _completionHandled && _totalSeconds > 0;
  bool get isTimerInErrorState =>
      _completionHandled && !_isTimerRunning && _totalSeconds > 0;

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
    _completionHandled = false; // Clear any error state
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
      _completionHandled = true; // Mark as error state
      notifyListeners();
      rethrow; // Re-throw to let UI handle the error
    }

    // Start listening to native timer updates
    _startNativeTimerListener();

    notifyListeners();
  }

  void stopTimer() {
    // Prevent multiple calls
    if (_currentBookId == null && _totalSeconds == 0) {
      return;
    }

    // Mark as manually stopped
    _wasManuallyStopped = true;

    // Stop listening to native updates
    _timerStateSubscription?.cancel();
    _timerStateSubscription = null;

    // Stop native service (handles everything)
    _nativeTimerService.stopTimer().catchError((e) {
      debugPrint('⚠️ Failed to stop native timer: $e');
    });

    // Trigger completion flow for manual stop
    _handleTimerCompletion();

    notifyListeners();
  }

  void resetTimer() {
    // Stop native service (handles notifications)
    _nativeTimerService.stopTimer().catchError((e) {
      debugPrint('⚠️ Failed to stop native timer: $e');
    });

    _timerStateSubscription?.cancel();
    _timerStateSubscription = null;
    _isTimerRunning = false;
    _currentBookId = null;
    _totalSeconds = 0;
    _remainingSeconds = 0;
    _wasManuallyStopped = false;
    _completionHandled = false;
    notifyListeners();
  }

  /// Retry starting the timer after an error
  Future<void> retryTimer() async {
    if (_currentBookId == null || _totalSeconds <= 0) {
      debugPrint('❌ Cannot retry timer - no valid state');
      return;
    }

    debugPrint('🔄 Retrying timer start...');

    // Clear error state
    _completionHandled = false;

    // Try to start timer again
    await startTimer(_currentBookId!);
  }

  /// Pause the timer
  Future<void> pauseTimer() async {
    if (!_isTimerRunning || _isTimerPaused) {
      return; // Already paused or not running
    }

    try {
      await _nativeTimerService.pauseTimer();
      debugPrint('⏸️ Timer paused');
    } catch (e) {
      debugPrint('❌ Failed to pause timer: $e');
      rethrow;
    }
  }

  /// Resume the timer
  Future<void> resumeTimer() async {
    if (!_isTimerRunning || !_isTimerPaused) {
      return; // Not paused or not running
    }

    try {
      await _nativeTimerService.resumeTimer();
      debugPrint('▶️ Timer resumed');
    } catch (e) {
      debugPrint('❌ Failed to resume timer: $e');
      rethrow;
    }
  }

  /// Start listening to native timer updates via EventChannel
  void _startNativeTimerListener() {
    _timerStateSubscription?.cancel(); // Cancel any existing subscription

    _timerStateSubscription = _nativeTimerService.timerStateStream.listen(
      (nativeState) {
        final isRunning = nativeState['isRunning'] as bool? ?? false;
        final isPaused = nativeState['isPaused'] as bool? ?? false;
        final remainingSeconds = nativeState['remainingSeconds'] as int? ?? 0;
        final totalSeconds = nativeState['totalSeconds'] as int? ?? 0;

        debugPrint(
          '🔄 Native update: isRunning=$isRunning, isPaused=$isPaused, remaining=$remainingSeconds, total=$totalSeconds',
        );

        // Update Flutter state to match native
        _remainingSeconds = remainingSeconds;
        _isTimerRunning = isRunning;
        _isTimerPaused = isPaused;
        if (totalSeconds > 0) {
          _totalSeconds = totalSeconds;
        }

        // Handle completion if timer finished
        if (!isRunning &&
            remainingSeconds == 0 &&
            _totalSeconds > 0 &&
            !_completionHandled) {
          debugPrint('🎯 Timer completion detected from native service');
          _handleTimerCompletion();
        }

        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Native timer stream error: $error');
        // Stop timer and show error state - no fallback
        _handleNativeServiceError();
      },
    );
  }

  /// Handle native service errors gracefully
  void _handleNativeServiceError() {
    debugPrint('🛑 Native timer service error - stopping timer');

    // Stop listening to native updates
    _timerStateSubscription?.cancel();
    _timerStateSubscription = null;

    // Reset timer state
    _isTimerRunning = false;
    _completionHandled = true; // Prevent completion handling

    // Notify UI of error state
    notifyListeners();
  }

  /// Handle timer completion (called when native service reports completion)
  void _handleTimerCompletion() {
    if (_completionHandled) return; // Prevent multiple calls

    _completionHandled = true;
    _isTimerRunning = false;

    debugPrint('⏰ Reading session completed!');

    // Trigger progress update modal
    _triggerProgressUpdateModal();

    notifyListeners();
  }

  /// Trigger progress update modal
  void _triggerProgressUpdateModal() {
    // This will be handled by the UI layer
    // We just need to notify that completion happened
    debugPrint('📝 Triggering progress update modal for book $_currentBookId');
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

  // Clear just completed state (called after modal is shown)
  void clearJustCompletedState() {
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
    _timerStateSubscription?.cancel();
    super.dispose();
  }
}
