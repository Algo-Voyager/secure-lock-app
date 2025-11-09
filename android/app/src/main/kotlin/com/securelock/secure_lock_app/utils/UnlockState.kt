package com.securelock.secure_lock_app.utils

import java.util.concurrent.ConcurrentHashMap

/**
 * Holds ephemeral unlock allowances to avoid immediate re-lock when returning
 * to a just-unlocked app. Entries auto-expire after a short grace period.
 */
object UnlockState {
    private val allowedUntil = ConcurrentHashMap<String, Long>()
    private const val DEFAULT_GRACE_MS = 10000L // 10 seconds

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
}
