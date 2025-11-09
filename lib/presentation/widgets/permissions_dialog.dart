import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/permissions_provider.dart';

/// Dialog to guide users through enabling required permissions
class PermissionsDialog extends StatefulWidget {
  const PermissionsDialog({super.key});

  @override
  State<PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<PermissionsDialog> {
  @override
  void initState() {
    super.initState();
    // Check permissions on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionsProvider>().checkAllPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionsProvider>(
      builder: (context, permissionsProvider, child) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.security,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Required Permissions'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'To lock apps effectively, we need the following permissions:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Accessibility Service
                _PermissionItem(
                  icon: Icons.accessibility_new,
                  title: 'Accessibility Service',
                  description:
                      'Required to detect when you open locked apps',
                  isGranted: permissionsProvider.isAccessibilityServiceEnabled,
                  onTap: () async {
                    await permissionsProvider.openAccessibilitySettings();
                    // Wait a bit for user to potentially grant permission
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) {
                      await permissionsProvider.checkAllPermissions();
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Usage Stats Permission
                _PermissionItem(
                  icon: Icons.bar_chart,
                  title: 'Usage Access',
                  description:
                      'Required to monitor which app is currently active',
                  isGranted: permissionsProvider.hasUsageStatsPermission,
                  onTap: () async {
                    await permissionsProvider.requestUsageStatsPermission();
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) {
                      await permissionsProvider.checkAllPermissions();
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Overlay Permission
                _PermissionItem(
                  icon: Icons.layers,
                  title: 'Display Over Other Apps',
                  description: 'Required to show the lock screen overlay',
                  isGranted: permissionsProvider.hasOverlayPermission,
                  onTap: () async {
                    await permissionsProvider.requestOverlayPermission();
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) {
                      await permissionsProvider.checkAllPermissions();
                    }
                  },
                ),

                if (permissionsProvider.hasAllPermissions) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'All permissions granted!',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: permissionsProvider.hasAllPermissions
                  ? () {
                      Navigator.of(context).pop(true);
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isGranted ? Colors.green.shade200 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isGranted ? Colors.green.shade50 : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isGranted ? Colors.green.shade700 : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isGranted ? Colors.green.shade900 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isGranted)
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20)
            else
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }
}
