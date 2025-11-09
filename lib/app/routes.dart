import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/setup/pin_setup_screen.dart';
import '../presentation/screens/setup/pattern_setup_screen.dart';
import '../presentation/screens/setup/permission_wizard_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/app_selection/app_selection_screen.dart';
import '../presentation/screens/lock_screen/lock_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/settings/backup_restore_screen.dart';
import '../presentation/screens/security/intruder_logs_screen.dart';
import '../presentation/screens/security/fake_crash_screen.dart';
import '../presentation/screens/security/decoy_setup_screen.dart';
import '../presentation/screens/automation/automation_screen.dart';
import '../presentation/screens/vault/vault_screen.dart';
import '../presentation/screens/analytics/analytics_screen.dart';
import '../presentation/screens/debug/debug_monitor_screen.dart';

/// App routes configuration
class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeSplash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppConstants.routeOnboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppConstants.routePinSetup:
        return MaterialPageRoute(builder: (_) => const PinSetupScreen());

      case AppConstants.routeHome:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppConstants.routeAppSelection:
        return MaterialPageRoute(builder: (_) => const AppSelectionScreen());

      case AppConstants.routeLockScreen:
        return MaterialPageRoute(
          builder: (_) => const LockScreen(),
          fullscreenDialog: true,
        );

      case AppConstants.routeSettings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/pattern-setup':
        return MaterialPageRoute(builder: (_) => const PatternSetupScreen());

      case '/permission-wizard':
        return MaterialPageRoute(builder: (_) => const PermissionWizardScreen());

      case '/intruder-logs':
        return MaterialPageRoute(builder: (_) => const IntruderLogsScreen());

      case '/automation':
        return MaterialPageRoute(builder: (_) => const AutomationScreen());

      case '/vault':
        return MaterialPageRoute(builder: (_) => const VaultScreen());

      case '/analytics':
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());

      case '/backup-restore':
        return MaterialPageRoute(builder: (_) => const BackupRestoreScreen());

      case '/decoy-setup':
        return MaterialPageRoute(builder: (_) => const DecoySetupScreen());

      case '/fake-crash':
        return MaterialPageRoute(
          builder: (_) => const FakeCrashScreen(),
          fullscreenDialog: true,
        );

      case '/debug-monitor':
        return MaterialPageRoute(
          builder: (_) => const DebugMonitorScreen(),
          fullscreenDialog: true,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
