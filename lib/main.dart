import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/services/native_service.dart';
import 'core/utils/debug_logger.dart';

/// Main entry point of the Secure Lock application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for now)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize MethodChannel callbacks so native can trigger the lock screen
  NativeService().initializeCallbacks();

  // Log app startup
  DebugLogger().log('App started', level: LogLevel.info, tag: 'App');

  runApp(const SecureLockApp());
}
