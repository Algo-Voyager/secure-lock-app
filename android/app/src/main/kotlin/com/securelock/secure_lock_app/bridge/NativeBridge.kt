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
import com.securelock.secure_lock_app.utils.FlowLogger

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
        } catch (e: Exception) {
            Log.e(TAG, "Error starting foreground service", e)
            result.error("SERVICE_ERROR", e.message, null)
        }
    }

    private fun stopForegroundService(result: MethodChannel.Result) {
        try {
            val intent = Intent(context, AppLockForegroundService::class.java).apply {
                action = AppLockForegroundService.ACTION_STOP_SERVICE
            }
            context.startService(intent)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping foreground service", e)
            result.error("SERVICE_ERROR", e.message, null)
        }
    }

    private fun isServiceRunning(result: MethodChannel.Result) {
        result.success(AppLockForegroundService.isServiceRunning)
    }

    private fun getCurrentApp(result: MethodChannel.Result) {
        val currentApp = UsageStatsHelper.getForegroundApp(context)
        result.success(currentApp)
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
        } catch (e: Exception) {
            Log.e(TAG, "Error getting installed apps", e)
            result.error("APPS_ERROR", e.message, null)
        }
    }

    private fun isAppLocked(packageName: String?, result: MethodChannel.Result) {
        if (packageName == null) {
            result.error("INVALID_ARGUMENT", "Package name is required", null)
            return
        }
        result.success(prefsHelper.isAppLocked(packageName))
    }

    private fun lockApp(packageName: String?, result: MethodChannel.Result) {
        if (packageName == null) {
            result.error("INVALID_ARGUMENT", "Package name is required", null)
            return
        }
        prefsHelper.lockApp(packageName)
        result.success(true)
    }

    private fun unlockApp(packageName: String?, result: MethodChannel.Result) {
        if (packageName == null) {
            result.error("INVALID_ARGUMENT", "Package name is required", null)
            return
        }
        prefsHelper.unlockApp(packageName)
        result.success(true)
    }

    private fun getLockedApps(result: MethodChannel.Result) {
        val lockedApps = prefsHelper.getLockedApps().toList()
        result.success(lockedApps)
    }

    private fun hasOverlayPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            result.success(Settings.canDrawOverlays(context))
        } else {
            result.success(true)
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
            } else {
                result.success(false) // Already has permission
            }
        } else {
            result.success(false)
        }
    }

    private fun hasUsageStatsPermission(result: MethodChannel.Result) {
        result.success(UsageStatsHelper.hasUsageStatsPermission(context))
    }

    private fun requestUsageStatsPermission(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            activity.startActivityForResult(intent, REQUEST_CODE_USAGE_STATS_PERMISSION)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening usage stats settings", e)
            result.error("PERMISSION_ERROR", e.message, null)
        }
    }

    private fun isAccessibilityServiceEnabled(result: MethodChannel.Result) {
        result.success(AppLockAccessibilityService.isServiceRunning)
    }

    private fun openAccessibilitySettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            activity.startActivityForResult(intent, REQUEST_CODE_ACCESSIBILITY_SETTINGS)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening accessibility settings", e)
            result.error("PERMISSION_ERROR", e.message, null)
        }
    }

    private fun isDeviceAdminActive(result: MethodChannel.Result) {
        val devicePolicyManager = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(context, AppLockDeviceAdmin::class.java)
        result.success(devicePolicyManager.isAdminActive(componentName))
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
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting device admin", e)
            result.error("PERMISSION_ERROR", e.message, null)
        }
    }

    private fun onUnlockSuccess(packageName: String?, result: MethodChannel.Result) {
        try {
            val target = packageName ?: com.securelock.secure_lock_app.services.AppLockForegroundService.lastLockedPackage

            if (target != null) {
                // Apply grace period to prevent immediate re-lock
                com.securelock.secure_lock_app.utils.UnlockState.allow(target)

                // Log unlock success
                FlowLogger.logUnlock(target)

                // Bring target app to foreground BEFORE finishing
                try {
                    val launchIntent = context.packageManager.getLaunchIntentForPackage(target)
                    if (launchIntent != null) {
                        launchIntent.addFlags(
                            Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                        )
                        FlowLogger.logStep("Bringing App to Foreground", target)
                        context.startActivity(launchIntent)

                        // Small delay to let target app start coming to front
                        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                            FlowLogger.logStep("Finishing Lock Screen", "Closing MainActivity")
                            try {
                                activity.finishAndRemoveTask()
                            } catch (_: Exception) {
                                activity.finish()
                            }
                            FlowLogger.endFlow(true)
                        }, 100)
                    } else {
                        Log.w(TAG, "⚠ No launch intent for $target, just finishing")
                        activity.finish()
                        FlowLogger.endFlow(false)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Error bringing app to foreground: ${e.message}")
                    activity.finish()
                    FlowLogger.endFlow(false)
                }
            } else {
                Log.w(TAG, "⚠ No target package, just finishing")
                activity.finish()
                // Don't call endFlow here - no flow was started
            }

            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error in unlock flow: ${e.message}", e)
            FlowLogger.endFlow(false)
            result.error("UNLOCK_ERROR", e.message, null)
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
            } else {
                result.error("APP_NOT_FOUND", "App not found: $packageName", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error launching app: $packageName", e)
            result.error("LAUNCH_ERROR", e.message, null)
        }
    }
}
