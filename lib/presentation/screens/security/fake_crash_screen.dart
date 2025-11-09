import 'package:flutter/material.dart';
import 'dart:async';

/// Fake crash screen to deceive intruders
/// Shows a convincing Android system crash message
class FakeCrashScreen extends StatefulWidget {
  final VoidCallback? onDismiss;

  const FakeCrashScreen({super.key, this.onDismiss});

  @override
  State<FakeCrashScreen> createState() => _FakeCrashScreenState();
}

class _FakeCrashScreenState extends State<FakeCrashScreen> {
  bool _showDetails = false;
  int _tapCount = 0;
  Timer? _tapResetTimer;

  void _handleSecretTap() {
    setState(() => _tapCount++);

    // Reset tap count after 2 seconds
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _tapCount = 0);
    });

    // If tapped 5 times quickly, dismiss crash screen
    if (_tapCount >= 5) {
      widget.onDismiss?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Android system crash header
            Container(
              width: double.infinity,
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _handleSecretTap,
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.grey.shade400,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'com.securelock.secure_lock_app',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'has stopped',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Error details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Crash message
                    Text(
                      'Unfortunately, Secure Lock has stopped.',
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Show details toggle
                    GestureDetector(
                      onTap: () {
                        setState(() => _showDetails = !_showDetails);
                      },
                      child: Row(
                        children: [
                          Icon(
                            _showDetails ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showDetails ? 'Hide details' : 'Show details',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Crash details (fake stack trace)
                    if (_showDetails) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getFakeStackTrace(),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade800),
                ),
              ),
              child: Column(
                children: [
                  // Hidden hint for user
                  if (_tapCount > 0 && _tapCount < 5)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Tap ${5 - _tapCount} more times to dismiss',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 10,
                        ),
                      ),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Report sent (fake)'),
                                backgroundColor: Colors.grey.shade800,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade400,
                            side: BorderSide(color: Colors.grey.shade700),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Send feedback'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Just close the screen (fake close)
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            foregroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Close app'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFakeStackTrace() {
    return '''
FATAL EXCEPTION: main
Process: com.securelock.secure_lock_app, PID: 12847
java.lang.RuntimeException: Unable to start activity
    at android.app.ActivityThread.performLaunchActivity
    at android.app.ActivityThread.handleLaunchActivity
    at android.app.servertransaction.LaunchActivityItem
    at android.app.ActivityThread\$Handler.handleMessage
    at android.os.Handler.dispatchMessage
    at android.os.Looper.loop
    at android.app.ActivityThread.main
    at java.lang.reflect.Method.invoke
    at com.android.internal.os.RuntimeInit\$MethodAndArgsCaller
    at com.android.internal.os.ZygoteInit.main
Caused by: java.lang.NullPointerException
    at com.securelock.secure_lock_app.MainActivity.onCreate
    at android.app.Activity.performCreate
    at android.app.Activity.performCreate
    at android.app.Instrumentation.callActivityOnCreate
    at android.app.ActivityThread.performLaunchActivity
''';
  }
}

/// Provider to manage fake crash mode
class FakeCrashProvider extends ChangeNotifier {
  bool _isFakeCrashEnabled = false;
  bool _isInFakeCrashMode = false;

  bool get isFakeCrashEnabled => _isFakeCrashEnabled;
  bool get isInFakeCrashMode => _isInFakeCrashMode;

  void enableFakeCrash() {
    _isFakeCrashEnabled = true;
    notifyListeners();
  }

  void disableFakeCrash() {
    _isFakeCrashEnabled = false;
    _isInFakeCrashMode = false;
    notifyListeners();
  }

  void triggerFakeCrash() {
    if (_isFakeCrashEnabled) {
      _isInFakeCrashMode = true;
      notifyListeners();
    }
  }

  void dismissFakeCrash() {
    _isInFakeCrashMode = false;
    notifyListeners();
  }
}
