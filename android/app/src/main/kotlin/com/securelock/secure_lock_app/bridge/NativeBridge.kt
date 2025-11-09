package com.securelock.secure_lock_app.bridge

import android.app.Activity
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import com.securelock.secure_lock_app.receivers.AppLockDeviceAdmin
import com.securelock.secure_lock_app.services.AppLockAccessibilityService
import com.securelock.secure_lock_app.services.AppLockForegroundService
import com.securelock.secure_lock_app.utils.PreferencesHelper
import com.securelock.secure_lock_app.utils.UsageStatsHelper
import io.flutter.plugin.common.MethodChannel
import com.securelock.secure_lock_app.bridge.ChannelBridge

/**
 * Bridge between Flutter and Native Android code
 */
class NativeBridge(private val activity: Activity) {

    companion object {
        const val CHANNEL = "com.securelock.app/lock"
        private const val TAG = "NativeBridge"

        // Request codes
        const val REQUEST_CODE_OVERLAY_PERMISSION = 1001
        const val REQUEST_CODE_USAGE_STATS_PERMISSION = 1002
        const val REQUEST_CODE_DEVICE_ADMIN = 1003
        const val REQUEST_CODE_ACCESSIBILITY_SETTINGS = 1004
    }

    private val context: Context = activity.applicationContext
    private val prefsHelper = PreferencesHelper(context)

    /**
     * Handle method calls from Flutter
     */
    fun handleMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startForegroundService" -> startForegroundService(result)
            "stopForegroundService" -> stopForegroundService(result)
            "isServiceRunning" -> isServiceRunning(result)
            "getCurrentApp" -> getCurrentApp(result)
            "getInstalledApps" -> getInstalledApps(result)
            "isAppLocked" -> {
                val packageName = call.argument<String>("packageName")
                isAppLocked(packageName, result)
            }
            "lockApp" -> {
                val packageName = call.argument<String>("packageName")
                lockApp(packageName, result)
            }
            "unlockApp" -> {
                val packageName = call.argument<String>("packageName")
                unlockApp(packageName, result)
            }
            "getLockedApps" -> getLockedApps(result)
            "hasOverlayPermission" -> hasOverlayPermission(result)
            "requestOverlayPermission" -> requestOverlayPermission(result)
            "hasUsageStatsPermission" -> hasUsageStatsPermission(result)
            "requestUsageStatsPermission" -> requestUsageStatsPermission(result)
            "isAccessibilityServiceEnabled" -> isAccessibilityServiceEnabled(result)
            "openAccessibilitySettings" -> openAccessibilitySettings(result)
            "isDeviceAdminActive" -> isDeviceAdminActive(result)
            "requestDeviceAdmin" -> requestDeviceAdmin(result)
            "launchApp" -> {
                val packageName = call.argument<String>("packageName")
                launchApp(packageName, result)
            }
            "onUnlockSuccess" -> {
                val packageName = call.argument<String>("packageName")
                onUnlockSuccess(packageName, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun startForegroundService(result: MethodChannel.Result) {
        try {
            val intent = Intent(context, AppLockForegroundService::class.java).apply {
                action = AppLockForegroundService.ACTION_START_SERVICE
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }

            result.success(true)
            ChannelBridge.debugLog("Requested start of foreground service", tag = TAG)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting foreground service", e)
            result.error("SERVICE_ERROR", e.message, null)
            ChannelBridge.debugLog("Start service error: ${e.message}", level = "error", tag = TAG)
        }
    }

    private fun stopForegroundService(result: MethodChannel.Result) {
        try {
            val intent = Intent(context, AppLockForegroundService::class.java).apply {
                action = AppLockForegroundService.ACTION_STOP_SERVICE
            }
            context.startService(intent)
            result.success(true)
            ChannelBridge.debugLog("Requested stop of foreground service", tag = TAG)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping foreground service", e)
            result.error("SERVICE_ERROR", e.message, null)
            ChannelBridge.debugLog("Stop service error: ${e.message}", level = "error", tag = TAG)
        }
    }

    private fun isServiceRunning(result: MethodChannel.Result) {
        result.success(AppLockForegroundService.isServiceRunning)
    }

    private fun getCurrentApp(result: MethodChannel.Result) {
        val currentApp = UsageStatsHelper.getForegroundApp(context)
        result.success(currentApp)
        ChannelBridge.debugLog("getCurrentApp -> ${currentApp ?: "null"}", level = "debug", tag = TAG)
    }

    private fun getInstalledApps(result: MethodChannel.Result) {
        try {
            val packageManager = context.packageManager
            val packages = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

            val appList = packages
                .filter { (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 } // Filter out system apps
                .mapNotNull { appInfo ->
                    try {
                        mapOf(
                            "packageName" to appInfo.packageName,
                            "appName" to packageManager.getApplicationLabel(appInfo).toString(),
                            "icon" to appInfo.icon
                        )
                    } catch (e: Exception) {
                        null
                    }
                }
                .sortedBy { it["appName"] as String }

            result.success(appList)
            ChannelBridge.debugLog("Installed apps fetched: ${appList.size}", level = "debug", tag = TAG)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting installed apps", e)
            result.error("APPS_ERROR", e.message, null)
            ChannelBridge.debugLog("Installed apps error: ${e.message}", level = "error", tag = TAG)
        }
    }

    private fun isAppLocked(packageName: String?, result: MethodChannel.Result) {
        if (packageName == null) {
            result.error("INVALID_ARGUMENT", "Package name is required", null)
            return
        }
        result.success(prefsHelper.isAppLocked(packageName))
        ChannelBridge.debugLog("isAppLocked($packageName)", level = "debug", tag = TAG)
    }

    private fun lockApp(packageName: String?, result: MethodChannel.Result) {
        if (packageName == null) {
            result.error("INVALID_ARGUMENT", "Package name is required", null)
            return
        }
        prefsHelper.lockApp(packageName)
        result.success(true)
        ChannelBridge.debugLog("Locked app $packageName", level = "success", tag = TAG)
    }

    private fun unlockApp(packageName: String?, result: MethodChannel.Result) {
        if (packageName == null) {
            result.error("INVALID_ARGUMENT", "Package name is required", null)
            return
        }
        prefsHelper.unlockApp(packageName)
        result.success(true)
        ChannelBridge.debugLog("Unlocked app $packageName", level = "warning", tag = TAG)
    }

    private fun getLockedApps(result: MethodChannel.Result) {
        val lockedApps = prefsHelper.getLockedApps().toList()
        result.success(lockedApps)
        ChannelBridge.debugLog("Locked apps -> ${lockedApps.size}", level = "debug", tag = TAG)
    }

    private fun hasOverlayPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            result.success(Settings.canDrawOverlays(context))
            ChannelBridge.debugLog("Overlay permission -> ${Settings.canDrawOverlays(context)}", level = "debug", tag = TAG)
        } else {
            result.success(true)
            ChannelBridge.debugLog("Overlay permission -> true (SDK<23)", level = "debug", tag = TAG)
        }
    }

    private fun requestOverlayPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(context)) {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:${context.packageName}")
                )
                activity.startActivityForResult(intent, REQUEST_CODE_OVERLAY_PERMISSION)
                result.success(true)
                ChannelBridge.debugLog("Overlay permission requested", tag = TAG)
            } else {
                result.success(false) // Already has permission
                ChannelBridge.debugLog("Overlay permission already granted", level = "debug", tag = TAG)
            }
        } else {
            result.success(false)
            ChannelBridge.debugLog("Overlay permission request not supported", level = "warning", tag = TAG)
        }
    }

    private fun hasUsageStatsPermission(result: MethodChannel.Result) {
        result.success(UsageStatsHelper.hasUsageStatsPermission(context))
        ChannelBridge.debugLog("Usage stats perm -> ${UsageStatsHelper.hasUsageStatsPermission(context)}", level = "debug", tag = TAG)
    }

    private fun requestUsageStatsPermission(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            activity.startActivityForResult(intent, REQUEST_CODE_USAGE_STATS_PERMISSION)
            result.success(true)
            ChannelBridge.debugLog("Usage stats permission requested", tag = TAG)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening usage stats settings", e)
            result.error("PERMISSION_ERROR", e.message, null)
            ChannelBridge.debugLog("Usage stats request error: ${e.message}", level = "error", tag = TAG)
        }
    }

    private fun isAccessibilityServiceEnabled(result: MethodChannel.Result) {
        result.success(AppLockAccessibilityService.isServiceRunning)
        ChannelBridge.debugLog("Accessibility running -> ${AppLockAccessibilityService.isServiceRunning}", level = "debug", tag = TAG)
    }

    private fun openAccessibilitySettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            activity.startActivityForResult(intent, REQUEST_CODE_ACCESSIBILITY_SETTINGS)
            result.success(true)
            ChannelBridge.debugLog("Opened accessibility settings", tag = TAG)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening accessibility settings", e)
            result.error("PERMISSION_ERROR", e.message, null)
            ChannelBridge.debugLog("Open accessibility error: ${e.message}", level = "error", tag = TAG)
        }
    }

    private fun isDeviceAdminActive(result: MethodChannel.Result) {
        val devicePolicyManager = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(context, AppLockDeviceAdmin::class.java)
        result.success(devicePolicyManager.isAdminActive(componentName))
        ChannelBridge.debugLog("Device admin active -> ${devicePolicyManager.isAdminActive(componentName)}", level = "debug", tag = TAG)
    }

    private fun requestDeviceAdmin(result: MethodChannel.Result) {
        try {
            val componentName = ComponentName(context, AppLockDeviceAdmin::class.java)
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
                putExtra(
                    DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                    "Device admin is required to prevent uninstallation and protect your locked apps"
                )
            }
            activity.startActivityForResult(intent, REQUEST_CODE_DEVICE_ADMIN)
            result.success(true)
            ChannelBridge.debugLog("Requested device admin", tag = TAG)
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting device admin", e)
            result.error("PERMISSION_ERROR", e.message, null)
            ChannelBridge.debugLog("Device admin request error: ${e.message}", level = "error", tag = TAG)
        }
    }

    private fun onUnlockSuccess(packageName: String?, result: MethodChannel.Result) {
        try {
            val target = packageName ?: com.securelock.secure_lock_app.services.AppLockForegroundService.lastLockedPackage
            target?.let { pkg ->
                // Apply grace period to prevent immediate re-lock
                com.securelock.secure_lock_app.utils.UnlockState.allow(pkg)
                ChannelBridge.debugLog("Unlock success for $pkg (grace applied)", tag = TAG)
            }

            // Simply finish the activity - the target app is already running in background
            // and will naturally come to foreground when we finish
            try {
                activity.finishAndRemoveTask()
            } catch (_: Exception) {
                activity.finish()
            }

            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error handling unlock success", e)
            result.error("UNLOCK_ERROR", e.message, null)
            ChannelBridge.debugLog("Unlock success error: ${e.message}", level = "error", tag = TAG)
        }
    }

    private fun launchApp(packageName: String?, result: MethodChannel.Result) {
        if (packageName == null) {
            result.error("INVALID_ARGUMENT", "Package name is required", null)
            return
        }

        try {
            val packageManager = context.packageManager
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)

            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                context.startActivity(launchIntent)
                result.success(true)
                ChannelBridge.debugLog("Launched app: $packageName", level = "success", tag = TAG)
            } else {
                result.error("APP_NOT_FOUND", "App not found: $packageName", null)
                ChannelBridge.debugLog("App not found: $packageName", level = "error", tag = TAG)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error launching app: $packageName", e)
            result.error("LAUNCH_ERROR", e.message, null)
            ChannelBridge.debugLog("Launch error: ${e.message}", level = "error", tag = TAG)
        }
    }
}
