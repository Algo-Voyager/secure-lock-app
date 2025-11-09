import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/app_lock_provider.dart';
import '../presentation/providers/theme_provider.dart';
import '../presentation/providers/intruder_provider.dart';
import '../presentation/providers/automation_provider.dart';
import '../presentation/providers/vault_provider.dart';
import '../presentation/providers/permissions_provider.dart';
import 'routes.dart';

/// Main application widget
class SecureLockApp extends StatelessWidget {
  const SecureLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppLockProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => IntruderProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AutomationProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => VaultProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => PermissionsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.materialThemeMode,
            initialRoute: AppConstants.routeSplash,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
