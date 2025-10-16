import 'package:flutter/material.dart';
import 'package:maestro_test/features/todo/widgets/components/todo_delete_button.dart';
import 'package:maestro_test/features/todo/widgets/components/todo_edit_button.dart';
import 'package:maestro_test/features/todo/widgets/components/todo_loading_indicator.dart';

class TodoTrailing extends StatelessWidget {
  final bool isPending;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int? index;

  const TodoTrailing({
    super.key,
    required this.isPending,
    required this.onEdit,
    required this.onDelete,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    if (isPending) {
      return const TodoLoadingIndicator();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TodoEditButton(onEdit: onEdit, index: index),
        TodoDeleteButton(onDelete: onDelete, index: index),
      ],
    );
  }
}
