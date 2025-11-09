import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/strings.dart';
import '../../providers/app_lock_provider.dart';
import '../../providers/permissions_provider.dart';
import '../../widgets/permissions_dialog.dart';

class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.selectAppsTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.searchApps,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: Consumer<AppLockProvider>(
              builder: (context, appLockProvider, child) {
                final filteredApps = appLockProvider.installedApps.where((app) {
                  return app.appName.toLowerCase().contains(_searchQuery) ||
                      app.packageName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredApps.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.noAppsFound,
                      style: theme.textTheme.titleMedium,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredApps.length,
                  itemBuilder: (context, index) {
                    final app = filteredApps[index];
                    final isLocked = appLockProvider.isAppLocked(app.packageName);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            app.appName[0].toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(app.appName),
                        subtitle: Text(app.packageName),
                        trailing: Switch(
                          value: isLocked,
                          onChanged: (value) async {
                            // If trying to lock an app, check permissions first
                            if (value) {
                              final permissionsProvider = context.read<PermissionsProvider>();
                              await permissionsProvider.checkAllPermissions();

                              // If not all permissions are granted, show dialog
                              if (!permissionsProvider.hasAllPermissions) {
                                if (context.mounted) {
                                  final granted = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const PermissionsDialog(),
                                  );

                                  if (granted != true) {
                                    return; // User cancelled, don't lock the app
                                  }
                                }
                              }
                            }

                            // Proceed with toggling the lock
                            await appLockProvider.toggleAppLock(
                              app.packageName,
                              app.appName,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
