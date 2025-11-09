import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: AppStrings.settingsSecurity),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                children: [
                  if (authProvider.biometricAvailable)
                    SwitchListTile(
                      title: const Text(AppStrings.settingsEnableBiometric),
                      subtitle: const Text('Use fingerprint or face unlock'),
                      value: authProvider.biometricEnabled,
                      onChanged: (value) async {
                        if (value) {
                          await authProvider.enableBiometric();
                        } else {
                          await authProvider.disableBiometric();
                        }
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.pin),
                    title: const Text(AppStrings.settingsChangePin),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement change PIN
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(),
          _SectionHeader(title: AppStrings.settingsTheme),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                children: [
                  RadioListTile<AppThemeMode>(
                    title: const Text(AppStrings.settingsLightMode),
                    value: AppThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) {
                      themeProvider.setThemeMode(value!);
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    title: const Text(AppStrings.settingsDarkMode),
                    value: AppThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) {
                      themeProvider.setThemeMode(value!);
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    title: const Text(AppStrings.settingsSystemMode),
                    value: AppThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) {
                      themeProvider.setThemeMode(value!);
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(),
          _SectionHeader(title: AppStrings.settingsAbout),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(AppStrings.settingsVersion),
            subtitle: const Text(AppConstants.appVersion),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
