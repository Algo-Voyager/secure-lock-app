/// Core application constants
class AppConstants {
  // App Information
  static const String appName = 'Secure Lock';
  static const String appVersion = '1.0.0';

  // Authentication
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const int minPasswordLength = 4;
  static const int maxPasswordLength = 32;
  static const int maxAuthAttempts = 5;
  static const int authLockoutDurationSeconds = 300; // 5 minutes

  // Storage Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyHasSetupAuth = 'has_setup_auth';
  static const String keyAuthMethod = 'auth_method';
  static const String keyPinHash = 'pin_hash';
  static const String keyPasswordHash = 'password_hash';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyLockedApps = 'locked_apps';
  static const String keyThemeMode = 'theme_mode';
  static const String keyFailedAttempts = 'failed_attempts';
  static const String keyLockoutUntil = 'lockout_until';
  static const String keyEncryptionKey = 'encryption_key';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 48.0;

  // Animation Durations
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 300;
  static const int longAnimationMs = 500;

  // Routes
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routePinSetup = '/pin-setup';
  static const String routePasswordSetup = '/password-setup';
  static const String routeHome = '/home';
  static const String routeLockScreen = '/lock-screen';
  static const String routeAppSelection = '/app-selection';
  static const String routeSettings = '/settings';

  // Lock Screen
  static const int lockScreenResponseTimeMs = 100;

  // Performance Targets
  static const int maxMemoryUsageMb = 50;
  static const double maxBatteryDrainPercent = 2.0;

  // Method Channel Names
  static const String methodChannelPrefix = 'com.securelock.app';
  static const String appLockChannel = '$methodChannelPrefix/app_lock';
  static const String cameraChannel = '$methodChannelPrefix/camera';

  // Encryption
  static const String encryptionAlgorithm = 'AES-256-GCM';

  // Mock Data (for web testing) - Set to false for production
  static const bool useMockData = false;

  // Timeouts
  static const Duration authTimeout = Duration(seconds: 30);
  static const Duration lockScreenTimeout = Duration(minutes: 1);
  static const Duration splashDuration = Duration(seconds: 2);
}

/// Authentication methods enum
enum AuthMethod {
  none,
  pin,
  password,
  biometric,
  pattern,
}

/// Theme modes
enum AppThemeMode {
  light,
  dark,
  system,
}
