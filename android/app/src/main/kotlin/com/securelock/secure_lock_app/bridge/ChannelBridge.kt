package com.securelock.secure_lock_app.bridge

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ConcurrentLinkedQueue

/**
 * Holds a reference to the Flutter MethodChannel so background components
 * (services, receivers) can send lightweight debug logs to Flutter.
 * Buffers logs when channel is not ready and sends them when available.
 */
object ChannelBridge {
    @Volatile
    private var methodChannel: MethodChannel? = null

    private val mainHandler = Handler(Looper.getMainLooper())
    private val logBuffer = ConcurrentLinkedQueue<HashMap<String, Any?>>()
    private const val MAX_BUFFER_SIZE = 100

    fun setChannel(channel: MethodChannel?) {
        methodChannel = channel
        // Send buffered logs when channel becomes available
        if (channel != null) {
            flushLogBuffer()
        }
    }

    private fun flushLogBuffer() {
        val channel = methodChannel ?: return
        while (logBuffer.isNotEmpty()) {
            val log = logBuffer.poll() ?: break
            if (Looper.myLooper() == Looper.getMainLooper()) {
                channel.invokeMethod("debugLog", log)
            } else {
                mainHandler.post { channel.invokeMethod("debugLog", log) }
            }
        }
    }

    fun debugLog(message: String, level: String = "info", tag: String? = null) {
        // Debug logs disabled - use logcat instead
        // All in-app debug tab logging has been removed
    }

    /**
     * Send flow diagram logs to Flutter Flow tab
     */
    fun flowLog(message: String) {
        val payload = hashMapOf<String, Any?>(
            "message" to message,
            "timestamp" to System.currentTimeMillis()
        )

        val channel = methodChannel
        if (channel != null) {
            // Channel is ready, send immediately
            if (Looper.myLooper() == Looper.getMainLooper()) {
                channel.invokeMethod("flowLog", payload)
            } else {
                mainHandler.post { channel.invokeMethod("flowLog", payload) }
            }
        }
        // Note: Flow logs are NOT buffered - they're real-time only
    }
}

