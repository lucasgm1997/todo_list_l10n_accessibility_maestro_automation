import 'package:flutter/material.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';
import 'package:maestro_test/l10n/app_localizations.dart';

class TodoCheckbox extends StatelessWidget {
  final bool completed;
  final bool isPending;
  final VoidCallback onToggle;

  const TodoCheckbox({
    super.key,
    required this.completed,
    required this.isPending,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      identifier: AppSemantics.todoItemCheckbox,
      label: completed
          ? l10n.todo_item_checkbox_completed
          : l10n.todo_item_checkbox,
      checked: completed,
      enabled: !isPending,
      child: Checkbox(
        value: completed,
        onChanged: isPending ? null : (_) => onToggle(),
      ),
    );
  }
}
