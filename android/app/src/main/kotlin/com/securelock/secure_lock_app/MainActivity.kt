package com.securelock.secure_lock_app

import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.securelock.secure_lock_app.bridge.NativeBridge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.securelock.secure_lock_app.bridge.ChannelBridge

class MainActivity : FlutterFragmentActivity() {

    private lateinit var nativeBridge: NativeBridge
    private lateinit var methodChannel: MethodChannel
    private var pendingLockedPackage: String? = null
    private var pendingLockIntent: Intent? = null

    companion object {
        private const val TAG = "MainActivity"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize native bridge
        nativeBridge = NativeBridge(this)

        // Set up method channel
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NativeBridge.CHANNEL
        )

        methodChannel.setMethodCallHandler { call, result ->
            nativeBridge.handleMethodCall(call, result)
        }

        // Expose channel to other components for lightweight debug logs
        ChannelBridge.setChannel(methodChannel)

        // If we received a lock request before the channel was ready, deliver it now
        pendingLockedPackage?.let { pkg ->
            Log.d(TAG, "Delivering pending lock screen for: $pkg")
            methodChannel.invokeMethod("showLockScreen", mapOf(
                "packageName" to pkg
            ))
            pendingLockedPackage = null
        }

        // Also handle any pending intent
        pendingLockIntent?.let { intent ->
            handleLockScreenIntent(intent)
            pendingLockIntent = null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Handle lock screen intent
        handleLockScreenIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleLockScreenIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        // Re-check intent when activity resumes (in case it was in background)
        intent?.let { handleLockScreenIntent(it) }
    }

    private fun handleLockScreenIntent(intent: Intent) {
        val showLockScreen = intent.getBooleanExtra("show_lock_screen", false)
        val lockedPackage = intent.getStringExtra("locked_package")

        if (showLockScreen && lockedPackage != null) {
            Log.d(TAG, "Handling lock screen intent for: $lockedPackage")

            // Notify Flutter to show lock screen (or defer until channel ready)
            if (::methodChannel.isInitialized) {
                Log.d(TAG, "Method channel ready, sending lock screen request")
                methodChannel.invokeMethod("showLockScreen", mapOf(
                    "packageName" to lockedPackage
                ))
            } else {
                Log.d(TAG, "Method channel not ready, storing package: $lockedPackage")
                pendingLockedPackage = lockedPackage
                pendingLockIntent = intent
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        // Handle permission results
        when (requestCode) {
            NativeBridge.REQUEST_CODE_OVERLAY_PERMISSION,
            NativeBridge.REQUEST_CODE_USAGE_STATS_PERMISSION,
            NativeBridge.REQUEST_CODE_DEVICE_ADMIN,
            NativeBridge.REQUEST_CODE_ACCESSIBILITY_SETTINGS -> {
                // Notify Flutter about permission result
                methodChannel.invokeMethod("onPermissionResult", mapOf(
                    "requestCode" to requestCode,
                    "resultCode" to resultCode
                ))
            }
        }
    }
}
