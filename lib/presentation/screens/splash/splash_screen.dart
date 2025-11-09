import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/permissions_provider.dart';

/// Splash screen with app initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = context.read<AuthProvider>();
    final permissionsProvider = context.read<PermissionsProvider>();

    await authProvider.initialize();

    // Check permissions
    await permissionsProvider.checkAllPermissions();

    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    // Navigate based on app state
    if (!authProvider.hasSetupAuth) {
      // First time setup - go to onboarding
      Navigator.of(context).pushReplacementNamed(AppConstants.routeOnboarding);
    } else if (!permissionsProvider.hasAllPermissions) {
      // Auth is set up but permissions missing - go to permission wizard
      Navigator.of(context).pushReplacementNamed('/permission-wizard');
    } else {
      // Everything is set up - go to home
      Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.appName,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.appTagline,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
