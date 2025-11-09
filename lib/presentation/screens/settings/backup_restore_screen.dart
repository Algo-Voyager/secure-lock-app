import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/backup/backup_service.dart';
import '../../../core/utils/logger.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final BackupService _backupService = BackupService();
  List<File> _backupFiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    try {
      final backups = await _backupService.getAvailableBackups();
      setState(() {
        _backupFiles = backups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      logger.e('Error loading backups', error: e);
    }
  }

  Future<void> _createBackup({bool includeVault = false}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Creating backup...'),
          ],
        ),
      ),
    );

    try {
      final filePath = await _backupService.createBackup(includeVault: includeVault);

      if (mounted) {
        Navigator.pop(context); // Close progress dialog

        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup created successfully!\n$filePath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          await _loadBackups();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create backup'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup(String filePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace your current settings and locked apps. '
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Restoring backup...'),
          ],
        ),
      ),
    );

    try {
      final success = await _backupService.restoreBackup(filePath);

      if (mounted) {
        Navigator.pop(context); // Close progress dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Backup restored successfully!' : 'Failed to restore backup'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          // Reload app state
          await Future.delayed(const Duration(seconds: 1));
          // Optionally restart the app or reload providers
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareBackup(String filePath) async {
    try {
      await _backupService.shareBackup(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing backup: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteBackup(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text('Delete ${file.path.split('/').last}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await file.delete();
        await _loadBackups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting backup: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Create backup section
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create New Backup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _createBackup(includeVault: false),
                                icon: const Icon(Icons.backup),
                                label: const Text('Settings Only'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _createBackup(includeVault: true),
                                icon: const Icon(Icons.backup),
                                label: const Text('Full Backup'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Full backup includes vault metadata (not actual encrypted files)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Available backups section
                Expanded(
                  child: _backupFiles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_off,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No backups found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _backupFiles.length,
                          itemBuilder: (context, index) {
                            final file = _backupFiles[index];
                            final fileName = file.path.split('/').last;
                            final fileStat = file.statSync();
                            final fileSize = (fileStat.size / 1024).toStringAsFixed(2);
                            final fileDate = fileStat.modified;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(Icons.file_present, color: Colors.blue),
                                ),
                                title: Text(
                                  fileName,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${DateFormat('MMM dd, yyyy HH:mm').format(fileDate)} • $fileSize KB',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'restore',
                                      child: Row(
                                        children: [
                                          Icon(Icons.restore, size: 20),
                                          SizedBox(width: 8),
                                          Text('Restore'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'share',
                                      child: Row(
                                        children: [
                                          Icon(Icons.share, size: 20),
                                          SizedBox(width: 8),
                                          Text('Share'),
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
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'restore':
                                        _restoreBackup(file.path);
                                        break;
                                      case 'share':
                                        _shareBackup(file.path);
                                        break;
                                      case 'delete':
                                        _deleteBackup(file);
                                        break;
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
