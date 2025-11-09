import 'package:flutter/foundation.dart';
import '../../core/services/native_service.dart';
import '../../core/utils/logger.dart';

/// Provider for managing app permissions
class PermissionsProvider with ChangeNotifier {
  final NativeService _nativeService = NativeService();

  bool _hasOverlayPermission = false;
  bool _hasUsageStatsPermission = false;
  bool _isAccessibilityServiceEnabled = false;
  bool _isCheckingPermissions = false;

  // Getters
  bool get hasOverlayPermission => _hasOverlayPermission;
  bool get hasUsageStatsPermission => _hasUsageStatsPermission;
  bool get isAccessibilityServiceEnabled => _isAccessibilityServiceEnabled;
  bool get isCheckingPermissions => _isCheckingPermissions;
  bool get hasAllPermissions =>
      _hasOverlayPermission &&
      _hasUsageStatsPermission &&
      _isAccessibilityServiceEnabled;

  /// Check all permissions
  Future<void> checkAllPermissions() async {
    try {
      _isCheckingPermissions = true;
      notifyListeners();

      _hasOverlayPermission = await _nativeService.hasOverlayPermission();
      _hasUsageStatsPermission =
          await _nativeService.hasUsageStatsPermission();
      _isAccessibilityServiceEnabled =
          await _nativeService.isAccessibilityServiceEnabled();

      logger.i(
        'Permissions status - Overlay: $_hasOverlayPermission, '
        'UsageStats: $_hasUsageStatsPermission, '
        'Accessibility: $_isAccessibilityServiceEnabled',
      );
    } catch (e) {
      logger.e('Error checking permissions', error: e);
    } finally {
      _isCheckingPermissions = false;
      notifyListeners();
    }
  }

  /// Request overlay permission
  Future<void> requestOverlayPermission() async {
    try {
      await _nativeService.requestOverlayPermission();
      logger.i('Overlay permission requested');
    } catch (e) {
      logger.e('Error requesting overlay permission', error: e);
    }
  }

  /// Request usage stats permission
  Future<void> requestUsageStatsPermission() async {
    try {
      await _nativeService.requestUsageStatsPermission();
      logger.i('Usage stats permission requested');
    } catch (e) {
      logger.e('Error requesting usage stats permission', error: e);
    }
  }

  /// Open accessibility settings
  Future<void> openAccessibilitySettings() async {
    try {
      await _nativeService.openAccessibilitySettings();
      logger.i('Accessibility settings opened');
    } catch (e) {
      logger.e('Error opening accessibility settings', error: e);
    }
  }

  /// Get list of missing permissions
  List<String> getMissingPermissions() {
    final missing = <String>[];
    if (!_hasOverlayPermission) missing.add('Overlay Permission');
    if (!_hasUsageStatsPermission) missing.add('Usage Stats Permission');
    if (!_isAccessibilityServiceEnabled) missing.add('Accessibility Service');
    return missing;
  }
}
