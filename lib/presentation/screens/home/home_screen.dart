import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/debug_logger.dart';
import '../../providers/app_lock_provider.dart';
import '../../widgets/custom_button.dart';
import '../logs/logs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppLockProvider>().initialize();
      // Log that home screen is initialized with bottom navigation
      DebugLogger().log('Home screen initialized with bottom navigation (Home + Logs tabs)', level: LogLevel.info, tag: 'Home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? AppStrings.homeTitle : 'Logs'),
        actions: [
          if (_currentIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.greenAccent),
              tooltip: 'Debug Monitor',
              onPressed: () {
                Navigator.of(context).pushNamed('/debug-monitor');
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.routeSettings);
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear logs',
              onPressed: () {
                DebugLogger().clear();
              },
            ),
          ],
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(theme),
          const LogsScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index >= 0 && index < 2) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              activeIcon: Icon(Icons.description),
              label: 'Logs',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.routeAppSelection);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Apps'),
            )
          : null,
    );
  }

  Widget _buildHomeContent(ThemeData theme) {
    return Consumer<AppLockProvider>(
      builder: (context, appLockProvider, child) {
        if (appLockProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.lock,
                        label: AppStrings.homeTotalLocked,
                        value: appLockProvider.lockedAppsCount.toString(),
                      ),
                      _StatItem(
                        icon: Icons.security,
                        label: AppStrings.homeUnlockAttempts,
                        value: '0',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Locked Apps Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.homeLockedApps,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppConstants.routeAppSelection,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Locked Apps List
              if (appLockProvider.lockedApps.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_open,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.homeNoLockedApps,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: AppStrings.homeAddApps,
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              AppConstants.routeAppSelection,
                            );
                          },
                          icon: Icons.add,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...appLockProvider.lockedApps.map((app) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(app.appName[0].toUpperCase()),
                      ),
                      title: Text(app.appName),
                      subtitle: Text(app.packageName),
                      trailing: IconButton(
                        icon: const Icon(Icons.lock_open),
                        onPressed: () async {
                          await appLockProvider.unlockApp(app.packageName);
                        },
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 32, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
