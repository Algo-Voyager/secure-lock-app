import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/encryption_service.dart';
import '../../data/models/locked_app_model.dart';
import '../../data/models/user_settings_model.dart';
import '../../data/models/automation_rule_model.dart';

/// Service for backup and restore functionality
class BackupService {
  final Logger _logger = Logger();
  final StorageService _storageService = StorageService();
  final EncryptionService _encryptionService = EncryptionService();

  /// Create backup of all app data
  Future<String?> createBackup({bool includeVault = false}) async {
    try {
      await _storageService.init();
      await _encryptionService.init();

      // Collect data from all boxes
      final backupData = <String, dynamic>{
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'lockedApps': await _getLockedApps(),
        'settings': await _getSettings(),
        'automationRules': await _getAutomationRules(),
        'vaultMetadata': includeVault ? await _getVaultMetadata() : [],
      };

      // Convert to JSON
      final jsonString = jsonEncode(backupData);

      // Encrypt backup
      final encryptedBackup = await _encryptionService.encryptString(jsonString);

      // Save to file
      final directory = await getExternalStorageDirectory() ??
                       await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/Backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${backupDir.path}/secure_lock_backup_$timestamp.slb';
      final file = File(filePath);
      await file.writeAsString(encryptedBackup);

      _logger.i('Backup created successfully: $filePath');
      return filePath;
    } catch (e) {
      _logger.e('Error creating backup', error: e);
      return null;
    }
  }

  /// Restore data from backup file
  Future<bool> restoreBackup(String backupFilePath) async {
    try {
      final file = File(backupFilePath);
      if (!await file.exists()) {
        _logger.w('Backup file not found: $backupFilePath');
        return false;
      }

      // Read encrypted backup
      final encryptedBackup = await file.readAsString();

      // Decrypt backup
      final jsonString = await _encryptionService.decryptString(encryptedBackup);

      // Parse JSON
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Restore data to boxes
      await _restoreLockedApps(backupData['lockedApps']);
      await _restoreSettings(backupData['settings']);
      await _restoreAutomationRules(backupData['automationRules']);

      if (backupData['vaultMetadata'] != null) {
        await _restoreVaultMetadata(backupData['vaultMetadata']);
      }

      _logger.i('Backup restored successfully');
      return true;
    } catch (e) {
      _logger.e('Error restoring backup', error: e);
      return false;
    }
  }

  /// Share backup file
  Future<void> shareBackup(String backupFilePath) async {
    try {
      await Share.shareXFiles(
        [XFile(backupFilePath)],
        subject: 'Secure Lock Backup',
        text: 'Secure Lock app backup file',
      );
    } catch (e) {
      _logger.e('Error sharing backup', error: e);
    }
  }

  /// Get list of available backups
  Future<List<File>> getAvailableBackups() async {
    try {
      final directory = await getExternalStorageDirectory() ??
                       await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/Backups');

      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir.list().toList();
      return files
          .whereType<File>()
          .where((file) => file.path.endsWith('.slb'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path)); // Sort by newest first
    } catch (e) {
      _logger.e('Error getting available backups', error: e);
      return [];
    }
  }

  /// Delete backup file
  Future<bool> deleteBackup(String backupFilePath) async {
    try {
      final file = File(backupFilePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error deleting backup', error: e);
      return false;
    }
  }

  // Helper methods to get data from storage

  Future<List<Map<String, dynamic>>> _getLockedApps() async {
    try {
      final box = await _storageService.getBox<LockedAppModel>('locked_apps');
      return box.values.map((app) => app.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getSettings() async {
    try {
      final box = await _storageService.getBox<UserSettingsModel>('settings');
      final settings = box.get('user_settings');
      return settings?.toJson();
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _getAutomationRules() async {
    try {
      final box = await _storageService.getBox<AutomationRuleModel>('automation_rules');
      return box.values.map((rule) => rule.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getVaultMetadata() async {
    try {
      final box = await _storageService.getBox('vault_metadata');
      return box.values
          .map((item) => (item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Helper methods to restore data

  Future<void> _restoreLockedApps(dynamic data) async {
    try {
      if (data == null) return;
      final box = await _storageService.getBox<LockedAppModel>('locked_apps');
      await box.clear();

      for (final item in data as List) {
        final app = LockedAppModel.fromJson(item as Map<String, dynamic>);
        await box.put(app.packageName, app);
      }
    } catch (e) {
      _logger.e('Error restoring locked apps', error: e);
    }
  }

  Future<void> _restoreSettings(dynamic data) async {
    try {
      if (data == null) return;
      final box = await _storageService.getBox<UserSettingsModel>('settings');
      final settings = UserSettingsModel.fromJson(data as Map<String, dynamic>);
      await box.put('user_settings', settings);
    } catch (e) {
      _logger.e('Error restoring settings', error: e);
    }
  }

  Future<void> _restoreAutomationRules(dynamic data) async {
    try {
      if (data == null) return;
      final box = await _storageService.getBox<AutomationRuleModel>('automation_rules');
      await box.clear();

      for (final item in data as List) {
        final rule = AutomationRuleModel.fromJson(item as Map<String, dynamic>);
        await box.put(rule.id, rule);
      }
    } catch (e) {
      _logger.e('Error restoring automation rules', error: e);
    }
  }

  Future<void> _restoreVaultMetadata(dynamic data) async {
    try {
      if (data == null) return;
      final box = await _storageService.getBox('vault_metadata');
      await box.clear();

      for (final item in data as List) {
        // VaultItemModel restoration logic here
      }
    } catch (e) {
      _logger.e('Error restoring vault metadata', error: e);
    }
  }
}
