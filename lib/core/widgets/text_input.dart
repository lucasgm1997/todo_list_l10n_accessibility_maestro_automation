import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_spacing.dart';

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  const TextInput({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      onSubmitted: onSubmitted,
      autofocus: autofocus,
    );
  }
}
