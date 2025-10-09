import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to communicate with native Android timer service
class NativeTimerService {
  static const MethodChannel _channel = MethodChannel(
    'reading_timer/native_service',
  );

  static final NativeTimerService _instance = NativeTimerService._internal();
  factory NativeTimerService() => _instance;
  NativeTimerService._internal();

  /// Start timer using native Android service
  Future<void> startTimer(int totalSeconds, {String bookTitle = ''}) async {
    try {
      await _channel.invokeMethod('startTimer', {
        'totalSeconds': totalSeconds,
        'bookTitle': bookTitle,
      });
      debugPrint('🔔 Native timer service started');
    } catch (e) {
      debugPrint('❌ Failed to start native timer: $e');
      rethrow;
    }
  }

  /// Stop timer using native Android service
  Future<void> stopTimer() async {
    try {
      await _channel.invokeMethod('stopTimer');
      debugPrint('🔔 Native timer service stopped');
    } catch (e) {
      debugPrint('❌ Failed to stop native timer: $e');
      rethrow;
    }
  }

  /// Get current timer state from native service
  Future<Map<String, dynamic>?> getTimerState() async {
    try {
      final state = await _channel.invokeMethod('getTimerState');
      return Map<String, dynamic>.from(state ?? {});
    } catch (e) {
      debugPrint('❌ Failed to get timer state: $e');
      return null;
    }
  }
}
