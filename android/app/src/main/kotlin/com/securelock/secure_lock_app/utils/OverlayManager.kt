package com.securelock.secure_lock_app.utils

import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.util.Log
import android.view.Gravity
import android.view.WindowManager
import android.widget.FrameLayout
import com.securelock.secure_lock_app.MainActivity

/**
 * Manages the lock screen overlay using SYSTEM_ALERT_WINDOW
 * Creates an unbreakable overlay that forces authentication
 */
object OverlayManager {
    private const val TAG = "OverlayManager"
    private var overlayView: FrameLayout? = null
    private var windowManager: WindowManager? = null
    private var isOverlayShowing = false

    /**
     * Show lock screen overlay for a locked app
     */
    fun showLockScreen(context: Context, packageName: String) {
        if (isOverlayShowing) {
            Log.d(TAG, "Overlay already showing, ignoring")
            return
        }

        try {
            // Instead of creating a transparent overlay, launch the Flutter app
            // with a deep link to show the lock screen
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_NO_ANIMATION
                putExtra("show_lock_screen", true)
                putExtra("locked_package", packageName)
                putExtra("locked_app_name", getAppName(context, packageName))
            }
            context.startActivity(intent)
            isOverlayShowing = true

            Log.d(TAG, "Lock screen launched for package: $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "Error showing lock screen", e)
        }
    }

    /**
     * Hide the lock screen overlay
     */
    fun hideLockScreen(context: Context) {
        try {
            if (overlayView != null && windowManager != null) {
                windowManager?.removeView(overlayView)
                overlayView = null
                windowManager = null
            }
            isOverlayShowing = false
            Log.d(TAG, "Lock screen hidden")
        } catch (e: Exception) {
            Log.e(TAG, "Error hiding lock screen", e)
            // Force reset
            overlayView = null
            windowManager = null
            isOverlayShowing = false
        }
    }

    /**
     * Check if overlay is currently showing
     */
    fun isShowing(): Boolean = isOverlayShowing

    /**
     * Create overlay window parameters
     */
    private fun createLayoutParams(): WindowManager.LayoutParams {
        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        return WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }
    }

    /**
     * Get app name from package name
     */
    private fun getAppName(context: Context, packageName: String): String {
        return try {
            val pm = context.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: Exception) {
            packageName
        }
    }

    /**
     * Reset overlay state (for cleanup)
     */
    fun reset() {
        overlayView = null
        windowManager = null
        isOverlayShowing = false
    }
}
