/// Application string constants
class AppStrings {
  // App Name
  static const String appName = 'Secure Lock';
  static const String appTagline = 'Protect Your Privacy';

  // Onboarding
  static const String onboardingTitle1 = 'Lock Your Apps';
  static const String onboardingDesc1 = 'Secure individual apps with PIN, password, or fingerprint';
  static const String onboardingTitle2 = 'Smart Protection';
  static const String onboardingDesc2 = 'Auto-lock based on location, time, or WiFi network';
  static const String onboardingTitle3 = 'Intruder Detection';
  static const String onboardingDesc3 = 'Capture photos of unauthorized access attempts';
  static const String onboardingGetStarted = 'Get Started';
  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';

  // Authentication Setup
  static const String setupAuthTitle = 'Setup Authentication';
  static const String setupAuthDesc = 'Choose how you want to secure your apps';
  static const String setupPinTitle = 'Create PIN';
  static const String setupPinDesc = 'Create a 4-6 digit PIN';
  static const String setupPasswordTitle = 'Create Password';
  static const String setupPasswordDesc = 'Create a strong password';
  static const String setupBiometricTitle = 'Enable Biometric';
  static const String setupBiometricDesc = 'Use fingerprint or face unlock';

  // PIN/Password
  static const String enterPin = 'Enter PIN';
  static const String reEnterPin = 'Re-enter PIN';
  static const String createPin = 'Create PIN';
  static const String confirmPin = 'Confirm PIN';
  static const String enterPassword = 'Enter Password';
  static const String reEnterPassword = 'Re-enter Password';
  static const String createPassword = 'Create Password';
  static const String confirmPassword = 'Confirm Password';
  static const String pinMismatch = 'PINs do not match';
  static const String passwordMismatch = 'Passwords do not match';
  static const String pinTooShort = 'PIN must be at least 4 digits';
  static const String pinTooLong = 'PIN must not exceed 6 digits';
  static const String passwordTooShort = 'Password must be at least 4 characters';
  static const String passwordTooWeak = 'Password is too weak';
  static const String incorrectPin = 'Incorrect PIN';
  static const String incorrectPassword = 'Incorrect Password';

  // Home Screen
  static const String homeTitle = 'Secure Lock';
  static const String homeLockedApps = 'Locked Apps';
  static const String homeNoLockedApps = 'No apps locked yet';
  static const String homeAddApps = 'Add Apps to Lock';
  static const String homeStats = 'Statistics';
  static const String homeTotalLocked = 'Total Locked';
  static const String homeUnlockAttempts = 'Unlock Attempts';
  static const String homeIntruderPhotos = 'Intruder Photos';

  // App Selection
  static const String selectAppsTitle = 'Select Apps';
  static const String selectAppsDesc = 'Choose apps to lock';
  static const String searchApps = 'Search apps...';
  static const String noAppsFound = 'No apps found';
  static const String systemApps = 'System Apps';
  static const String userApps = 'User Apps';
  static const String allApps = 'All Apps';

  // Lock Screen
  static const String lockScreenTitle = 'App Locked';
  static const String lockScreenDesc = 'Enter your credentials to unlock';
  static const String unlock = 'Unlock';
  static const String useBiometric = 'Use Biometric';
  static const String forgotPassword = 'Forgot Password?';
  static const String attemptsRemaining = 'Attempts remaining';
  static const String tooManyAttempts = 'Too many attempts';
  static const String tryAgainIn = 'Try again in';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String settingsSecurity = 'Security';
  static const String settingsChangePin = 'Change PIN';
  static const String settingsChangePassword = 'Change Password';
  static const String settingsEnableBiometric = 'Enable Biometric';
  static const String settingsTheme = 'Theme';
  static const String settingsLightMode = 'Light Mode';
  static const String settingsDarkMode = 'Dark Mode';
  static const String settingsSystemMode = 'System Default';
  static const String settingsAbout = 'About';
  static const String settingsVersion = 'Version';
  static const String settingsPrivacyPolicy = 'Privacy Policy';
  static const String settingsTerms = 'Terms of Service';

  // Common Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String continueText = 'Continue';
  static const String back = 'Back';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String apply = 'Apply';
  static const String reset = 'Reset';

  // Error Messages
  static const String errorGeneric = 'Something went wrong';
  static const String errorNetwork = 'Network error occurred';
  static const String errorAuth = 'Authentication failed';
  static const String errorPermission = 'Permission denied';
  static const String errorStorage = 'Storage error';
  static const String errorBiometric = 'Biometric authentication not available';

  // Success Messages
  static const String successAuthSetup = 'Authentication setup successful';
  static const String successAppLocked = 'App locked successfully';
  static const String successAppUnlocked = 'App unlocked successfully';
  static const String successSettingsSaved = 'Settings saved successfully';

  // Permissions
  static const String permissionUsageStats = 'Usage Stats Permission';
  static const String permissionUsageStatsDesc = 'Required to monitor app usage';
  static const String permissionOverlay = 'Display Over Other Apps';
  static const String permissionOverlayDesc = 'Required to show lock screen';
  static const String permissionCamera = 'Camera Permission';
  static const String permissionCameraDesc = 'Required for intruder detection';
  static const String permissionLocation = 'Location Permission';
  static const String permissionLocationDesc = 'Required for location-based automation';

  // Time
  static const String seconds = 'seconds';
  static const String minutes = 'minutes';
  static const String hours = 'hours';
  static const String days = 'days';
}
