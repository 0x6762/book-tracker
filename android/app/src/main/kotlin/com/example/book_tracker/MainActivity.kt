package com.readr.booktracker

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
        // This would require binding to the service to get real-time state
        // For now, return basic state
        return mapOf(
            "isRunning" to false,
            "remainingSeconds" to 0,
            "totalSeconds" to 0,
            "bookTitle" to ""
        )
    }
}
