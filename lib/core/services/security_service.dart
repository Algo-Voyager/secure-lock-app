import 'dart:io';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

/// Security service for root detection, tamper detection, and security checks
class SecurityService {
  /// Check if device is rooted
  Future<bool> isDeviceRooted() async {
    try {
      // Check 1: Look for su binary in common locations
      final suPaths = [
        '/system/bin/su',
        '/system/xbin/su',
        '/sbin/su',
        '/system/su',
        '/system/bin/.ext/.su',
        '/system/usr/we-need-root/su-backup',
        '/system/xbin/mu',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
      ];

      for (final path in suPaths) {
        if (await File(path).exists()) {
          logger.w('Root detected: su binary found at $path');
          return true;
        }
      }

      // Check 2: Look for common root management apps
      final rootApps = [
        'com.noshufou.android.su',
        'com.noshufou.android.su.elite',
        'eu.chainfire.supersu',
        'com.koushikdutta.superuser',
        'com.thirdparty.superuser',
        'com.yellowes.su',
        'com.topjohnwu.magisk',
        'me.phh.superuser',
        'com.kingroot.kinguser',
        'com.kingo.root',
      ];

      for (final packageName in rootApps) {
        try {
          // Check if package exists (platform-specific implementation needed)
          // For now, we'll skip this check as it requires Android-specific code
        } catch (e) {
          // Package not found, continue
        }
      }

      // Check 3: Check for RW system partition
      try {
        final result = await Process.run('mount', []);
        if (result.stdout.toString().contains('/system') &&
            result.stdout.toString().contains('rw')) {
          logger.w('Root detected: System partition is RW');
          return true;
        }
      } catch (e) {
        // Can't check mount, continue
      }

      // Check 4: Check build tags for test-keys
      try {
        final buildTags = Platform.operatingSystemVersion;
        if (buildTags.contains('test-keys')) {
          logger.w('Root detected: Build contains test-keys');
          return true;
        }
      } catch (e) {
        // Can't check build tags
      }

      return false;
    } catch (e) {
      logger.e('Error checking root status', error: e);
      return false;
    }
  }

  /// Check if USB debugging is enabled
  Future<bool> isUsbDebuggingEnabled() async {
    try {
      // This requires Android-specific implementation via method channel
      // For now, return false as a placeholder
      return false;
    } catch (e) {
      logger.e('Error checking USB debugging', error: e);
      return false;
    }
  }

  /// Check if developer options are enabled
  Future<bool> isDeveloperModeEnabled() async {
    try {
      // This requires Android-specific implementation via method channel
      // For now, return false as a placeholder
      return false;
    } catch (e) {
      logger.e('Error checking developer mode', error: e);
      return false;
    }
  }

  /// Check if screen recording is active
  Future<bool> isScreenRecordingActive() async {
    try {
      // This requires Android-specific implementation
      // For now, return false as a placeholder
      return false;
    } catch (e) {
      logger.e('Error checking screen recording', error: e);
      return false;
    }
  }

  /// Perform comprehensive security check
  Future<SecurityCheckResult> performSecurityCheck() async {
    final isRooted = await isDeviceRooted();
    final isUsbDebugging = await isUsbDebuggingEnabled();
    final isDeveloperMode = await isDeveloperModeEnabled();
    final isScreenRecording = await isScreenRecordingActive();

    return SecurityCheckResult(
      isRooted: isRooted,
      isUsbDebuggingEnabled: isUsbDebugging,
      isDeveloperModeEnabled: isDeveloperMode,
      isScreenRecordingActive: isScreenRecording,
    );
  }

  /// Check if app has been tampered with
  Future<bool> isAppTampered() async {
    try {
      // Check app signature (requires platform-specific implementation)
      // For now, return false
      return false;
    } catch (e) {
      logger.e('Error checking app tampering', error: e);
      return false;
    }
  }

  /// Get device security info
  Future<Map<String, dynamic>> getSecurityInfo() async {
    final result = await performSecurityCheck();
    return {
      'isRooted': result.isRooted,
      'isUsbDebuggingEnabled': result.isUsbDebuggingEnabled,
      'isDeveloperModeEnabled': result.isDeveloperModeEnabled,
      'isScreenRecordingActive': result.isScreenRecordingActive,
      'isSecure': result.isSecure,
      'threats': result.threats,
    };
  }
}

/// Result of security check
class SecurityCheckResult {
  final bool isRooted;
  final bool isUsbDebuggingEnabled;
  final bool isDeveloperModeEnabled;
  final bool isScreenRecordingActive;

  SecurityCheckResult({
    required this.isRooted,
    required this.isUsbDebuggingEnabled,
    required this.isDeveloperModeEnabled,
    required this.isScreenRecordingActive,
  });

  /// Check if device is secure (no threats detected)
  bool get isSecure =>
      !isRooted &&
      !isUsbDebuggingEnabled &&
      !isScreenRecordingActive;

  /// Get list of detected threats
  List<String> get threats {
    final List<String> threatList = [];
    if (isRooted) threatList.add('Device is rooted');
    if (isUsbDebuggingEnabled) threatList.add('USB debugging enabled');
    if (isDeveloperModeEnabled) threatList.add('Developer mode enabled');
    if (isScreenRecordingActive) threatList.add('Screen recording active');
    return threatList;
  }

  /// Get security level (1-5, where 5 is most secure)
  int get securityLevel {
    int level = 5;
    if (isRooted) level -= 2;
    if (isUsbDebuggingEnabled) level -= 1;
    if (isDeveloperModeEnabled) level -= 1;
    if (isScreenRecordingActive) level -= 1;
    return level.clamp(1, 5);
  }
}
