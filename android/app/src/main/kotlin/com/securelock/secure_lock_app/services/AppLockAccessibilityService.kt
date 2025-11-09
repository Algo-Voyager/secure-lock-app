package com.securelock.secure_lock_app.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.os.Build
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import com.securelock.secure_lock_app.utils.PreferencesHelper
import com.securelock.secure_lock_app.bridge.ChannelBridge
import com.securelock.secure_lock_app.utils.UnlockState
import com.securelock.secure_lock_app.utils.FlowLogger

/**
 * Accessibility Service to detect when users switch to locked apps
 * This is the primary method for real-time app detection
 */
class AppLockAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "AppLockAccessibility"
        const val ACTION_APP_OPENED = "com.securelock.secure_lock_app.APP_OPENED"
        const val EXTRA_PACKAGE_NAME = "package_name"

        var isServiceRunning = false
            private set
    }

    override fun onServiceConnected() {
        super.onServiceConnected()

        val info = AccessibilityServiceInfo().apply {
            // Set the type of events that this service wants to listen to
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                        AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED

            // Set the type of feedback your service will provide
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC

            // Set flags
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS

            // Set how long to wait before processing events (in milliseconds)
            notificationTimeout = 100
        }

        this.serviceInfo = info
        isServiceRunning = true

        Log.d(TAG, "✓ Accessibility Service Connected - Monitoring app switches")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                handleWindowStateChanged(event)
            }
        }
    }

    private fun handleWindowStateChanged(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString()
        val className = event.className?.toString()

        if (packageName.isNullOrEmpty()) return

        // Ignore our own app
        if (packageName == this.packageName) return

        // Ignore system UI and launcher
        if (packageName.startsWith("com.android.systemui") ||
            packageName.startsWith("com.android.launcher") ||
            packageName.startsWith("com.google.android.apps.nexuslauncher")) {
            return
        }

        // Notify UnlockState about app switch (clears grace for other apps)
        val lastApp = UnlockState.getLastForegroundApp()
        val graceCleared = UnlockState.onAppSwitch(packageName)

        if (graceCleared.isNotEmpty()) {
            FlowLogger.logAppSwitch(lastApp, packageName, graceCleared)
        }

        // Check if this app is locked and not temporarily allowed
        if (!UnlockState.isAllowed(packageName) && isAppLocked(packageName)) {
            FlowLogger.startFlow(packageName, "Auto (Accessibility Service)")

            // Broadcast to Flutter app
            broadcastAppOpened(packageName)

            // Show lock screen overlay
            showLockScreen(packageName)
        }
    }

    private fun isAppLocked(packageName: String): Boolean {
        val prefsHelper = PreferencesHelper(this)
        return prefsHelper.isAppLocked(packageName)
    }

    private fun broadcastAppOpened(packageName: String) {
        val intent = Intent(ACTION_APP_OPENED).apply {
            putExtra(EXTRA_PACKAGE_NAME, packageName)
            setPackage(this@AppLockAccessibilityService.packageName)
        }
        sendBroadcast(intent)
    }

    private fun showLockScreen(packageName: String) {
        // Send to overlay service to show lock screen
        val intent = Intent(this, AppLockForegroundService::class.java).apply {
            action = AppLockForegroundService.ACTION_SHOW_LOCK_SCREEN
            putExtra(EXTRA_PACKAGE_NAME, packageName)
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            FlowLogger.logStep("Lock Screen Request Sent", "via Accessibility Service")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error starting lock screen: ${e.message}")
        }
    }

    override fun onInterrupt() {
        // Service interrupted - no action needed
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
        Log.w(TAG, "⚠ Accessibility Service Destroyed")
    }
}
