package com.readr.booktracker

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class MainActivity : FlutterActivity() {
    private val CHANNEL = "reading_timer/native_service"
    private val EVENT_CHANNEL = "reading_timer/events"
    private var eventSink: EventSink? = null
    

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Method Channel for commands
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startTimer" -> {
                    val totalSeconds = call.argument<Int>("totalSeconds") ?: 0
                    val bookTitle = call.argument<String>("bookTitle") ?: ""
                    startTimerService(totalSeconds, bookTitle)
                    result.success(null)
                }
                "pauseTimer" -> {
                    pauseTimerService()
                    result.success(null)
                }
                "resumeTimer" -> {
                    resumeTimerService()
                    result.success(null)
                }
                "stopTimer" -> {
                    stopTimerService()
                    result.success(null)
                }
                "getTimerState" -> {
                    val state = getTimerState()
                    result.success(state)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Event Channel for real-time updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventSink?) {
                    eventSink = events
                    staticEventSink = events
                }
                
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    staticEventSink = null
                }
            }
        )
    }
    
    // Method to send timer updates to Flutter
    fun sendTimerUpdate(isRunning: Boolean, isPaused: Boolean, remainingSeconds: Int, totalSeconds: Int, bookTitle: String) {
        eventSink?.success(mapOf(
            "isRunning" to isRunning,
            "isPaused" to isPaused,
            "remainingSeconds" to remainingSeconds,
            "totalSeconds" to totalSeconds,
            "bookTitle" to bookTitle
        ))
    }
    
    // Static method for service to call
    companion object {
        private var staticEventSink: EventSink? = null
        
        fun sendTimerUpdateStatic(isRunning: Boolean, isPaused: Boolean, remainingSeconds: Int, totalSeconds: Int, bookTitle: String) {
            staticEventSink?.success(mapOf(
                "isRunning" to isRunning,
                "isPaused" to isPaused,
                "remainingSeconds" to remainingSeconds,
                "totalSeconds" to totalSeconds,
                "bookTitle" to bookTitle
            ))
        }
    }

    private fun startTimerService(totalSeconds: Int, bookTitle: String) {
        val intent = Intent(this, ReadingTimerService::class.java).apply {
            action = "START_TIMER"
            putExtra("total_seconds", totalSeconds)
            putExtra("book_title", bookTitle)
        }
        startForegroundService(intent)
    }

    private fun pauseTimerService() {
        val intent = Intent(this, ReadingTimerService::class.java).apply {
            action = "PAUSE_TIMER"
        }
        startService(intent)
    }

    private fun resumeTimerService() {
        val intent = Intent(this, ReadingTimerService::class.java).apply {
            action = "RESUME_TIMER"
        }
        startService(intent)
    }

    private fun stopTimerService() {
        val intent = Intent(this, ReadingTimerService::class.java).apply {
            action = "STOP_TIMER"
        }
        startService(intent)
    }

    private fun getTimerState(): Map<String, Any> {
        // For now, return a simple state - we'll improve this later
        // The issue is that service binding is asynchronous
        return try {
            // Check if service is running by looking at SharedPreferences
            val prefs = getSharedPreferences("reading_timer_service", Context.MODE_PRIVATE)
            val isRunning = prefs.getBoolean("is_running", false)
            val isPaused = prefs.getBoolean("is_paused", false)
            val totalSeconds = prefs.getInt("total_seconds", 0)
            val startTime = prefs.getLong("start_time", 0)
            val bookTitle = prefs.getString("book_title", "") ?: ""
            
            if (isRunning && startTime > 0 && totalSeconds > 0) {
                val remainingSeconds = if (isPaused) {
                    prefs.getInt("remaining_seconds", totalSeconds)
                } else {
                    val elapsedSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt()
                    (totalSeconds - elapsedSeconds).coerceAtLeast(0)
                }
                
                mapOf(
                    "isRunning" to (remainingSeconds > 0),
                    "isPaused" to isPaused,
                    "remainingSeconds" to remainingSeconds,
                    "totalSeconds" to totalSeconds,
                    "bookTitle" to bookTitle
                )
            } else {
                mapOf(
                    "isRunning" to false,
                    "isPaused" to false,
                    "remainingSeconds" to 0,
                    "totalSeconds" to 0,
                    "bookTitle" to ""
                )
            }
        } catch (e: Exception) {
            mapOf(
                "isRunning" to false,
                "isPaused" to false,
                "remainingSeconds" to 0,
                "totalSeconds" to 0,
                "bookTitle" to ""
            )
        }
    }
}
