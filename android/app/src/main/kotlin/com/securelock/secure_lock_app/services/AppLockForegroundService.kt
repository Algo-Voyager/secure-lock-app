package com.securelock.secure_lock_app.services

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.securelock.secure_lock_app.MainActivity
import com.securelock.secure_lock_app.R
import com.securelock.secure_lock_app.utils.UsageStatsHelper

/**
 * Foreground Service for continuous app monitoring
 * Ensures the app lock functionality is always active
 */
class AppLockForegroundService : Service() {

    companion object {
        private const val TAG = "AppLockForeground"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "app_lock_service_channel"
        const val ACTION_START_SERVICE = "com.securelock.secure_lock_app.START_SERVICE"
        const val ACTION_STOP_SERVICE = "com.securelock.secure_lock_app.STOP_SERVICE"
        const val ACTION_SHOW_LOCK_SCREEN = "com.securelock.secure_lock_app.SHOW_LOCK_SCREEN"
        const val EXTRA_PACKAGE_NAME = "package_name"

        var isServiceRunning = false
            private set
    }

    private val handler = Handler(Looper.getMainLooper())
    private val monitoringRunnable = object : Runnable {
        override fun run() {
            monitorForegroundApp()
            handler.postDelayed(this, 1000) // Check every 1 second
        }
    }

    private var lastCheckedPackage: String? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service onCreate")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_SERVICE -> {
                Log.d(TAG, "Starting foreground service")
                startForegroundService()
            }
            ACTION_STOP_SERVICE -> {
                Log.d(TAG, "Stopping foreground service")
                stopForegroundService()
            }
            ACTION_SHOW_LOCK_SCREEN -> {
                val packageName = intent.getStringExtra(EXTRA_PACKAGE_NAME)
                if (packageName != null) {
                    showLockScreenForPackage(packageName)
                }
            }
        }

        return START_STICKY // Service will be restarted if killed
    }

    private fun startForegroundService() {
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)
        isServiceRunning = true

        // Start monitoring foreground apps
        handler.post(monitoringRunnable)

        Log.d(TAG, "Foreground service started")
    }

    private fun stopForegroundService() {
        handler.removeCallbacks(monitoringRunnable)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        isServiceRunning = false

        Log.d(TAG, "Foreground service stopped")
    }

    private fun monitorForegroundApp() {
        try {
            val currentPackage = UsageStatsHelper.getForegroundApp(this)

            if (currentPackage != null && currentPackage != lastCheckedPackage) {
                lastCheckedPackage = currentPackage

                // Ignore system apps and our own app
                if (currentPackage == packageName) return

                Log.d(TAG, "Current foreground app: $currentPackage")

                // Check if this app is locked
                // This is a backup to the Accessibility Service
                // Will be implemented through PreferencesHelper
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error monitoring foreground app", e)
        }
    }

    private fun showLockScreenForPackage(packageName: String) {
        Log.d(TAG, "Showing lock screen for: $packageName")

        // Launch lock screen overlay activity
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("show_lock_screen", true)
            putExtra("locked_package", packageName)
        }
        startActivity(intent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "App Lock Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps your apps secured"
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_SECRET
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("App Lock Active")
            .setContentText("Your apps are protected")
            .setSmallIcon(android.R.drawable.ic_lock_lock) // Will be replaced with custom icon
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(monitoringRunnable)
        isServiceRunning = false
        Log.d(TAG, "Service destroyed")

        // Restart service if it was stopped unexpectedly
        val restartIntent = Intent(this, AppLockForegroundService::class.java).apply {
            action = ACTION_START_SERVICE
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(restartIntent)
        } else {
            startService(restartIntent)
        }
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        // Service should continue running even if app is removed from recent tasks
        Log.d(TAG, "Task removed, service continues")
    }
}
