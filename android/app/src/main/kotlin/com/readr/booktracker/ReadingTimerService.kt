package com.readr.booktracker

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.CountDownTimer
import androidx.core.app.NotificationCompat

class ReadingTimerService : Service() {
    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "reading_timer_foreground"
        private const val CHANNEL_NAME = "Reading Timer"
        private const val CHANNEL_DESCRIPTION = "Ongoing reading timer notifications"
    }

    private val binder = TimerBinder()
    private var countDownTimer: CountDownTimer? = null
    private var totalSeconds = 0
    private var remainingSeconds = 0
    private var bookTitle = ""
    private var isRunning = false

    inner class TimerBinder : Binder() {
        fun getService(): ReadingTimerService = this@ReadingTimerService
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START_TIMER" -> {
                val totalSeconds = intent.getIntExtra("total_seconds", 0)
                val bookTitle = intent.getStringExtra("book_title") ?: ""
                startTimer(totalSeconds, bookTitle)
            }
            "STOP_TIMER" -> {
                stopTimer()
            }
        }
        return START_STICKY // This is the key - service will restart if killed
    }

    private fun startTimer(totalSeconds: Int, bookTitle: String) {
        this.totalSeconds = totalSeconds
        this.remainingSeconds = totalSeconds
        this.bookTitle = bookTitle
        this.isRunning = true

        // Start foreground service
        startForeground(NOTIFICATION_ID, buildNotification())

        // Start countdown timer
        countDownTimer = object : CountDownTimer(totalSeconds * 1000L, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                remainingSeconds = (millisUntilFinished / 1000).toInt()
                updateNotification()
            }

            override fun onFinish() {
                onTimerCompleted()
            }
        }.start()
    }

    private fun stopTimer() {
        isRunning = false
        countDownTimer?.cancel()
        countDownTimer = null
        stopForeground(true)
        stopSelf()
    }

    private fun onTimerCompleted() {
        isRunning = false
        countDownTimer?.cancel()
        countDownTimer = null
        
        // Show completion notification
        showCompletionNotification()
        
        // Stop the service
        stopForeground(true)
        stopSelf()
    }

    private fun buildNotification(): Notification {
        createNotificationChannel()
        
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
    }

    private fun showCompletionNotification() {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = CHANNEL_DESCRIPTION
                enableVibration(false)
                setShowBadge(false)
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    // Getters for Flutter to access timer state
    fun getRemainingSeconds(): Int = remainingSeconds
    fun getTotalSeconds(): Int = totalSeconds
    fun isTimerRunning(): Boolean = isRunning
    fun getBookTitle(): String = bookTitle
}
