import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_spacing.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';
import 'package:maestro_test/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      identifier: AppSemantics.todoAddInput,
      label: labelText ?? l10n.todo_add_field,
      textField: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText ?? l10n.todo_add_input,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        onSubmitted: onSubmitted,
        autofocus: autofocus,
      ),
    );
  }
}
