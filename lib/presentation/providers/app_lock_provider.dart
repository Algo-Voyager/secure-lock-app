import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/native_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/debug_logger.dart';
import '../../data/models/locked_app_model.dart';

/// Provider for managing locked applications
class AppLockProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NativeService _nativeService = NativeService();

  List<LockedAppModel> _lockedApps = [];
  List<AppInfo> _installedApps = [];
  bool _isLoading = false;

  // Getters
  List<LockedAppModel> get lockedApps => _lockedApps;
  List<AppInfo> get installedApps => _installedApps;
  bool get isLoading => _isLoading;
  int get lockedAppsCount => _lockedApps.length;

  /// Initialize app lock provider
  Future<void> initialize() async {
    try {
      await _storageService.initialize();
      await loadLockedApps();
      await loadInstalledApps();

      // Sync locked apps with native service and start service if needed
      if (_lockedApps.isNotEmpty) {
        try {
          DebugLogger().log('Syncing ${_lockedApps.length} locked apps with native service', tag: 'AppLock');

          // Sync each locked app with native service
          for (final app in _lockedApps) {
            await _nativeService.lockApp(app.packageName);
            DebugLogger().log('Synced: ${app.appName}', level: LogLevel.debug, tag: 'AppLock');
          }

          // Start foreground service if not already running
          final isRunning = await _nativeService.isServiceRunning();
          DebugLogger().log('Foreground service running: $isRunning', tag: 'AppLock');

          if (!isRunning) {
            DebugLogger().log('Starting foreground service...', level: LogLevel.warning, tag: 'AppLock');
            final started = await _nativeService.startForegroundService();
            if (started) {
              logger.i('Foreground service started on initialization');
              DebugLogger().log('✅ Foreground service started successfully!', level: LogLevel.success, tag: 'AppLock');
            } else {
              DebugLogger().log('❌ Failed to start foreground service', level: LogLevel.error, tag: 'AppLock');
            }
          } else {
            logger.i('Foreground service already running');
            DebugLogger().log('Foreground service already running', level: LogLevel.success, tag: 'AppLock');
          }
        } catch (e) {
          logger.e('Error syncing with native service', error: e);
          DebugLogger().log('ERROR syncing with native: $e', level: LogLevel.error, tag: 'AppLock');
        }
      } else {
        DebugLogger().log('No locked apps to sync', tag: 'AppLock');
      }

      logger.i('AppLockProvider initialized');
    } catch (e) {
      logger.e('Error initializing AppLockProvider', error: e);
      rethrow;
    }
  }

  /// Load locked apps from storage
  Future<void> loadLockedApps() async {
    try {
      _isLoading = true;
      notifyListeners();

      final packageNames = _storageService.getLockedApps();
      _lockedApps = packageNames
          .map(
            (packageName) => LockedAppModel(
              packageName: packageName,
              appName: _getAppNameFromPackage(packageName),
              lockedAt: DateTime.now(),
            ),
          )
          .toList();

      logger.i('Loaded ${_lockedApps.length} locked apps');
    } catch (e) {
      logger.e('Error loading locked apps', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load installed apps (mock data for web, real for Android)
  Future<void> loadInstalledApps() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (AppConstants.useMockData) {
        // Mock data for web testing
        _installedApps = _getMockInstalledApps();
      } else {
        // Get real installed apps from native code
        final apps = await _nativeService.getInstalledApps();
        _installedApps = apps.map((app) => AppInfo(
          packageName: app['packageName'] as String,
          appName: app['appName'] as String,
          icon: app['icon']?.toString(),
        )).toList();
      }

      logger.i('Loaded ${_installedApps.length} installed apps');
    } catch (e) {
      logger.e('Error loading installed apps', error: e);
      // Fallback to mock data if native call fails
      _installedApps = _getMockInstalledApps();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lock an app
  Future<bool> lockApp(String packageName, String appName) async {
    try {
      // Check if already locked
      if (_lockedApps.any((app) => app.packageName == packageName)) {
        logger.w('App already locked: $packageName');
        return false;
      }

      final lockedApp = LockedAppModel(
        packageName: packageName,
        appName: appName,
        lockedAt: DateTime.now(),
      );

      _lockedApps.add(lockedApp);
      await _saveLockedApps();

      // Notify native service about the locked app
      try {
        DebugLogger().log('Notifying native service to lock: $packageName', tag: 'Lock');
        await _nativeService.lockApp(packageName);
        logger.i('Native service notified about locked app: $packageName');
        DebugLogger().log('✅ Native notified successfully', level: LogLevel.success, tag: 'Lock');
      } catch (e) {
        logger.e('Error notifying native service', error: e);
        DebugLogger().log('❌ Failed to notify native: $e', level: LogLevel.error, tag: 'Lock');
      }

      // Start foreground service if this is the first locked app
      if (_lockedApps.length == 1) {
        try {
          DebugLogger().log('First app locked - starting foreground service...', level: LogLevel.warning, tag: 'Lock');
          final started = await _nativeService.startForegroundService();
          if (started) {
            logger.i('Foreground service started');
            DebugLogger().log('✅ Foreground service STARTED!', level: LogLevel.success, tag: 'Lock');
          } else {
            logger.w('Failed to start foreground service');
            DebugLogger().log('❌ Service start returned false', level: LogLevel.error, tag: 'Lock');
          }
        } catch (e) {
          logger.e('Error starting foreground service', error: e);
          DebugLogger().log('❌ Service start exception: $e', level: LogLevel.error, tag: 'Lock');
        }
      } else {
        DebugLogger().log('Total locked apps: ${_lockedApps.length}', tag: 'Lock');
      }

      logger.i('Locked app: $appName ($packageName)');
      notifyListeners();
      return true;
    } catch (e) {
      logger.e('Error locking app: $packageName', error: e);
      return false;
    }
  }

  /// Unlock an app
  Future<bool> unlockApp(String packageName) async {
    try {
      _lockedApps.removeWhere((app) => app.packageName == packageName);
      await _saveLockedApps();

      // Notify native service about the unlocked app
      try {
        await _nativeService.unlockApp(packageName);
        logger.i('Native service notified about unlocked app: $packageName');
      } catch (e) {
        logger.e('Error notifying native service', error: e);
      }

      // Stop foreground service if no apps are locked
      if (_lockedApps.isEmpty) {
        try {
          await _nativeService.stopForegroundService();
          logger.i('Foreground service stopped (no locked apps)');
        } catch (e) {
          logger.e('Error stopping foreground service', error: e);
        }
      }

      logger.i('Unlocked app: $packageName');
      notifyListeners();
      return true;
    } catch (e) {
      logger.e('Error unlocking app: $packageName', error: e);
      return false;
    }
  }

  /// Check if an app is locked
  bool isAppLocked(String packageName) {
    return _lockedApps.any((app) => app.packageName == packageName);
  }

  /// Toggle app lock status
  Future<bool> toggleAppLock(String packageName, String appName) async {
    if (isAppLocked(packageName)) {
      return await unlockApp(packageName);
    } else {
      return await lockApp(packageName, appName);
    }
  }

  /// Unlock all apps
  Future<void> unlockAllApps() async {
    try {
      _lockedApps.clear();
      await _storageService.saveLockedApps([]);
      logger.i('Unlocked all apps');
      notifyListeners();
    } catch (e) {
      logger.e('Error unlocking all apps', error: e);
    }
  }

  /// Save locked apps to storage
  Future<void> _saveLockedApps() async {
    final packageNames = _lockedApps.map((app) => app.packageName).toList();
    await _storageService.saveLockedApps(packageNames);
  }

  /// Get app name from package name (simplified)
  String _getAppNameFromPackage(String packageName) {
    // Try to find in installed apps
    final app = _installedApps.firstWhere(
      (app) => app.packageName == packageName,
      orElse: () => AppInfo(
        packageName: packageName,
        appName: packageName.split('.').last.replaceAll('_', ' ').toUpperCase(),
      ),
    );
    return app.appName;
  }

  /// Get mock installed apps for web testing
  List<AppInfo> _getMockInstalledApps() {
    return [
      const AppInfo(
        packageName: 'com.whatsapp',
        appName: 'WhatsApp',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.facebook.katana',
        appName: 'Facebook',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.twitter.android',
        appName: 'Twitter',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.google.android.gm',
        appName: 'Gmail',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.spotify.music',
        appName: 'Spotify',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.netflix.mediaclient',
        appName: 'Netflix',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.snapchat.android',
        appName: 'Snapchat',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.zhiliaoapp.musically',
        appName: 'TikTok',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.google.android.apps.photos',
        appName: 'Google Photos',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.telegram.messenger',
        appName: 'Telegram',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.reddit.frontpage',
        appName: 'Reddit',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.pinterest',
        appName: 'Pinterest',
        isSystemApp: false,
      ),
      const AppInfo(
        packageName: 'com.amazon.mShop.android.shopping',
        appName: 'Amazon Shopping',
        isSystemApp: false,
      ),
    ];
  }
}
