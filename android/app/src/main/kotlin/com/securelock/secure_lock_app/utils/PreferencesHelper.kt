package com.securelock.secure_lock_app.utils

import android.content.Context
import android.content.SharedPreferences

/**
 * Helper class to manage SharedPreferences for native Android code
 * Syncs with Flutter's SharedPreferences
 */
class PreferencesHelper(context: Context) {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_LOCKED_APPS = "flutter.locked_apps"
        private const val KEY_SERVICE_ENABLED = "flutter.service_enabled"
    }

    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    /**
     * Check if an app is locked
     */
    fun isAppLocked(packageName: String): Boolean {
        val lockedApps = getLockedApps()
        return lockedApps.contains(packageName)
    }

    /**
     * Get list of locked apps
     */
    fun getLockedApps(): Set<String> {
        val lockedAppsString = prefs.getString(KEY_LOCKED_APPS, "") ?: ""
        if (lockedAppsString.isEmpty()) {
            return emptySet()
        }
        return lockedAppsString.split(",").toSet()
    }

    /**
     * Add an app to locked list
     */
    fun lockApp(packageName: String) {
        val lockedApps = getLockedApps().toMutableSet()
        lockedApps.add(packageName)
        saveLockedApps(lockedApps)
    }

    /**
     * Remove an app from locked list
     */
    fun unlockApp(packageName: String) {
        val lockedApps = getLockedApps().toMutableSet()
        lockedApps.remove(packageName)
        saveLockedApps(lockedApps)
    }

    /**
     * Save locked apps list
     */
    private fun saveLockedApps(lockedApps: Set<String>) {
        val lockedAppsString = lockedApps.joinToString(",")
        prefs.edit().putString(KEY_LOCKED_APPS, lockedAppsString).apply()
    }

    /**
     * Check if service is enabled
     */
    fun isServiceEnabled(): Boolean {
        return prefs.getBoolean(KEY_SERVICE_ENABLED, true)
    }

    /**
     * Set service enabled status
     */
    fun setServiceEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_SERVICE_ENABLED, enabled).apply()
    }
}
