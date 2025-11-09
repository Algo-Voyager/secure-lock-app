import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import '../utils/logger.dart';

/// Service for managing decoy mode
/// Decoy mode shows fake empty data when authenticated with a decoy PIN/password
class DecoyService {
  final StorageService _storageService = StorageService();

  static const String _keyDecoyEnabled = 'decoy_enabled';
  static const String _keyDecoyPin = 'decoy_pin';
  static const String _keyDecoyPassword = 'decoy_password';
  static const String _keyDecoyPattern = 'decoy_pattern';
  static const String _keyIsInDecoyMode = 'is_in_decoy_mode';

  /// Check if decoy mode is enabled
  Future<bool> isDecoyEnabled() async {
    try {
      return _storageService.getSetting<bool>(_keyDecoyEnabled) ?? false;
    } catch (e) {
      logger.e('Error checking decoy mode', error: e);
      return false;
    }
  }

  /// Enable decoy mode
  Future<void> enableDecoyMode() async {
    try {
      await _storageService.saveSetting(_keyDecoyEnabled, true);
      logger.i('Decoy mode enabled');
    } catch (e) {
      logger.e('Error enabling decoy mode', error: e);
      rethrow;
    }
  }

  /// Disable decoy mode
  Future<void> disableDecoyMode() async {
    try {
      await _storageService.saveSetting(_keyDecoyEnabled, false);
      await _storageService.deleteSetting(_keyIsInDecoyMode);
      await _storageService.deleteSecure(_keyDecoyPin);
      await _storageService.deleteSecure(_keyDecoyPassword);
      await _storageService.deleteSecure(_keyDecoyPattern);
      logger.i('Decoy mode disabled');
    } catch (e) {
      logger.e('Error disabling decoy mode', error: e);
      rethrow;
    }
  }

  /// Set decoy PIN
  Future<void> setDecoyPin(String pinHash) async {
    try {
      await _storageService.saveSecure(_keyDecoyPin, pinHash);
      await enableDecoyMode();
      logger.i('Decoy PIN set');
    } catch (e) {
      logger.e('Error setting decoy PIN', error: e);
      rethrow;
    }
  }

  /// Set decoy password
  Future<void> setDecoyPassword(String passwordHash) async {
    try {
      await _storageService.saveSecure(_keyDecoyPassword, passwordHash);
      await enableDecoyMode();
      logger.i('Decoy password set');
    } catch (e) {
      logger.e('Error setting decoy password', error: e);
      rethrow;
    }
  }

  /// Set decoy pattern
  Future<void> setDecoyPattern(String patternHash) async {
    try {
      await _storageService.saveSecure(_keyDecoyPattern, patternHash);
      await enableDecoyMode();
      logger.i('Decoy pattern set');
    } catch (e) {
      logger.e('Error setting decoy pattern', error: e);
      rethrow;
    }
  }

  /// Get decoy PIN hash
  Future<String?> getDecoyPin() async {
    try {
      return await _storageService.getSecure(_keyDecoyPin);
    } catch (e) {
      logger.e('Error getting decoy PIN', error: e);
      return null;
    }
  }

  /// Get decoy password hash
  Future<String?> getDecoyPassword() async {
    try {
      return await _storageService.getSecure(_keyDecoyPassword);
    } catch (e) {
      logger.e('Error getting decoy password', error: e);
      return null;
    }
  }

  /// Get decoy pattern hash
  Future<String?> getDecoyPattern() async {
    try {
      return await _storageService.getSecure(_keyDecoyPattern);
    } catch (e) {
      logger.e('Error getting decoy pattern', error: e);
      return null;
    }
  }

  /// Check if currently in decoy mode
  bool isInDecoyMode() {
    try {
      return _storageService.getSetting<bool>(_keyIsInDecoyMode) ?? false;
    } catch (e) {
      logger.e('Error checking if in decoy mode', error: e);
      return false;
    }
  }

  /// Enter decoy mode
  Future<void> enterDecoyMode() async {
    try {
      await _storageService.saveSetting(_keyIsInDecoyMode, true);
      logger.w('Entered decoy mode');
    } catch (e) {
      logger.e('Error entering decoy mode', error: e);
      rethrow;
    }
  }

  /// Exit decoy mode
  Future<void> exitDecoyMode() async {
    try {
      await _storageService.saveSetting(_keyIsInDecoyMode, false);
      logger.i('Exited decoy mode');
    } catch (e) {
      logger.e('Error exiting decoy mode', error: e);
      rethrow;
    }
  }

  /// Get decoy data (fake empty data)
  Map<String, dynamic> getDecoyData() {
    return {
      'lockedApps': <String>[], // Empty list of locked apps
      'vaultItems': <String>[], // Empty vault
      'intruderPhotos': <String>[], // No intruder photos
      'automationRules': <String>[], // No automation rules
      'settings': {
        'theme': 'light',
        'biometricEnabled': false,
        'intruderDetectionEnabled': false,
      },
    };
  }
}

/// Provider for decoy mode
class DecoyProvider extends ChangeNotifier {
  final DecoyService _decoyService = DecoyService();

  bool _isDecoyEnabled = false;
  bool _isInDecoyMode = false;

  bool get isDecoyEnabled => _isDecoyEnabled;
  bool get isInDecoyMode => _isInDecoyMode;

  /// Initialize decoy provider
  Future<void> initialize() async {
    _isDecoyEnabled = await _decoyService.isDecoyEnabled();
    _isInDecoyMode = _decoyService.isInDecoyMode();
    notifyListeners();
  }

  /// Enable decoy mode
  Future<void> enableDecoy() async {
    await _decoyService.enableDecoyMode();
    _isDecoyEnabled = true;
    notifyListeners();
  }

  /// Disable decoy mode
  Future<void> disableDecoy() async {
    await _decoyService.disableDecoyMode();
    _isDecoyEnabled = false;
    _isInDecoyMode = false;
    notifyListeners();
  }

  /// Set decoy PIN
  Future<void> setDecoyPin(String pinHash) async {
    await _decoyService.setDecoyPin(pinHash);
    _isDecoyEnabled = true;
    notifyListeners();
  }

  /// Set decoy password
  Future<void> setDecoyPassword(String passwordHash) async {
    await _decoyService.setDecoyPassword(passwordHash);
    _isDecoyEnabled = true;
    notifyListeners();
  }

  /// Set decoy pattern
  Future<void> setDecoyPattern(String patternHash) async {
    await _decoyService.setDecoyPattern(patternHash);
    _isDecoyEnabled = true;
    notifyListeners();
  }

  /// Enter decoy mode
  Future<void> enterDecoy() async {
    await _decoyService.enterDecoyMode();
    _isInDecoyMode = true;
    notifyListeners();
  }

  /// Exit decoy mode
  Future<void> exitDecoy() async {
    await _decoyService.exitDecoyMode();
    _isInDecoyMode = false;
    notifyListeners();
  }

  /// Check if credentials are decoy credentials
  Future<bool> isDecoyCredentials(String input, String type) async {
    switch (type) {
      case 'pin':
        final decoyPin = await _decoyService.getDecoyPin();
        return decoyPin == input;
      case 'password':
        final decoyPassword = await _decoyService.getDecoyPassword();
        return decoyPassword == input;
      case 'pattern':
        final decoyPattern = await _decoyService.getDecoyPattern();
        return decoyPattern == input;
      default:
        return false;
    }
  }
}
