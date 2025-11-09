import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';

/// Main entry point of the Secure Lock application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for now)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SecureLockApp());
}
