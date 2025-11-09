package com.securelock.secure_lock_app.receivers

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Device Admin Receiver to prevent app uninstallation
 * Users must first disable device admin before they can uninstall the app
 */
class AppLockDeviceAdmin : DeviceAdminReceiver() {

    companion object {
        private const val TAG = "AppLockDeviceAdmin"
    }

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Log.d(TAG, "Device Admin Enabled")
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        Log.d(TAG, "Device Admin Disabled")
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        Log.d(TAG, "Device Admin Disable Requested")
        return "Disabling device admin will allow anyone to uninstall the app. Are you sure?"
    }

    override fun onPasswordChanged(context: Context, intent: Intent) {
        super.onPasswordChanged(context, intent)
        Log.d(TAG, "Device password changed")
    }

    override fun onPasswordFailed(context: Context, intent: Intent) {
        super.onPasswordFailed(context, intent)
        Log.d(TAG, "Device password failed")
    }

    override fun onPasswordSucceeded(context: Context, intent: Intent) {
        super.onPasswordSucceeded(context, intent)
        Log.d(TAG, "Device password succeeded")
    }
}
