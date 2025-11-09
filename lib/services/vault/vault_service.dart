import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../../data/models/vault_item_model.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/encryption_service.dart';

/// Service for managing encrypted vault
class VaultService {
  final Logger _logger = Logger();
  final StorageService _storageService = StorageService();
  final EncryptionService _encryptionService = EncryptionService();
  final _uuid = const Uuid();

  Directory? _vaultDirectory;
  Directory? _decoyVaultDirectory;

  /// Initialize vault service
  Future<void> initialize() async {
    try {
      await _storageService.init();
      await _encryptionService.init();

      // Create vault directories
      final appDir = await getApplicationDocumentsDirectory();
      _vaultDirectory = Directory('${appDir.path}/vault');
      _decoyVaultDirectory = Directory('${appDir.path}/decoy_vault');

      if (!await _vaultDirectory!.exists()) {
        await _vaultDirectory!.create(recursive: true);
      }

      if (!await _decoyVaultDirectory!.exists()) {
        await _decoyVaultDirectory!.create(recursive: true);
      }

      _logger.i('Vault service initialized');
    } catch (e) {
      _logger.e('Error initializing vault service', error: e);
    }
  }

  /// Add file to vault
  Future<VaultItemModel?> addToVault({
    required String filePath,
    required String itemType,
    String? category,
    List<String> tags = const [],
    bool isDecoy = false,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.w('File does not exist: $filePath');
        return null;
      }

      // Read file bytes
      final fileBytes = await file.readAsBytes();

      // Encrypt file
      final encryptedBytes = await _encryptionService.encryptBytes(fileBytes);

      // Generate unique file name
      final fileName = '${_uuid.v4()}.enc';
      final vaultDir = isDecoy ? _decoyVaultDirectory! : _vaultDirectory!;
      final encryptedFilePath = '${vaultDir.path}/$fileName';

      // Save encrypted file
      final encryptedFile = File(encryptedFilePath);
      await encryptedFile.writeAsBytes(encryptedBytes);

      // Create vault item model
      final vaultItem = VaultItemModel(
        id: _uuid.v4(),
        itemType: itemType,
        encryptedFilePath: encryptedFilePath,
        originalFileName: filePath.split('/').last,
        fileSizeBytes: fileBytes.length,
        addedAt: DateTime.now(),
        category: category,
        tags: tags,
        isDecoy: isDecoy,
      );

      // Save metadata
      await _saveVaultItem(vaultItem);

      // Delete original file (with user confirmation in UI)
      // await file.delete();

      _logger.i('File added to vault: ${vaultItem.originalFileName}');
      return vaultItem;
    } catch (e) {
      _logger.e('Error adding file to vault', error: e);
      return null;
    }
  }

  /// Get decrypted file from vault
  Future<File?> getFromVault(VaultItemModel item) async {
    try {
      final encryptedFile = File(item.encryptedFilePath);
      if (!await encryptedFile.exists()) {
        _logger.w('Encrypted file not found: ${item.encryptedFilePath}');
        return null;
      }

      // Read encrypted bytes
      final encryptedBytes = await encryptedFile.readAsBytes();

      // Decrypt file
      final decryptedBytes = await _encryptionService.decryptBytes(encryptedBytes);

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/${item.originalFileName}';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(decryptedBytes);

      // Update last accessed time
      final updatedItem = item.copyWith(lastAccessedAt: DateTime.now());
      await _saveVaultItem(updatedItem);

      return tempFile;
    } catch (e) {
      _logger.e('Error getting file from vault', error: e);
      return null;
    }
  }

  /// Get all vault items
  Future<List<VaultItemModel>> getAllVaultItems({bool includeDecoy = false}) async {
    try {
      final box = await _storageService.getBox<VaultItemModel>('vault_metadata');
      final items = box.values.where((item) {
        if (!includeDecoy) {
          return !item.isDecoy;
        }
        return true;
      }).toList();

      items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return items;
    } catch (e) {
      _logger.e('Error getting vault items', error: e);
      return [];
    }
  }

  /// Get vault items by type
  Future<List<VaultItemModel>> getVaultItemsByType(String type, {bool includeDecoy = false}) async {
    final allItems = await getAllVaultItems(includeDecoy: includeDecoy);
    return allItems.where((item) => item.itemType == type).toList();
  }

  /// Delete vault item
  Future<bool> deleteVaultItem(VaultItemModel item) async {
    try {
      // Delete encrypted file
      final file = File(item.encryptedFilePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete metadata
      final box = await _storageService.getBox<VaultItemModel>('vault_metadata');
      await box.delete(item.id);

      _logger.i('Vault item deleted: ${item.originalFileName}');
      return true;
    } catch (e) {
      _logger.e('Error deleting vault item', error: e);
      return false;
    }
  }

  /// Export vault item back to gallery/filesystem
  Future<String?> exportVaultItem(VaultItemModel item, String destinationPath) async {
    try {
      final decryptedFile = await getFromVault(item);
      if (decryptedFile == null) {
        return null;
      }

      // Copy to destination
      final destFile = File(destinationPath);
      await decryptedFile.copy(destFile.path);

      // Clean up temp file
      await decryptedFile.delete();

      _logger.i('Vault item exported: ${item.originalFileName}');
      return destFile.path;
    } catch (e) {
      _logger.e('Error exporting vault item', error: e);
      return null;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(VaultItemModel item) async {
    final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
    await _saveVaultItem(updatedItem);
  }

  /// Save vault item metadata
  Future<void> _saveVaultItem(VaultItemModel item) async {
    try {
      final box = await _storageService.getBox<VaultItemModel>('vault_metadata');
      await box.put(item.id, item);
    } catch (e) {
      _logger.e('Error saving vault item', error: e);
    }
  }

  /// Get vault statistics
  Future<Map<String, dynamic>> getVaultStats() async {
    final items = await getAllVaultItems();

    final photoCount = items.where((i) => i.isPhoto).length;
    final videoCount = items.where((i) => i.isVideo).length;
    final fileCount = items.where((i) => i.isFile).length;
    final totalSize = items.fold<int>(0, (sum, item) => sum + item.fileSizeBytes);

    return {
      'totalItems': items.length,
      'photoCount': photoCount,
      'videoCount': videoCount,
      'fileCount': fileCount,
      'totalSizeBytes': totalSize,
    };
  }
}
