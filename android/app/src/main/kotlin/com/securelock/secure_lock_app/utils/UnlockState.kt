package com.securelock.secure_lock_app.utils

import java.util.concurrent.ConcurrentHashMap

/**
 * Holds ephemeral unlock allowances to avoid immediate re-lock when returning
 * to a just-unlocked app. Entries are cleared when user switches to a different app.
 */
object UnlockState {
    private val allowedUntil = ConcurrentHashMap<String, Long>()
    private const val DEFAULT_GRACE_MS = 3000L // 3 seconds - just enough to prevent immediate re-lock
    private var lastForegroundApp: String? = null

    @JvmStatic
    fun allow(packageName: String, durationMs: Long = DEFAULT_GRACE_MS) {
        allowedUntil[packageName] = System.currentTimeMillis() + durationMs
    }

    @JvmStatic
    fun isAllowed(packageName: String): Boolean {
        val until = allowedUntil[packageName] ?: return false
        if (System.currentTimeMillis() <= until) return true
        allowedUntil.remove(packageName)
        return false
    }

    /**
     * Call this when a new app comes to foreground.
     * Clears grace for all OTHER apps, so they'll lock when user returns to them.
     */
    @JvmStatic
    fun onAppSwitch(currentApp: String) {
        // If switching to a different app, clear grace for all other apps
        if (currentApp != lastForegroundApp) {
            lastForegroundApp = currentApp
            // Clear grace for all apps except the current one
            allowedUntil.keys.forEach { pkg ->
                if (pkg != currentApp) {
                    allowedUntil.remove(pkg)
                }
            }
        }
    }
}
