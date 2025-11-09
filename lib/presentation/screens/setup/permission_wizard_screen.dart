import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/permissions_provider.dart';
import '../../widgets/custom_button.dart';

class PermissionWizardScreen extends StatefulWidget {
  const PermissionWizardScreen({super.key});

  @override
  State<PermissionWizardScreen> createState() => _PermissionWizardScreenState();
}

class _PermissionWizardScreenState extends State<PermissionWizardScreen> with WidgetsBindingObserver {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permissions when user returns from settings
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);
    await context.read<PermissionsProvider>().checkAllPermissions();
    setState(() => _isChecking = false);

    // If all permissions granted, navigate to home
    if (mounted && context.read<PermissionsProvider>().hasAllPermissions) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Required Permissions'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<PermissionsProvider>(
        builder: (context, permissionsProvider, child) {
          if (_isChecking) {
            return const Center(child: CircularProgressIndicator());
          }

          final allGranted = permissionsProvider.hasAllPermissions;
          final progress = _getProgress(permissionsProvider);

          return Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                minHeight: 6,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introduction
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.security, color: Colors.blue.shade700, size: 28),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Setup Required Permissions',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'To lock apps effectively, Secure Lock needs special permissions. '
                                'Please grant all three permissions below to enable app locking.',
                                style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Permission Steps
                      _buildPermissionCard(
                        context,
                        title: 'Usage Stats Access',
                        description: 'Required to detect which app is currently running',
                        icon: Icons.bar_chart,
                        isGranted: permissionsProvider.hasUsageStatsPermission,
                        onTap: () async {
                          await permissionsProvider.requestUsageStatsPermission();
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildPermissionCard(
                        context,
                        title: 'Display Over Other Apps',
                        description: 'Required to show lock screen overlay on locked apps',
                        icon: Icons.layers,
                        isGranted: permissionsProvider.hasOverlayPermission,
                        onTap: () async {
                          await permissionsProvider.requestOverlayPermission();
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildPermissionCard(
                        context,
                        title: 'Accessibility Service',
                        description: 'Required to detect when you open locked apps',
                        icon: Icons.accessibility_new,
                        isGranted: permissionsProvider.isAccessibilityServiceEnabled,
                        onTap: () async {
                          await permissionsProvider.openAccessibilitySettings();
                        },
                      ),

                      if (allGranted) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade400, Colors.green.shade600],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 48),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'All Set!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'All permissions granted. App locking is now active!',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!allGranted) ...[
                      CustomButton(
                        text: 'Refresh Status',
                        onPressed: _checkPermissions,
                        icon: Icons.refresh,
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
                        },
                        child: const Text('Skip (app locking won\'t work)'),
                      ),
                    ] else ...[
                      CustomButton(
                        text: 'Continue to App',
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
                        },
                        icon: Icons.arrow_forward,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isGranted ? Colors.green.shade300 : Colors.grey.shade300,
          width: isGranted ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isGranted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isGranted
                      ? Colors.green.shade100
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isGranted ? Colors.green.shade700 : theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isGranted)
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (!isGranted) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.settings, size: 18),
                        label: const Text('Grant Permission'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getProgress(PermissionsProvider provider) {
    int granted = 0;
    if (provider.hasUsageStatsPermission) granted++;
    if (provider.hasOverlayPermission) granted++;
    if (provider.isAccessibilityServiceEnabled) granted++;
    return granted / 3;
  }
}
