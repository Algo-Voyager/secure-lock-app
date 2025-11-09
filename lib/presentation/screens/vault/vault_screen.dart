import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/vault_provider.dart';
import '../../../data/models/vault_item_model.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaultProvider>().loadVaultItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Vault'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.photo), text: 'Photos'),
            Tab(icon: Icon(Icons.video_library), text: 'Videos'),
            Tab(icon: Icon(Icons.folder), text: 'Files'),
          ],
        ),
      ),
      body: Consumer<VaultProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPhotoVault(provider),
              _buildVideoVault(provider),
              _buildFileVault(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPhotoVault(VaultProvider provider) {
    final photos = provider.getItemsByType('photo');

    if (photos.isEmpty) {
      return _buildEmptyState(
        'No Photos in Vault',
        'Add photos to keep them secure and hidden',
        Icons.photo_library,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _buildPhotoTile(photos[index], provider);
      },
    );
  }

  Widget _buildPhotoTile(VaultItemModel item, VaultProvider provider) {
    return GestureDetector(
      onTap: () => _viewItem(item, provider),
      onLongPress: () => _showItemOptions(item, provider),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // TODO: Show decrypted thumbnail
          Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.photo, size: 40, color: Colors.grey),
          ),
          if (item.isFavorite)
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoVault(VaultProvider provider) {
    final videos = provider.getItemsByType('video');

    if (videos.isEmpty) {
      return _buildEmptyState(
        'No Videos in Vault',
        'Add videos to keep them secure and hidden',
        Icons.video_library,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 16 / 9,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return _buildVideoTile(videos[index], provider);
      },
    );
  }

  Widget _buildVideoTile(VaultItemModel item, VaultProvider provider) {
    return GestureDetector(
      onTap: () => _viewItem(item, provider),
      onLongPress: () => _showItemOptions(item, provider),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_circle_outline, size: 50, color: Colors.grey),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.displayName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (item.isFavorite)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileVault(VaultProvider provider) {
    final files = provider.getItemsByType('file');

    if (files.isEmpty) {
      return _buildEmptyState(
        'No Files in Vault',
        'Add documents to keep them secure',
        Icons.folder,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        return _buildFileTile(files[index], provider);
      },
    );
  }

  Widget _buildFileTile(VaultItemModel item, VaultProvider provider) {
    final sizeInMB = (item.fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            _getFileIcon(item.mimeType),
            color: Colors.blue,
          ),
        ),
        title: Text(item.displayName),
        subtitle: Text('$sizeInMB MB'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isFavorite)
              const Icon(Icons.favorite, color: Colors.red, size: 20),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 8),
                      Text('View'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'favorite',
                  child: Row(
                    children: [
                      Icon(Icons.favorite, size: 20),
                      SizedBox(width: 8),
                      Text('Favorite'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_upload, size: 20),
                      SizedBox(width: 8),
                      Text('Export'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleFileAction(value.toString(), item, provider),
            ),
          ],
        ),
        onTap: () => _viewItem(item, provider),
      ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description;
    }
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return Icons.table_chart;
    }
    return Icons.insert_drive_file;
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose Video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Add File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final photo = await _imagePicker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      _addToVault(photo.path, 'photo');
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _addToVault(image.path, 'photo');
    }
  }

  Future<void> _recordVideo() async {
    final video = await _imagePicker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      _addToVault(video.path, 'video');
    }
  }

  Future<void> _pickVideo() async {
    final video = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _addToVault(video.path, 'video');
    }
  }

  void _pickFile() {
    // TODO: Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File picker coming soon')),
    );
  }

  Future<void> _addToVault(String filePath, String itemType) async {
    final provider = context.read<VaultProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Adding to vault...'),
          ],
        ),
      ),
    );

    final item = await provider.addToVault(
      filePath: filePath,
      itemType: itemType,
    );

    if (mounted) {
      Navigator.pop(context); // Close progress dialog

      if (item != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to vault successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add to vault'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewItem(VaultItemModel item, VaultProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View functionality coming soon')),
    );
  }

  void _showItemOptions(VaultItemModel item, VaultProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              title: Text(item.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                provider.toggleFavorite(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Export'),
              onTap: () {
                Navigator.pop(context);
                _exportItem(item, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteItem(item, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleFileAction(String action, VaultItemModel item, VaultProvider provider) {
    switch (action) {
      case 'view':
        _viewItem(item, provider);
        break;
      case 'favorite':
        provider.toggleFavorite(item);
        break;
      case 'export':
        _exportItem(item, provider);
        break;
      case 'delete':
        _deleteItem(item, provider);
        break;
    }
  }

  void _exportItem(VaultItemModel item, VaultProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _deleteItem(VaultItemModel item, VaultProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete from Vault'),
        content: Text('Delete "${item.displayName}" from vault?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteItem(item);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Deleted successfully' : 'Failed to delete'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
