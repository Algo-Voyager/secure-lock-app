package com.securelock.secure_lock_app.utils

import android.util.Log
import com.securelock.secure_lock_app.bridge.ChannelBridge

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

        val message = """
╔═══════════════════════════════════════════════════════════╗
║  🔒 LOCK SCREEN FLOW STARTED                             ║
╠═══════════════════════════════════════════════════════════╣
║  📱 App: $appName${" ".repeat(maxOf(0, 47 - appName.length))}║
║  🔧 Trigger: $trigger${" ".repeat(maxOf(0, 43 - trigger.length))}║
║  ⏰ Started: ${getCurrentTime()}${" ".repeat(maxOf(0, 44 - getCurrentTime().length))}║
╚═══════════════════════════════════════════════════════════╝
     │
     ▼
""".trim()

        Log.d(TAG, "\n")
        Log.d(TAG, message)
        ChannelBridge.flowLog(message)
    }

    /**
     * Log a flow step
     */
    fun logStep(step: String, details: String = "") {
        val now = System.currentTimeMillis()
        val elapsed = now - lastEventTime
        val totalElapsed = now - flowStartTime
        lastEventTime = now

        val detailsLine = if (details.isNotEmpty()) {
            "\n│     └─ $details${" ".repeat(maxOf(0, 49 - details.length))}│"
        } else ""

        val message = """
┌───────────────────────────────────────────────────────────┐
│  ✓ $step${" ".repeat(maxOf(0, 53 - step.length))}│$detailsLine
│  ⏱️  Duration: ${elapsed}ms (Total: ${totalElapsed}ms)${" ".repeat(maxOf(0, 28 - elapsed.toString().length - totalElapsed.toString().length))}│
└───────────────────────────────────────────────────────────┘
     │
     ▼
""".trim()

        Log.d(TAG, "")
        Log.d(TAG, message)
        ChannelBridge.flowLog(message)
    }

    /**
     * Log unlock success
     */
    fun logUnlock(packageName: String) {
        val now = System.currentTimeMillis()
        val totalElapsed = now - flowStartTime

        val appName = packageName.split(".").lastOrNull() ?: packageName

        val message = """
╔═══════════════════════════════════════════════════════════╗
║  🔓 UNLOCK SUCCESSFUL                                    ║
╠═══════════════════════════════════════════════════════════╣
║  📱 Returning to: $appName${" ".repeat(maxOf(0, 40 - appName.length))}║
║  ⏱️  Total Time: ${totalElapsed}ms${" ".repeat(maxOf(0, 43 - totalElapsed.toString().length))}║
║  ✅ Grace Period: 3 seconds applied                      ║
╚═══════════════════════════════════════════════════════════╝
     │
     ▼
""".trim()

        Log.d(TAG, "")
        Log.d(TAG, message)
        ChannelBridge.flowLog(message)
    }

    /**
     * Log app switch
     */
    fun logAppSwitch(fromApp: String?, toApp: String, gracesCleared: List<String>) {
        val toAppName = toApp.split(".").lastOrNull() ?: toApp
        val fromAppName = fromApp?.split(".")?.lastOrNull() ?: "Unknown"

        val graceLines = if (gracesCleared.isNotEmpty()) {
            gracesCleared.joinToString("\n") { pkg ->
                val pkgName = pkg.split(".").lastOrNull() ?: pkg
                "║     • $pkgName${" ".repeat(maxOf(0, 50 - pkgName.length))}║"
            }
        } else ""

        val message = """
╔═══════════════════════════════════════════════════════════╗
║  🔄 APP SWITCH DETECTED                                  ║
╠═══════════════════════════════════════════════════════════╣
║  From: $fromAppName${" ".repeat(maxOf(0, 49 - fromAppName.length))}║
║  To:   $toAppName${" ".repeat(maxOf(0, 49 - toAppName.length))}║
${if (gracesCleared.isNotEmpty()) "║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ║\n║  🧹 Grace Cleared For:                                   ║\n$graceLines" else ""}
╚═══════════════════════════════════════════════════════════╝
""".trim()

        Log.d(TAG, "\n")
        Log.d(TAG, message)
        ChannelBridge.flowLog(message)
    }

    /**
     * Log flow completion
     */
    fun endFlow(success: Boolean) {
        val now = System.currentTimeMillis()
        val totalElapsed = now - flowStartTime

        val status = if (success) "✅ COMPLETED SUCCESSFULLY" else "❌ FAILED"

        val message = """
╔═══════════════════════════════════════════════════════════╗
║  $status${" ".repeat(maxOf(0, 53 - status.length))}║
╠═══════════════════════════════════════════════════════════╣
║  ⏱️  Total Flow Time: ${totalElapsed}ms${" ".repeat(maxOf(0, 38 - totalElapsed.toString().length))}║
║  ⏰ Ended: ${getCurrentTime()}${" ".repeat(maxOf(0, 46 - getCurrentTime().length))}║
╚═══════════════════════════════════════════════════════════╝
""".trim()

        Log.d(TAG, "")
        Log.d(TAG, message)
        Log.d(TAG, "\n")
        ChannelBridge.flowLog(message)

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
