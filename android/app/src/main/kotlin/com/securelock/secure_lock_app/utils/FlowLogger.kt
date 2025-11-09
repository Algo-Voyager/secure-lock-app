package com.securelock.secure_lock_app.utils

import android.util.Log

/**
 * Flow Logger - Creates beautiful, readable flow diagrams in logs
 * Shows timing, trigger source, and visual flow progression
 */
object FlowLogger {
    private const val TAG = "🔐 FLOW"

    // Flow event tracking
    private var lastEventTime: Long = 0
    private var flowStartTime: Long = 0
    private var currentPackage: String? = null

    /**
     * Start a new flow (lock screen triggered)
     */
    fun startFlow(packageName: String, trigger: String) {
        flowStartTime = System.currentTimeMillis()
        lastEventTime = flowStartTime
        currentPackage = packageName

        val appName = packageName.split(".").lastOrNull() ?: packageName

        Log.d(TAG, "\n")
        Log.d(TAG, "╔═══════════════════════════════════════════════════════════╗")
        Log.d(TAG, "║  🔒 LOCK SCREEN FLOW STARTED                             ║")
        Log.d(TAG, "╠═══════════════════════════════════════════════════════════╣")
        Log.d(TAG, "║  📱 App: $appName${" ".repeat(maxOf(0, 47 - appName.length))}║")
        Log.d(TAG, "║  🔧 Trigger: $trigger${" ".repeat(maxOf(0, 43 - trigger.length))}║")
        Log.d(TAG, "║  ⏰ Started: ${getCurrentTime()}${" ".repeat(maxOf(0, 44 - getCurrentTime().length))}║")
        Log.d(TAG, "╚═══════════════════════════════════════════════════════════╝")
        Log.d(TAG, "")
        Log.d(TAG, "     │")
        Log.d(TAG, "     ▼")
    }

    /**
     * Log a flow step
     */
    fun logStep(step: String, details: String = "") {
        val now = System.currentTimeMillis()
        val elapsed = now - lastEventTime
        val totalElapsed = now - flowStartTime
        lastEventTime = now

        Log.d(TAG, "")
        Log.d(TAG, "┌───────────────────────────────────────────────────────────┐")
        Log.d(TAG, "│  ✓ $step${" ".repeat(maxOf(0, 53 - step.length))}│")
        if (details.isNotEmpty()) {
            Log.d(TAG, "│     └─ $details${" ".repeat(maxOf(0, 49 - details.length))}│")
        }
        Log.d(TAG, "│  ⏱️  Duration: ${elapsed}ms (Total: ${totalElapsed}ms)${" ".repeat(maxOf(0, 28 - elapsed.toString().length - totalElapsed.toString().length))}│")
        Log.d(TAG, "└───────────────────────────────────────────────────────────┘")
        Log.d(TAG, "     │")
        Log.d(TAG, "     ▼")
    }

    /**
     * Log unlock success
     */
    fun logUnlock(packageName: String) {
        val now = System.currentTimeMillis()
        val totalElapsed = now - flowStartTime

        val appName = packageName.split(".").lastOrNull() ?: packageName

        Log.d(TAG, "")
        Log.d(TAG, "╔═══════════════════════════════════════════════════════════╗")
        Log.d(TAG, "║  🔓 UNLOCK SUCCESSFUL                                    ║")
        Log.d(TAG, "╠═══════════════════════════════════════════════════════════╣")
        Log.d(TAG, "║  📱 Returning to: $appName${" ".repeat(maxOf(0, 40 - appName.length))}║")
        Log.d(TAG, "║  ⏱️  Total Time: ${totalElapsed}ms${" ".repeat(maxOf(0, 43 - totalElapsed.toString().length))}║")
        Log.d(TAG, "║  ✅ Grace Period: 3 seconds applied                      ║")
        Log.d(TAG, "╚═══════════════════════════════════════════════════════════╝")
        Log.d(TAG, "     │")
        Log.d(TAG, "     ▼")
    }

    /**
     * Log app switch
     */
    fun logAppSwitch(fromApp: String?, toApp: String, gracesCleared: List<String>) {
        val toAppName = toApp.split(".").lastOrNull() ?: toApp
        val fromAppName = fromApp?.split(".")?.lastOrNull() ?: "Unknown"

        Log.d(TAG, "\n")
        Log.d(TAG, "╔═══════════════════════════════════════════════════════════╗")
        Log.d(TAG, "║  🔄 APP SWITCH DETECTED                                  ║")
        Log.d(TAG, "╠═══════════════════════════════════════════════════════════╣")
        Log.d(TAG, "║  From: $fromAppName${" ".repeat(maxOf(0, 49 - fromAppName.length))}║")
        Log.d(TAG, "║  To:   $toAppName${" ".repeat(maxOf(0, 49 - toAppName.length))}║")

        if (gracesCleared.isNotEmpty()) {
            Log.d(TAG, "║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ║")
            Log.d(TAG, "║  🧹 Grace Cleared For:                                   ║")
            gracesCleared.forEach { pkg ->
                val pkgName = pkg.split(".").lastOrNull() ?: pkg
                Log.d(TAG, "║     • $pkgName${" ".repeat(maxOf(0, 50 - pkgName.length))}║")
            }
        }

        Log.d(TAG, "╚═══════════════════════════════════════════════════════════╝")
        Log.d(TAG, "")
    }

    /**
     * Log flow completion
     */
    fun endFlow(success: Boolean) {
        val now = System.currentTimeMillis()
        val totalElapsed = now - flowStartTime

        val status = if (success) "✅ COMPLETED SUCCESSFULLY" else "❌ FAILED"

        Log.d(TAG, "")
        Log.d(TAG, "╔═══════════════════════════════════════════════════════════╗")
        Log.d(TAG, "║  $status${" ".repeat(maxOf(0, 53 - status.length))}║")
        Log.d(TAG, "╠═══════════════════════════════════════════════════════════╣")
        Log.d(TAG, "║  ⏱️  Total Flow Time: ${totalElapsed}ms${" ".repeat(maxOf(0, 38 - totalElapsed.toString().length))}║")
        Log.d(TAG, "║  ⏰ Ended: ${getCurrentTime()}${" ".repeat(maxOf(0, 46 - getCurrentTime().length))}║")
        Log.d(TAG, "╚═══════════════════════════════════════════════════════════╝")
        Log.d(TAG, "\n")

        // Reset
        currentPackage = null
        flowStartTime = 0
        lastEventTime = 0
    }

    private fun getCurrentTime(): String {
        val now = System.currentTimeMillis()
        val sdf = java.text.SimpleDateFormat("HH:mm:ss.SSS", java.util.Locale.getDefault())
        return sdf.format(java.util.Date(now))
    }
}
