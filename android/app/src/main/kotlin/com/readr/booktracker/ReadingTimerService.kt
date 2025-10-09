package com.readr.booktracker

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.CountDownTimer
import androidx.core.app.NotificationCompat
import com.readr.booktracker.MainActivity

class ReadingTimerService : Service() {
    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "reading_timer_foreground"
        private const val CHANNEL_NAME = "Reading Timer"
        private const val CHANNEL_DESCRIPTION = "Ongoing reading timer notifications"
        
        private const val COMPLETION_CHANNEL_ID = "reading_timer_complete"
        private const val COMPLETION_CHANNEL_NAME = "Reading Timer Complete"
        private const val COMPLETION_CHANNEL_DESCRIPTION = "Reading timer completion notifications"
        
        // SharedPreferences keys
        private const val PREFS_NAME = "reading_timer_service"
        private const val KEY_IS_RUNNING = "is_running"
        private const val KEY_START_TIME = "start_time"
        private const val KEY_TOTAL_SECONDS = "total_seconds"
        private const val KEY_BOOK_TITLE = "book_title"
    }

    private val binder = TimerBinder()
    private var countDownTimer: CountDownTimer? = null
    private var totalSeconds = 0
    private var remainingSeconds = 0
    private var bookTitle = ""
    private var isRunning = false
    private var isStopped = false // Guard against double-stop
    private var channelsCreated = false // Track if channels are already created
    
    private lateinit var prefs: SharedPreferences

    inner class TimerBinder : Binder() {
        fun getService(): ReadingTimerService = this@ReadingTimerService
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Start foreground immediately to avoid timeout
        startForeground(NOTIFICATION_ID, buildNotification())
        
        when (intent?.action) {
            "START_TIMER" -> {
                val totalSeconds = intent.getIntExtra("total_seconds", 0)
                val bookTitle = intent.getStringExtra("book_title") ?: ""
                startTimer(totalSeconds, bookTitle)
            }
            "STOP_TIMER" -> {
                stopTimer()
            }
            null -> {
                // Service was restarted by START_STICKY, try to restore state
                restoreTimerState()
            }
        }
        return START_STICKY // This is the key - service will restart if killed
    }

    private fun startTimer(totalSeconds: Int, bookTitle: String) {
        this.totalSeconds = totalSeconds
        this.remainingSeconds = totalSeconds
        this.bookTitle = bookTitle
        this.isRunning = true
        this.isStopped = false

        // Create notification channels first (only once)
        createNotificationChannel()

        // Start foreground service with initial notification
        startForeground(NOTIFICATION_ID, buildNotification())

        // Persist state
        saveTimerState()

        // Start countdown timer
        countDownTimer = object : CountDownTimer(totalSeconds * 1000L, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                remainingSeconds = (millisUntilFinished / 1000).toInt()
                updateNotification()
                // Send update to Flutter
                sendUpdateToFlutter()
            }

            override fun onFinish() {
                onTimerCompleted()
            }
        }.start()
    }

    private fun stopTimer() {
        if (isStopped) return // Guard against double-stop
        
        isStopped = true
        isRunning = false
        countDownTimer?.cancel()
        countDownTimer = null
        
        // Clear persisted state
        clearTimerState()
        
        // Only show completion notification if timer was actually running
        if (totalSeconds > 0) {
            showCompletionNotification()
        }
        
        stopForeground(true)
        stopSelf()
    }

    private fun onTimerCompleted() {
        if (isStopped) return // Guard against double-completion
        
        isStopped = true
        isRunning = false
        countDownTimer?.cancel()
        countDownTimer = null
        
        // Clear persisted state
        clearTimerState()
        
        // Show completion notification
        showCompletionNotification()
        
        // Stop the service
        stopForeground(true)
        stopSelf()
    }

    private fun buildNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("📚 Reading Timer")
            .setContentText(getNotificationText())
            .setSmallIcon(R.drawable.ic_stat_name)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setAutoCancel(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun updateNotification() {
        val notification = buildNotification()
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
        android.util.Log.d("ReadingTimerService", "📱 Updated notification: ${getNotificationText()}")
    }

    private fun showCompletionNotification() {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, COMPLETION_CHANNEL_ID)
            .setContentTitle("Reading Session Complete!")
            .setContentText("Your reading timer has finished. Tap to update your progress.")
            .setSmallIcon(R.drawable.ic_stat_name)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(888, notification) // Different ID for completion
    }

    private fun getNotificationText(): String {
        val minutes = remainingSeconds / 60
        val seconds = remainingSeconds % 60
        val timeText = String.format("%02d:%02d remaining", minutes, seconds)
        
        return if (bookTitle.isNotEmpty()) {
            "Reading: $bookTitle - $timeText"
        } else {
            "Reading Timer - $timeText"
        }
    }

    private fun createNotificationChannel() {
        if (channelsCreated) return // Skip if already created
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Low importance channel for ongoing timer notifications
            val timerChannel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = CHANNEL_DESCRIPTION
                enableVibration(false)
                setShowBadge(false)
            }
            
            // High importance channel for completion notifications
            val completionChannel = NotificationChannel(
                COMPLETION_CHANNEL_ID,
                COMPLETION_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = COMPLETION_CHANNEL_DESCRIPTION
                enableVibration(true)
                setShowBadge(true)
            }
            
            notificationManager.createNotificationChannel(timerChannel)
            notificationManager.createNotificationChannel(completionChannel)
            channelsCreated = true
            android.util.Log.d("ReadingTimerService", "📱 Created notification channels")
        }
    }

    // Getters for Flutter to access timer state
    fun getRemainingSeconds(): Int = remainingSeconds
    fun getTotalSeconds(): Int = totalSeconds
    fun isTimerRunning(): Boolean = isRunning
    fun getBookTitle(): String = bookTitle

    // Send update to Flutter via static reference
    private fun sendUpdateToFlutter() {
        try {
            MainActivity.sendTimerUpdateStatic(isRunning, remainingSeconds, totalSeconds, bookTitle)
        } catch (e: Exception) {
            // MainActivity might not be available, that's okay
        }
    }

    // State persistence methods
    private fun saveTimerState() {
        prefs.edit().apply {
            putBoolean(KEY_IS_RUNNING, isRunning)
            putLong(KEY_START_TIME, System.currentTimeMillis())
            putInt(KEY_TOTAL_SECONDS, totalSeconds)
            putString(KEY_BOOK_TITLE, bookTitle)
            apply()
        }
    }

    private fun clearTimerState() {
        prefs.edit().clear().apply()
    }

    private fun restoreTimerState() {
        val wasRunning = prefs.getBoolean(KEY_IS_RUNNING, false)
        if (!wasRunning) return

        val startTime = prefs.getLong(KEY_START_TIME, 0)
        val savedTotalSeconds = prefs.getInt(KEY_TOTAL_SECONDS, 0)
        val savedBookTitle = prefs.getString(KEY_BOOK_TITLE, "") ?: ""

        if (startTime == 0L || savedTotalSeconds == 0) return

        val elapsedSeconds = ((System.currentTimeMillis() - startTime) / 1000).toInt()
        val remaining = savedTotalSeconds - elapsedSeconds

        if (remaining <= 0) {
            // Timer should have completed
            clearTimerState()
            showCompletionNotification()
            stopSelf()
            return
        }

        // Restore timer with remaining time
        this.totalSeconds = savedTotalSeconds
        this.remainingSeconds = remaining
        this.bookTitle = savedBookTitle
        this.isRunning = true
        this.isStopped = false

        // Start foreground service
        startForeground(NOTIFICATION_ID, buildNotification())

        // Start countdown timer with remaining time
        countDownTimer = object : CountDownTimer(remaining * 1000L, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                remainingSeconds = (millisUntilFinished / 1000).toInt()
                updateNotification()
            }

            override fun onFinish() {
                onTimerCompleted()
            }
        }.start()
    }
}
