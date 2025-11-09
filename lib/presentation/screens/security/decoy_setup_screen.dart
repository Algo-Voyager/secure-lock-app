import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/decoy_service.dart';
import '../../../core/services/encryption_service.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class DecoySetupScreen extends StatefulWidget {
  const DecoySetupScreen({super.key});

  @override
  State<DecoySetupScreen> createState() => _DecoySetupScreenState();
}

class _DecoySetupScreenState extends State<DecoySetupScreen> {
  final DecoyService _decoyService = DecoyService();
  final EncryptionService _encryptionService = EncryptionService();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String _selectedMethod = 'pin';
  bool _isDecoyEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecoyStatus();
    _encryptionService.initialize();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadDecoyStatus() async {
    final isEnabled = await _decoyService.isDecoyEnabled();
    setState(() {
      _isDecoyEnabled = isEnabled;
      _isLoading = false;
    });
  }

  Future<void> _setupDecoy() async {
    final input = _selectedMethod == 'pin' ? _pinController.text : _passwordController.text;
    final confirm = _confirmController.text;

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a decoy ${_selectedMethod}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (input != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inputs do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMethod == 'pin') {
      if (input.length < AppConstants.minPinLength || input.length > AppConstants.maxPinLength) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PIN must be ${AppConstants.minPinLength}-${AppConstants.maxPinLength} digits'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_selectedMethod == 'password') {
      if (input.length < AppConstants.minPasswordLength) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password must be at least ${AppConstants.minPasswordLength} characters'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      final hash = _encryptionService.hashPassword(input);

      if (_selectedMethod == 'pin') {
        await _decoyService.setDecoyPin(hash);
      } else {
        await _decoyService.setDecoyPassword(hash);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Decoy mode setup successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() => _isDecoyEnabled = true);
        _pinController.clear();
        _passwordController.clear();
        _confirmController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disableDecoy() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Decoy Mode'),
        content: const Text(
          'This will remove your decoy credentials. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _decoyService.disableDecoyMode();
        setState(() => _isDecoyEnabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Decoy mode disabled'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decoy Mode'),
        actions: [
          if (_isDecoyEnabled)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _disableDecoy,
              tooltip: 'Disable Decoy Mode',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        const Text(
                          'What is Decoy Mode?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Decoy mode creates a fake "alternate" version of your app. '
                      'When unlocked with the decoy PIN/password, the app shows '
                      'empty vault, no locked apps, and fake settings. This protects '
                      'your real data if someone forces you to unlock the app.',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_isDecoyEnabled) ...[
              // Status card when enabled
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Decoy mode is active',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Setup form when disabled
              const Text(
                'Setup Decoy Credentials',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Method selection
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'pin', label: Text('PIN')),
                  ButtonSegment(value: 'password', label: Text('Password')),
                ],
                selected: {_selectedMethod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _selectedMethod = newSelection.first);
                  _pinController.clear();
                  _passwordController.clear();
                  _confirmController.clear();
                },
              ),

              const SizedBox(height: 24),

              // Input fields
              if (_selectedMethod == 'pin') ...[
                TextField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: 'Decoy PIN',
                    hintText: 'Enter ${AppConstants.minPinLength}-${AppConstants.maxPinLength} digits',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: AppConstants.maxPinLength,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Decoy PIN',
                    hintText: 'Re-enter PIN',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: AppConstants.maxPinLength,
                ),
              ] else ...[
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Decoy Password',
                    hintText: 'Enter password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Decoy Password',
                    hintText: 'Re-enter password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
              ],

              const SizedBox(height: 24),

              // Setup button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _setupDecoy,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Setup Decoy Mode'),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Warning card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        const Text(
                          'Important',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Your real data will be hidden when using decoy credentials\n'
                      '• Make sure your decoy credentials are different from real ones\n'
                      '• Decoy mode shows empty apps and vault\n'
                      '• To access real data, use your normal credentials',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
