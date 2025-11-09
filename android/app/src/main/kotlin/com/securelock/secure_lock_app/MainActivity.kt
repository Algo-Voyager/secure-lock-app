package com.securelock.secure_lock_app

import android.content.Intent
import android.os.Bundle
import com.securelock.secure_lock_app.bridge.NativeBridge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private lateinit var nativeBridge: NativeBridge
    private lateinit var methodChannel: MethodChannel

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

    private fun handleLockScreenIntent(intent: Intent) {
        val showLockScreen = intent.getBooleanExtra("show_lock_screen", false)
        val lockedPackage = intent.getStringExtra("locked_package")

        if (showLockScreen && lockedPackage != null) {
            // Notify Flutter to show lock screen
            methodChannel.invokeMethod("showLockScreen", mapOf(
                "packageName" to lockedPackage
            ))
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
