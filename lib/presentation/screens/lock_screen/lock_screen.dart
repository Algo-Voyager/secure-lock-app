import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/native_service.dart';
import '../../../core/utils/debug_logger.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final NativeService _nativeService = NativeService();
  String? _errorMessage;
  bool _isLoading = false;
  String? _lockedPackageName;

  @override
  void initState() {
    super.initState();
    // Get package name from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _lockedPackageName = args['packageName'] as String?;
        if (_lockedPackageName != null) {
          DebugLogger().log('Lock screen opened for: $_lockedPackageName', tag: 'LockScreen');
        }
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLockedOut) {
      setState(() {
        _errorMessage = '${AppStrings.tooManyAttempts}. ${AppStrings.tryAgainIn} ${AppStrings.minutes}';
      });
      return;
    }

    setState(() => _isLoading = true);

    bool success = false;

    if (authProvider.authMethod == AuthMethod.pin) {
      success = await authProvider.verifyPin(_pinController.text);
    } else if (authProvider.authMethod == AuthMethod.password) {
      success = await authProvider.verifyPassword(_passwordController.text);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Apply native grace to avoid immediate re-lock and finish overlay activity
      await _nativeService.onUnlockSuccess(packageName: _lockedPackageName);
      // Do not re-launch the app from Flutter; native brings it to front.
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = authProvider.authMethod == AuthMethod.pin
            ? AppStrings.incorrectPin
            : AppStrings.incorrectPassword;
        _pinController.clear();
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.lockScreenTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.lockScreenDesc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                        if (authProvider.authMethod == AuthMethod.pin)
                          PinInputField(
                            controller: _pinController,
                            length: AppConstants.maxPinLength,
                            onCompleted: (_) => _authenticate(),
                          )
                        else
                          CustomTextField(
                            controller: _passwordController,
                            label: AppStrings.enterPassword,
                            obscureText: true,
                          ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                        if (!authProvider.isLockedOut) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${AppStrings.attemptsRemaining}: ${authProvider.remainingAttempts}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (authProvider.authMethod == AuthMethod.password)
                  CustomButton(
                    text: AppStrings.unlock,
                    onPressed: _authenticate,
                    isLoading: _isLoading,
                    backgroundColor: Colors.white,
                    textColor: theme.colorScheme.primary,
                  ),
                if (authProvider.biometricEnabled) ...[
                  const SizedBox(height: 16),
                  CustomButton(
                    text: AppStrings.useBiometric,
                    onPressed: () async {
                      final success = await authProvider.authenticateWithBiometric();
                      if (success && mounted) {
                        // Apply native grace and return to target app (native brings it to front)
                        await _nativeService.onUnlockSuccess(packageName: _lockedPackageName);
                        if (mounted) Navigator.of(context).pop(true);
                      }
                    },
                    icon: Icons.fingerprint,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    textColor: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
