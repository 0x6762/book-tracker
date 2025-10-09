package com.readr.booktracker

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "reading_timer/native_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startTimer" -> {
                    val totalSeconds = call.argument<Int>("totalSeconds") ?: 0
                    val bookTitle = call.argument<String>("bookTitle") ?: ""
                    startTimerService(totalSeconds, bookTitle)
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
    }

    private fun startTimerService(totalSeconds: Int, bookTitle: String) {
        val intent = Intent(this, ReadingTimerService::class.java).apply {
            action = "START_TIMER"
            putExtra("total_seconds", totalSeconds)
            putExtra("book_title", bookTitle)
        }
        startForegroundService(intent)
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
            val totalSeconds = prefs.getInt("total_seconds", 0)
            val startTime = prefs.getLong("start_time", 0)
            val bookTitle = prefs.getString("book_title", "") ?: ""
            
            if (isRunning && startTime > 0 && totalSeconds > 0) {
                val elapsedSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt()
                val remainingSeconds = (totalSeconds - elapsedSeconds).coerceAtLeast(0)
                
                mapOf(
                    "isRunning" to (remainingSeconds > 0),
                    "remainingSeconds" to remainingSeconds,
                    "totalSeconds" to totalSeconds,
                    "bookTitle" to bookTitle
                )
            } else {
                mapOf(
                    "isRunning" to false,
                    "remainingSeconds" to 0,
                    "totalSeconds" to 0,
                    "bookTitle" to ""
                )
            }
        } catch (e: Exception) {
            mapOf(
                "isRunning" to false,
                "remainingSeconds" to 0,
                "totalSeconds" to 0,
                "bookTitle" to ""
            )
        }
    }
}
