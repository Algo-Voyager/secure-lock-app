package com.securelock.secure_lock_app.utils

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import android.util.Log
import java.util.*

/**
 * Helper class to get foreground app using UsageStatsManager
 * Requires PACKAGE_USAGE_STATS permission
 */
object UsageStatsHelper {

    private const val TAG = "UsageStatsHelper"

    /**
     * Get the package name of the currently foreground app
     */
    fun getForegroundApp(context: Context): String? {
        try {
            if (!hasUsageStatsPermission(context)) {
                Log.w(TAG, "Usage stats permission not granted")
                return null
            }

            val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return null

            val currentTime = System.currentTimeMillis()
            // Query events from last 5 seconds
            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_BEST,
                currentTime - 5000,
                currentTime
            )

            if (stats.isNullOrEmpty()) {
                return null
            }

            // Sort by last time used
            val sortedStats = stats.sortedByDescending { it.lastTimeUsed }

            // Return the most recently used app
            return sortedStats.firstOrNull()?.packageName
        } catch (e: Exception) {
            Log.e(TAG, "Error getting foreground app", e)
            return null
        }
    }

    /**
     * Check if app has usage stats permission
     */
    fun hasUsageStatsPermission(context: Context): Boolean {
        return try {
            val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
                ?: return false

            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOpsManager.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    context.packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOpsManager.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    context.packageName
                )
            }

            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            Log.e(TAG, "Error checking usage stats permission", e)
            false
        }
    }

    /**
     * Get app usage statistics for a specific time period
     */
    fun getAppUsageStats(
        context: Context,
        startTime: Long,
        endTime: Long
    ): List<UsageStats>? {
        try {
            if (!hasUsageStatsPermission(context)) {
                return null
            }

            val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return null

            return usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )?.sortedByDescending { it.totalTimeInForeground }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting app usage stats", e)
            return null
        }
    }

    /**
     * Get list of recently used apps
     */
    fun getRecentlyUsedApps(context: Context, count: Int = 10): List<String> {
        try {
            if (!hasUsageStatsPermission(context)) {
                return emptyList()
            }

            val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return emptyList()

            val currentTime = System.currentTimeMillis()
            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                currentTime - 24 * 60 * 60 * 1000, // Last 24 hours
                currentTime
            ) ?: return emptyList()

            return stats
                .filter { it.totalTimeInForeground > 0 }
                .sortedByDescending { it.lastTimeUsed }
                .take(count)
                .map { it.packageName }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting recently used apps", e)
            return emptyList()
        }
    }
}
