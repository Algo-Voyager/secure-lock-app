import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom text field widget
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

/// Custom PIN input field
class PinInputField extends StatelessWidget {
  final TextEditingController controller;
  final int length;
  final void Function(String)? onChanged;
  final void Function(String)? onCompleted;

  const PinInputField({
    super.key,
    required this.controller,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 16,
      ),
      maxLength: length,
      obscureText: true,
      obscuringCharacter: '●',
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: const InputDecoration(
        counterText: '',
        border: InputBorder.none,
        hintText: '••••',
        hintStyle: TextStyle(
          fontSize: 32,
          letterSpacing: 16,
        ),
      ),
      onChanged: (value) {
        onChanged?.call(value);
        if (value.length == length) {
          onCompleted?.call(value);
        }
      },
    );
  }
}
