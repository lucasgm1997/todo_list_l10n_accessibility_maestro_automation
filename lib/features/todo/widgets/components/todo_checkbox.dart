import 'package:flutter/material.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';
import 'package:maestro_test/l10n/app_localizations.dart';

class TodoCheckbox extends StatelessWidget {
  final bool completed;
  final bool isPending;
  final VoidCallback onToggle;
  final int? index;

  const TodoCheckbox({
    super.key,
    required this.completed,
    required this.isPending,
    required this.onToggle,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final semanticId = index != null
        ? '${AppSemantics.todoItemCheckbox}_$index'
        : AppSemantics.todoItemCheckbox;

    return Semantics(
      identifier: semanticId,
      label: completed
          ? l10n.todo_item_checkbox_completed
          : l10n.todo_item_checkbox,
      checked: completed,
      enabled: !isPending,
      child: ExcludeSemantics(
        child: Checkbox(
          value: completed,
          onChanged: isPending ? null : (_) => onToggle(),
        ),
      ),
    );
  }
}
