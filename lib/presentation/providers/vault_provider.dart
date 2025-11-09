import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../data/models/vault_item_model.dart';
import '../../services/vault/vault_service.dart';

/// Provider for vault state
class VaultProvider with ChangeNotifier {
  final VaultService _vaultService = VaultService();

  List<VaultItemModel> _vaultItems = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _stats;

  List<VaultItemModel> get vaultItems => _vaultItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get stats => _stats;

  /// Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _vaultService.initialize();
      await loadVaultItems();
      await loadStats();
      _error = null;
    } catch (e) {
      _error = 'Error initializing vault: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all vault items
  Future<void> loadVaultItems({bool includeDecoy = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _vaultItems = await _vaultService.getAllVaultItems(includeDecoy: includeDecoy);
      _error = null;
    } catch (e) {
      _error = 'Error loading vault items: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
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
      final item = await _vaultService.addToVault(
        filePath: filePath,
        itemType: itemType,
        category: category,
        tags: tags,
        isDecoy: isDecoy,
      );

      if (item != null) {
        _vaultItems.insert(0, item);
        await loadStats();
        notifyListeners();
      }

      return item;
    } catch (e) {
      _error = 'Error adding to vault: $e';
      debugPrint(_error);
      notifyListeners();
      return null;
    }
  }

  /// Get decrypted file from vault
  Future<File?> getFromVault(VaultItemModel item) async {
    try {
      return await _vaultService.getFromVault(item);
    } catch (e) {
      _error = 'Error getting from vault: $e';
      debugPrint(_error);
      notifyListeners();
      return null;
    }
  }

  /// Delete vault item
  Future<bool> deleteItem(VaultItemModel item) async {
    try {
      final success = await _vaultService.deleteVaultItem(item);
      if (success) {
        _vaultItems.removeWhere((i) => i.id == item.id);
        await loadStats();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Error deleting item: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Export vault item
  Future<String?> exportItem(VaultItemModel item, String destinationPath) async {
    try {
      return await _vaultService.exportVaultItem(item, destinationPath);
    } catch (e) {
      _error = 'Error exporting item: $e';
      debugPrint(_error);
      notifyListeners();
      return null;
    }
  }

  /// Toggle favorite
  Future<void> toggleFavorite(VaultItemModel item) async {
    try {
      await _vaultService.toggleFavorite(item);
      final index = _vaultItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _vaultItems[index] = item.copyWith(isFavorite: !item.isFavorite);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error toggling favorite: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Load vault statistics
  Future<void> loadStats() async {
    try {
      _stats = await _vaultService.getVaultStats();
    } catch (e) {
      debugPrint('Error loading vault stats: $e');
    }
  }

  /// Get items by type
  List<VaultItemModel> getItemsByType(String type) {
    return _vaultItems.where((item) => item.itemType == type).toList();
  }

  /// Get favorite items
  List<VaultItemModel> get favoriteItems {
    return _vaultItems.where((item) => item.isFavorite).toList();
  }

  int get totalItems => _vaultItems.length;
  int get photoCount => _vaultItems.where((i) => i.isPhoto).length;
  int get videoCount => _vaultItems.where((i) => i.isVideo).length;
  int get fileCount => _vaultItems.where((i) => i.isFile).length;
}
