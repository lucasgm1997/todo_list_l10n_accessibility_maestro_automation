import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';
import 'package:maestro_test/l10n/app_localizations.dart';

class TodoDeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const TodoDeleteButton({
    super.key,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      identifier: AppSemantics.todoItemDeleteButton,
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
