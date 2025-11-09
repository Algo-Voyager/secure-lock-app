import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isConfirming = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handlePinEntry(String pin) async {
    if (!_isConfirming) {
      // First PIN entry
      if (pin.length >= AppConstants.minPinLength) {
        setState(() {
          _isConfirming = true;
          _errorMessage = null;
          _confirmPinController.clear();
        });
      }
    } else {
      // Confirm PIN entry
      if (pin != _pinController.text) {
        setState(() {
          _errorMessage = AppStrings.pinMismatch;
          _confirmPinController.clear();
        });
        return;
      }

      // Setup PIN
      setState(() => _isLoading = true);

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.setupPin(pin);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
      } else {
        setState(() {
          _errorMessage = AppStrings.errorGeneric;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.setupPinTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.pin_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _isConfirming
                    ? AppStrings.confirmPin
                    : AppStrings.createPin,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.setupPinDesc,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: PinInputField(
                    controller: _isConfirming ? _confirmPinController : _pinController,
                    length: AppConstants.maxPinLength,
                    onCompleted: _handlePinEntry,
                  ),
                ),
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
              const Spacer(),
              if (_isConfirming)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isConfirming = false;
                      _errorMessage = null;
                      _pinController.clear();
                      _confirmPinController.clear();
                    });
                  },
                  child: const Text(AppStrings.back),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
