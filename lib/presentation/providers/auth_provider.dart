import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/encryption_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/logger.dart';

/// Authentication provider managing PIN, Password, and Biometric authentication
class AuthProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final EncryptionService _encryptionService = EncryptionService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthMethod _authMethod = AuthMethod.none;
  bool _isAuthenticated = false;
  bool _hasSetupAuth = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  // Getters
  AuthMethod get authMethod => _authMethod;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasSetupAuth => _hasSetupAuth;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;
  int get failedAttempts => _failedAttempts;
  bool get isLockedOut => _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);
  int get remainingAttempts => AppConstants.maxAuthAttempts - _failedAttempts;

  /// Initialize authentication provider
  Future<void> initialize() async {
    try {
      await _storageService.initialize();
      await _encryptionService.initialize();

      // Load saved auth method
      final savedMethod = _storageService.getSetting<String>(AppConstants.keyAuthMethod);
      if (savedMethod != null) {
        _authMethod = AuthMethod.values.firstWhere(
          (e) => e.toString().split('.').last == savedMethod,
          orElse: () => AuthMethod.none,
        );
      }

      // Check if auth is setup
      _hasSetupAuth = _storageService.getSetting<bool>(
            AppConstants.keyHasSetupAuth,
            defaultValue: false,
          ) ??
          false;

      // Load biometric settings
      _biometricEnabled = _storageService.getSetting<bool>(
            AppConstants.keyBiometricEnabled,
            defaultValue: false,
          ) ??
          false;

      // Check biometric availability (may fail on web)
      try {
        _biometricAvailable = await _localAuth.canCheckBiometrics;
      } catch (e) {
        _biometricAvailable = false;
        logger.w('Biometric not available on this platform');
      }

      // Load failed attempts and lockout
      _failedAttempts = _storageService.getSetting<int>(
            AppConstants.keyFailedAttempts,
            defaultValue: 0,
          ) ??
          0;

      final lockoutTimestamp = _storageService.getSetting<int>(AppConstants.keyLockoutUntil);
      if (lockoutTimestamp != null) {
        _lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
        // Clear lockout if expired
        if (!isLockedOut) {
          _lockoutUntil = null;
          await _storageService.deleteSetting(AppConstants.keyLockoutUntil);
        }
      }

      logger.i('AuthProvider initialized - Method: $_authMethod, Setup: $_hasSetupAuth');
      notifyListeners();
    } catch (e) {
      logger.e('Error initializing AuthProvider', error: e);
      rethrow;
    }
  }

  /// Setup PIN authentication
  Future<bool> setupPin(String pin) async {
    try {
      if (pin.length < AppConstants.minPinLength || pin.length > AppConstants.maxPinLength) {
        return false;
      }

      final pinHash = _encryptionService.hashPassword(pin);
      await _storageService.saveSecure(AppConstants.keyPinHash, pinHash);
      await _storageService.saveSetting(AppConstants.keyAuthMethod, AuthMethod.pin.toString().split('.').last);
      await _storageService.saveSetting(AppConstants.keyHasSetupAuth, true);

      _authMethod = AuthMethod.pin;
      _hasSetupAuth = true;
      _isAuthenticated = true;

      logger.i('PIN authentication setup successfully');
      notifyListeners();
      return true;
    } catch (e) {
      logger.e('Error setting up PIN', error: e);
      return false;
    }
  }

  /// Setup Password authentication
  Future<bool> setupPassword(String password) async {
    try {
      if (password.length < AppConstants.minPasswordLength) {
        return false;
      }

      final passwordHash = _encryptionService.hashPassword(password);
      await _storageService.saveSecure(AppConstants.keyPasswordHash, passwordHash);
      await _storageService.saveSetting(AppConstants.keyAuthMethod, AuthMethod.password.toString().split('.').last);
      await _storageService.saveSetting(AppConstants.keyHasSetupAuth, true);

      _authMethod = AuthMethod.password;
      _hasSetupAuth = true;
      _isAuthenticated = true;

      logger.i('Password authentication setup successfully');
      notifyListeners();
      return true;
    } catch (e) {
      logger.e('Error setting up password', error: e);
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    if (isLockedOut) {
      logger.w('Authentication locked out');
      return false;
    }

    try {
      final storedHash = await _storageService.getSecure(AppConstants.keyPinHash);
      if (storedHash == null) {
        return false;
      }

      final isValid = _encryptionService.verifyPassword(pin, storedHash);
      await _handleAuthResult(isValid);
      return isValid;
    } catch (e) {
      logger.e('Error verifying PIN', error: e);
      return false;
    }
  }

  /// Verify Password
  Future<bool> verifyPassword(String password) async {
    if (isLockedOut) {
      logger.w('Authentication locked out');
      return false;
    }

    try {
      final storedHash = await _storageService.getSecure(AppConstants.keyPasswordHash);
      if (storedHash == null) {
        return false;
      }

      final isValid = _encryptionService.verifyPassword(password, storedHash);
      await _handleAuthResult(isValid);
      return isValid;
    } catch (e) {
      logger.e('Error verifying password', error: e);
      return false;
    }
  }

  /// Setup pattern authentication
  Future<void> setupPattern(String pattern) async {
    try {
      final patternHash = _encryptionService.hashPassword(pattern);
      await _storageService.saveSecure('pattern_hash', patternHash);
      await _storageService.saveSetting(AppConstants.keyAuthMethod, AuthMethod.pattern.toString());
      await _storageService.saveSetting(AppConstants.keyHasSetupAuth, true);

      _authMethod = AuthMethod.pattern;
      _hasSetupAuth = true;
      logger.i('Pattern lock setup completed');
      notifyListeners();
    } catch (e) {
      logger.e('Error setting up pattern', error: e);
      rethrow;
    }
  }

  /// Verify pattern authentication
  Future<bool> verifyPattern(String pattern) async {
    try {
      if (isLockedOut) {
        logger.w('User is locked out - cannot verify pattern');
        return false;
      }

      final storedHash = await _storageService.getSecure('pattern_hash');
      if (storedHash == null) {
        logger.e('Pattern hash not found');
        return false;
      }

      final isValid = _encryptionService.verifyPassword(pattern, storedHash);
      await _handleAuthResult(isValid);
      return isValid;
    } catch (e) {
      logger.e('Error verifying pattern', error: e);
      return false;
    }
  }

  /// Authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    if (!_biometricAvailable || !_biometricEnabled) {
      return false;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _isAuthenticated = true;
        await _resetFailedAttempts();
        notifyListeners();
      }

      return authenticated;
    } catch (e) {
      logger.e('Error during biometric authentication', error: e);
      return false;
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      if (!_biometricAvailable) {
        logger.w('Biometric not available on this device');
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to enable biometric',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await _storageService.saveSetting(AppConstants.keyBiometricEnabled, true);
        _biometricEnabled = true;
        logger.i('Biometric authentication enabled');
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      logger.e('Error enabling biometric', error: e);
      return false;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    try {
      await _storageService.saveSetting(AppConstants.keyBiometricEnabled, false);
      _biometricEnabled = false;
      logger.i('Biometric authentication disabled');
      notifyListeners();
    } catch (e) {
      logger.e('Error disabling biometric', error: e);
    }
  }

  /// Handle authentication result
  Future<void> _handleAuthResult(bool success) async {
    if (success) {
      _isAuthenticated = true;
      await _resetFailedAttempts();
      logger.i('Authentication successful');
    } else {
      _failedAttempts++;
      await _storageService.saveSetting(AppConstants.keyFailedAttempts, _failedAttempts);
      logger.w('Authentication failed - Attempts: $_failedAttempts');

      // Check if max attempts exceeded
      if (_failedAttempts >= AppConstants.maxAuthAttempts) {
        await _lockoutUser();
      }
    }
    notifyListeners();
  }

  /// Lockout user after max failed attempts
  Future<void> _lockoutUser() async {
    _lockoutUntil = DateTime.now().add(
      Duration(seconds: AppConstants.authLockoutDurationSeconds),
    );
    await _storageService.saveSetting(
      AppConstants.keyLockoutUntil,
      _lockoutUntil!.millisecondsSinceEpoch,
    );
    logger.w('User locked out until: $_lockoutUntil');
  }

  /// Reset failed attempts
  Future<void> _resetFailedAttempts() async {
    _failedAttempts = 0;
    _lockoutUntil = null;
    await _storageService.deleteSetting(AppConstants.keyFailedAttempts);
    await _storageService.deleteSetting(AppConstants.keyLockoutUntil);
  }

  /// Logout user
  void logout() {
    _isAuthenticated = false;
    logger.i('User logged out');
    notifyListeners();
  }

  /// Reset authentication (factory reset)
  Future<void> resetAuth() async {
    try {
      await _storageService.deleteSecure(AppConstants.keyPinHash);
      await _storageService.deleteSecure(AppConstants.keyPasswordHash);
      await _storageService.deleteSetting(AppConstants.keyAuthMethod);
      await _storageService.deleteSetting(AppConstants.keyHasSetupAuth);
      await _storageService.deleteSetting(AppConstants.keyBiometricEnabled);
      await _resetFailedAttempts();

      _authMethod = AuthMethod.none;
      _hasSetupAuth = false;
      _isAuthenticated = false;
      _biometricEnabled = false;

      logger.w('Authentication reset');
      notifyListeners();
    } catch (e) {
      logger.e('Error resetting authentication', error: e);
    }
  }
}
