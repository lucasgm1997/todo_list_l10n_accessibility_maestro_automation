import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';
import 'package:maestro_test/l10n/app_localizations.dart';

class TodoDeleteButton extends StatelessWidget {
  final VoidCallback onDelete;
  final int? index;

  const TodoDeleteButton({
    super.key,
    required this.onDelete,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final semanticId = index != null
        ? '${AppSemantics.todoItemDeleteButton}_$index'
        : AppSemantics.todoItemDeleteButton;

    return Semantics(
      identifier: semanticId,
      label: l10n.todo_item_delete_button,
      button: true,
      child: IconButton(
        icon: const Icon(Icons.delete, size: 20),
        onPressed: onDelete,
        color: AppColors.error,
        tooltip: l10n.todo_item_delete_button,
      ),
    );
  }
}
