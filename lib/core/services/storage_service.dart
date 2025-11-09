import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'encryption_service.dart';

/// Service for managing all storage operations
/// Uses Hive for local storage and FlutterSecureStorage for sensitive data
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _logger = Logger();
  final _encryptionService = EncryptionService();
  final _secureStorage = const FlutterSecureStorage();

  SharedPreferences? _prefs;
  Box? _settingsBox;
  Box? _lockedAppsBox;
  Box? _securityLogsBox;
  Box? _automationRulesBox;
  Box? _vaultMetadataBox;

  bool _initialized = false;

  /// Initialize storage service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _logger.i('Initializing storage service...');

      // Initialize Hive
      await Hive.initFlutter();

      // Register Hive type adapters
      _registerAdapters();

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Initialize encryption service
      await _encryptionService.initialize();

      // Open Hive boxes
      _settingsBox = await Hive.openBox('settings');
      _lockedAppsBox = await Hive.openBox('locked_apps');
      _securityLogsBox = await Hive.openBox('security_logs');
      _automationRulesBox = await Hive.openBox('automation_rules');
      _vaultMetadataBox = await Hive.openBox('vault_metadata');

      _initialized = true;
      _logger.i('Storage service initialized successfully');
    } catch (e) {
      _logger.e('Error initializing storage service', error: e);
      rethrow;
    }
  }

  /// Register Hive type adapters (placeholder for future use)
  void _registerAdapters() {
    // Note: Currently using JSON serialization instead of Hive type adapters
    // Models store as Map<String, dynamic> in untyped boxes
    _logger.i('Using untyped Hive boxes with JSON serialization');
  }

  /// Ensure storage is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  // ==================== Settings Storage ====================

  /// Save a setting
  Future<void> saveSetting(String key, dynamic value) async {
    await _ensureInitialized();
    try {
      await _settingsBox!.put(key, value);
    } catch (e) {
      _logger.e('Error saving setting: $key', error: e);
      rethrow;
    }
  }

  /// Get a setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      _logger.e('Error getting setting: $key', error: e);
      return defaultValue;
    }
  }

  /// Delete a setting
  Future<void> deleteSetting(String key) async {
    await _ensureInitialized();
    try {
      await _settingsBox!.delete(key);
    } catch (e) {
      _logger.e('Error deleting setting: $key', error: e);
      rethrow;
    }
  }

  // ==================== Secure Storage ====================

  /// Save secure data (encrypted)
  Future<void> saveSecure(String key, String value) async {
    try {
      final encrypted = await _encryptionService.encryptString(value);
      await _secureStorage.write(key: key, value: encrypted);
    } catch (e) {
      _logger.e('Error saving secure data: $key', error: e);
      rethrow;
    }
  }

  /// Get secure data (decrypted)
  Future<String?> getSecure(String key) async {
    try {
      final encrypted = await _secureStorage.read(key: key);
      if (encrypted == null) return null;
      return await _encryptionService.decryptString(encrypted);
    } catch (e) {
      _logger.e('Error getting secure data: $key', error: e);
      return null;
    }
  }

  /// Delete secure data
  Future<void> deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      _logger.e('Error deleting secure data: $key', error: e);
      rethrow;
    }
  }

  // ==================== Locked Apps Storage ====================

  /// Save locked apps list
  Future<void> saveLockedApps(List<String> packageNames) async {
    await _ensureInitialized();
    try {
      await _lockedAppsBox!.put('locked_apps', packageNames);

      // Also save to SharedPreferences for native access
      await _prefs!.setString('flutter.locked_apps', packageNames.join(','));
    } catch (e) {
      _logger.e('Error saving locked apps', error: e);
      rethrow;
    }
  }

  /// Get locked apps list
  List<String> getLockedApps() {
    try {
      final apps = _lockedAppsBox?.get('locked_apps', defaultValue: <String>[]);
      return List<String>.from(apps ?? []);
    } catch (e) {
      _logger.e('Error getting locked apps', error: e);
      return [];
    }
  }

  /// Add an app to locked list
  Future<void> addLockedApp(String packageName) async {
    await _ensureInitialized();
    try {
      final lockedApps = getLockedApps();
      if (!lockedApps.contains(packageName)) {
        lockedApps.add(packageName);
        await saveLockedApps(lockedApps);
      }
    } catch (e) {
      _logger.e('Error adding locked app: $packageName', error: e);
      rethrow;
    }
  }

  /// Remove an app from locked list
  Future<void> removeLockedApp(String packageName) async {
    await _ensureInitialized();
    try {
      final lockedApps = getLockedApps();
      lockedApps.remove(packageName);
      await saveLockedApps(lockedApps);
    } catch (e) {
      _logger.e('Error removing locked app: $packageName', error: e);
      rethrow;
    }
  }

  /// Check if an app is locked
  bool isAppLocked(String packageName) {
    final lockedApps = getLockedApps();
    return lockedApps.contains(packageName);
  }

  // ==================== Security Logs Storage ====================

  /// Save a security log
  Future<void> saveSecurityLog(Map<String, dynamic> log) async {
    await _ensureInitialized();
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _securityLogsBox!.put(timestamp, log);
    } catch (e) {
      _logger.e('Error saving security log', error: e);
      rethrow;
    }
  }

  /// Get all security logs
  List<Map<String, dynamic>> getSecurityLogs() {
    try {
      final logs = <Map<String, dynamic>>[];
      for (var key in _securityLogsBox?.keys ?? []) {
        final log = _securityLogsBox!.get(key);
        if (log != null) {
          logs.add(Map<String, dynamic>.from(log));
        }
      }
      return logs..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    } catch (e) {
      _logger.e('Error getting security logs', error: e);
      return [];
    }
  }

  /// Clear all security logs
  Future<void> clearSecurityLogs() async {
    await _ensureInitialized();
    try {
      await _securityLogsBox!.clear();
    } catch (e) {
      _logger.e('Error clearing security logs', error: e);
      rethrow;
    }
  }

  // ==================== Automation Rules Storage ====================

  /// Save automation rules
  Future<void> saveAutomationRules(List<Map<String, dynamic>> rules) async {
    await _ensureInitialized();
    try {
      await _automationRulesBox!.put('rules', rules);
    } catch (e) {
      _logger.e('Error saving automation rules', error: e);
      rethrow;
    }
  }

  /// Get automation rules
  List<Map<String, dynamic>> getAutomationRules() {
    try {
      final rules = _automationRulesBox?.get('rules', defaultValue: []);
      return List<Map<String, dynamic>>.from(rules ?? []);
    } catch (e) {
      _logger.e('Error getting automation rules', error: e);
      return [];
    }
  }

  // ==================== Vault Metadata Storage ====================

  /// Save vault item metadata
  Future<void> saveVaultItem(String id, Map<String, dynamic> metadata) async {
    await _ensureInitialized();
    try {
      await _vaultMetadataBox!.put(id, metadata);
    } catch (e) {
      _logger.e('Error saving vault item: $id', error: e);
      rethrow;
    }
  }

  /// Get vault item metadata
  Map<String, dynamic>? getVaultItem(String id) {
    try {
      final item = _vaultMetadataBox?.get(id);
      return item != null ? Map<String, dynamic>.from(item) : null;
    } catch (e) {
      _logger.e('Error getting vault item: $id', error: e);
      return null;
    }
  }

  /// Get all vault items
  List<Map<String, dynamic>> getAllVaultItems() {
    try {
      final items = <Map<String, dynamic>>[];
      for (var key in _vaultMetadataBox?.keys ?? []) {
        final item = _vaultMetadataBox!.get(key);
        if (item != null) {
          items.add(Map<String, dynamic>.from(item));
        }
      }
      return items;
    } catch (e) {
      _logger.e('Error getting all vault items', error: e);
      return [];
    }
  }

  /// Delete vault item metadata
  Future<void> deleteVaultItem(String id) async {
    await _ensureInitialized();
    try {
      await _vaultMetadataBox!.delete(id);
    } catch (e) {
      _logger.e('Error deleting vault item: $id', error: e);
      rethrow;
    }
  }

  // ==================== Helper Methods ====================

  /// Alias for initialize (for compatibility)
  Future<void> init() async {
    await initialize();
  }

  /// Save boolean value
  Future<void> saveBool(String key, bool value) async {
    await saveSetting(key, value);
  }

  /// Get boolean value
  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return getSetting<bool>(key);
  }

  /// Save integer value
  Future<void> saveInt(String key, int value) async {
    await saveSetting(key, value);
  }

  /// Get integer value
  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return getSetting<int>(key);
  }

  /// Get a Hive box (generic method for accessing boxes)
  Future<Box<T>> getBox<T>(String boxName) async {
    await _ensureInitialized();
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      } else {
        return await Hive.openBox<T>(boxName);
      }
    } catch (e) {
      _logger.e('Error getting box: $boxName', error: e);
      rethrow;
    }
  }

  // ==================== Utility Methods ====================

  /// Clear all data (factory reset)
  Future<void> clearAllData() async {
    await _ensureInitialized();
    try {
      _logger.w('Clearing all data...');

      await _settingsBox!.clear();
      await _lockedAppsBox!.clear();
      await _securityLogsBox!.clear();
      await _automationRulesBox!.clear();
      await _vaultMetadataBox!.clear();
      await _prefs!.clear();
      await _secureStorage.deleteAll();
      await _encryptionService.clearKeys();

      _logger.w('All data cleared successfully');
    } catch (e) {
      _logger.e('Error clearing all data', error: e);
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> close() async {
    try {
      await _settingsBox?.close();
      await _lockedAppsBox?.close();
      await _securityLogsBox?.close();
      await _automationRulesBox?.close();
      await _vaultMetadataBox?.close();
      _initialized = false;
    } catch (e) {
      _logger.e('Error closing storage', error: e);
    }
  }
}
