import 'package:flutter/services.dart';
import '../utils/logger.dart';
import '../utils/debug_logger.dart';
import 'navigation_service.dart';

/// Service to communicate with native Android code via method channels
class NativeService {
  static const _channel = MethodChannel('com.securelock.app/lock');
  static bool _callbacksInitialized = false;

  /// Initialize handlers for messages coming from native (Android)
  /// - showLockScreen: request from native to display the lock UI
  void initializeCallbacks() {
    if (_callbacksInitialized) return;
    _callbacksInitialized = true;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'debugLog':
          try {
            final args = (call.arguments is Map)
                ? Map<String, dynamic>.from(call.arguments as Map)
                : <String, dynamic>{};
            final message = args['message']?.toString() ?? '';
            final tag = args['tag']?.toString();
            final levelStr = args['level']?.toString() ?? 'info';
            final level = _parseLevel(levelStr);
            // Route to in-app DebugLogger
            // Do not spam production logs; this is internal UI
            DebugLogger().log(message, level: level, tag: tag);
            return true;
          } catch (e) {
            logger.e('Error handling debugLog', error: e);
            return false;
          }
        case 'showLockScreen':
          try {
            final args = (call.arguments is Map) ? Map<String, dynamic>.from(call.arguments as Map) : <String, dynamic>{};
            final packageName = args['packageName'] as String?;
            logger.i('Native requested lock screen for: ${packageName ?? 'unknown'}');
            await NavigationService.instance.showLockScreen(packageName: packageName);
            return true;
          } catch (e) {
            logger.e('Error handling showLockScreen', error: e);
            return false;
          }
        case 'onPermissionResult':
          // Currently handled by UI lifecycle (Permission Wizard re-checks on resume)
          // Keep a no-op here to avoid unhandled method warnings.
          logger.d('Received onPermissionResult from native');
          return true;
        default:
          return false;
      }
    });
  }

  LogLevel _parseLevel(String level) {
    switch (level.toLowerCase()) {
      case 'debug':
        return LogLevel.debug;
      case 'warning':
        return LogLevel.warning;
      case 'error':
        return LogLevel.error;
      case 'success':
        return LogLevel.success;
      case 'info':
      default:
        return LogLevel.info;
    }
  }

  /// Start the foreground service
  Future<bool> startForegroundService() async {
    try {
      final result = await _channel.invokeMethod('startForegroundService');
      logger.i('Foreground service started: $result');
      return result == true;
    } catch (e) {
      logger.e('Error starting foreground service', error: e);
      return false;
    }
  }

  /// Stop the foreground service
  Future<bool> stopForegroundService() async {
    try {
      final result = await _channel.invokeMethod('stopForegroundService');
      logger.i('Foreground service stopped: $result');
      return result == true;
    } catch (e) {
      logger.e('Error stopping foreground service', error: e);
      return false;
    }
  }

  /// Check if service is running
  Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod('isServiceRunning');
      return result == true;
    } catch (e) {
      logger.e('Error checking service status', error: e);
      return false;
    }
  }

  /// Get currently foreground app package name
  Future<String?> getCurrentApp() async {
    try {
      final result = await _channel.invokeMethod('getCurrentApp');
      return result as String?;
    } catch (e) {
      logger.e('Error getting current app', error: e);
      return null;
    }
  }

  /// Get list of installed apps
  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      if (result is List) {
        return result.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return [];
    } catch (e) {
      logger.e('Error getting installed apps', error: e);
      return [];
    }
  }

  /// Check if an app is locked
  Future<bool> isAppLocked(String packageName) async {
    try {
      final result = await _channel.invokeMethod('isAppLocked', {
        'packageName': packageName,
      });
      return result == true;
    } catch (e) {
      logger.e('Error checking if app is locked', error: e);
      return false;
    }
  }

  /// Lock an app
  Future<bool> lockApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod('lockApp', {
        'packageName': packageName,
      });
      logger.i('App locked: $packageName');
      return result == true;
    } catch (e) {
      logger.e('Error locking app', error: e);
      return false;
    }
  }

  /// Unlock an app
  Future<bool> unlockApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod('unlockApp', {
        'packageName': packageName,
      });
      logger.i('App unlocked: $packageName');
      return result == true;
    } catch (e) {
      logger.e('Error unlocking app', error: e);
      return false;
    }
  }

  /// Get list of locked apps
  Future<List<String>> getLockedApps() async {
    try {
      final result = await _channel.invokeMethod('getLockedApps');
      if (result is List) {
        return result.map((item) => item.toString()).toList();
      }
      return [];
    } catch (e) {
      logger.e('Error getting locked apps', error: e);
      return [];
    }
  }

  /// Check if overlay permission is granted
  Future<bool> hasOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('hasOverlayPermission');
      return result == true;
    } catch (e) {
      logger.e('Error checking overlay permission', error: e);
      return false;
    }
  }

  /// Request overlay permission
  Future<bool> requestOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('requestOverlayPermission');
      return result == true;
    } catch (e) {
      logger.e('Error requesting overlay permission', error: e);
      return false;
    }
  }

  /// Check if usage stats permission is granted
  Future<bool> hasUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod('hasUsageStatsPermission');
      return result == true;
    } catch (e) {
      logger.e('Error checking usage stats permission', error: e);
      return false;
    }
  }

  /// Request usage stats permission
  Future<bool> requestUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod('requestUsageStatsPermission');
      return result == true;
    } catch (e) {
      logger.e('Error requesting usage stats permission', error: e);
      return false;
    }
  }

  /// Check if accessibility service is enabled
  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final result = await _channel.invokeMethod('isAccessibilityServiceEnabled');
      return result == true;
    } catch (e) {
      logger.e('Error checking accessibility service', error: e);
      return false;
    }
  }

  /// Open accessibility settings
  Future<bool> openAccessibilitySettings() async {
    try {
      final result = await _channel.invokeMethod('openAccessibilitySettings');
      return result == true;
    } catch (e) {
      logger.e('Error opening accessibility settings', error: e);
      return false;
    }
  }

  /// Check if device admin is active
  Future<bool> isDeviceAdminActive() async {
    try {
      final result = await _channel.invokeMethod('isDeviceAdminActive');
      return result == true;
    } catch (e) {
      logger.e('Error checking device admin', error: e);
      return false;
    }
  }

  /// Request device admin permission
  Future<bool> requestDeviceAdmin() async {
    try {
      final result = await _channel.invokeMethod('requestDeviceAdmin');
      return result == true;
    } catch (e) {
      logger.e('Error requesting device admin', error: e);
      return false;
    }
  }
 
  /// Notify native layer to return to the previously opened app after a successful unlock.
  Future<bool> onUnlockSuccess({String? packageName}) async {
    try {
      final result = await _channel.invokeMethod('onUnlockSuccess', {
        'packageName': packageName,
      });
      return result == true;
    } catch (e) {
      logger.e('Error notifying unlock success', error: e);
      return false;
    }
  }

  /// Launch an app by package name
  Future<bool> launchApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod('launchApp', {
        'packageName': packageName,
      });
      logger.i('App launched: $packageName');
      return result == true;
    } catch (e) {
      logger.e('Error launching app', error: e);
      return false;
    }
  }
}
