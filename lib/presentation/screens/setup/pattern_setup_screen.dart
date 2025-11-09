import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pattern_lock_widget.dart';
import '../../../core/constants/app_constants.dart';

class PatternSetupScreen extends StatefulWidget {
  const PatternSetupScreen({super.key});

  @override
  State<PatternSetupScreen> createState() => _PatternSetupScreenState();
}

class _PatternSetupScreenState extends State<PatternSetupScreen> {
  String? _firstPattern;
  String _message = 'Draw your unlock pattern';
  bool _isConfirming = false;
  bool _hasError = false;

  void _handlePatternComplete(List<int> pattern) {
    if (pattern.length < 4) {
      setState(() {
        _message = 'Connect at least 4 dots!';
        _hasError = true;
      });
      _resetAfterDelay();
      return;
    }

    final patternString = PatternHelper.patternToString(pattern);

    if (!_isConfirming) {
      // First pattern entry
      setState(() {
        _firstPattern = patternString;
        _message = 'Draw pattern again to confirm';
        _isConfirming = true;
        _hasError = false;
      });
    } else {
      // Confirmation pattern entry
      if (patternString == _firstPattern) {
        // Patterns match - save pattern
        _savePattern(patternString);
      } else {
        // Patterns don't match
        setState(() {
          _message = 'Patterns don\'t match! Try again';
          _firstPattern = null;
          _isConfirming = false;
          _hasError = true;
        });
        _resetAfterDelay();
      }
    }
  }

  void _resetAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (!_isConfirming) {
            _message = 'Draw your unlock pattern';
          } else {
            _message = 'Draw pattern again to confirm';
          }
          _hasError = false;
        });
      }
    });
  }

  Future<void> _savePattern(String pattern) async {
    final authProvider = context.read<AuthProvider>();

    setState(() {
      _message = 'Saving pattern...';
    });

    try {
      await authProvider.setupPattern(pattern);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pattern lock enabled successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home or next screen
        Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = 'Error saving pattern. Try again.';
          _hasError = true;
          _firstPattern = null;
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Pattern Lock'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Instructions
              Text(
                _message,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: _hasError ? Colors.red : theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                'Connect at least 4 dots',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // Pattern Lock Widget
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: PatternLockWidget(
                        onPatternComplete: _handlePatternComplete,
                        dotColor: Colors.grey.shade400,
                        selectedDotColor: theme.primaryColor,
                        lineColor: theme.primaryColor,
                        dotSize: 25,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressDot(isActive: true),
                  const SizedBox(width: 8),
                  _buildProgressDot(isActive: _isConfirming),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot({required bool isActive}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
      ),
    );
  }
}
