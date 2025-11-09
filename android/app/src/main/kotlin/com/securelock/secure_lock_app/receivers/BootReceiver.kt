package com.securelock.secure_lock_app.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.securelock.secure_lock_app.services.AppLockForegroundService

/**
 * Boot Receiver to start the app lock service when device boots
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON" -> {
                Log.d(TAG, "Boot completed, starting service")
                startAppLockService(context)
            }
        }
    }

    private fun startAppLockService(context: Context) {
        try {
            val serviceIntent = Intent(context, AppLockForegroundService::class.java).apply {
                action = AppLockForegroundService.ACTION_START_SERVICE
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }

            Log.d(TAG, "App lock service started on boot")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting service on boot", e)
        }
    }
}
