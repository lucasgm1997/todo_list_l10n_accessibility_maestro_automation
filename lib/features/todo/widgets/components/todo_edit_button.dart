import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';
import 'package:maestro_test/l10n/app_localizations.dart';

class TodoEditButton extends StatelessWidget {
  final VoidCallback onEdit;
  final int? index;

  const TodoEditButton({
    super.key,
    required this.onEdit,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final semanticId = index != null
        ? '${AppSemantics.todoItemEditButton}_$index'
        : AppSemantics.todoItemEditButton;

    return Semantics(
      identifier: semanticId,
      label: l10n.todo_item_edit_button,
      button: true,
      child: IconButton(
        icon: const Icon(Icons.edit, size: 20),
        onPressed: onEdit,
        color: AppColors.primary,
        tooltip: l10n.todo_item_edit_button,
      ),
    );
  }
}
