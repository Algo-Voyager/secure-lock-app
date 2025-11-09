import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';

/// Provider for managing app theme
class ThemeProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  /// Initialize theme provider
  Future<void> initialize() async {
    await _storageService.initialize();
    final savedMode = _storageService.getSetting<String>(AppConstants.keyThemeMode);
    if (savedMode != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (e) => e.toString().split('.').last == savedMode,
        orElse: () => AppThemeMode.system,
      );
    }
    notifyListeners();
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _storageService.saveSetting(
      AppConstants.keyThemeMode,
      mode.toString().split('.').last,
    );
    notifyListeners();
  }

  /// Get ThemeMode for MaterialApp
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
