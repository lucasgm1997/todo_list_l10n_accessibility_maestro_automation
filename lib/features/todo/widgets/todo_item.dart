import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_spacing.dart';
import 'package:maestro_test/data/models/domain/todo.dart';
import 'package:maestro_test/features/todo/widgets/components/todo_checkbox.dart';
import 'package:maestro_test/features/todo/widgets/components/todo_subtitle.dart';
import 'package:maestro_test/features/todo/widgets/components/todo_title.dart';
import 'package:maestro_test/features/todo/widgets/components/todo_trailing.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.index,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    var identifier = 'elevated_button_toggle';
    return Column(
      children: [
        Semantics(
          identifier: identifier,
          container: true,
          child: ExcludeSemantics(
            child: ElevatedButton(
              onPressed: () {
                onToggle();
              },
              child: const Text('Toggle'),
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            leading: TodoCheckbox(
              completed: todo.completed,
              isPending: todo.isPending,
              onToggle: onToggle,
            ),
            title: TodoTitle(
              title: todo.title,
              completed: todo.completed,
              isPending: todo.isPending,
              // index: index,
            ),
            subtitle: TodoSubtitle(createdAt: todo.createdAt),
            trailing: TodoTrailing(
              isPending: todo.isPending,
              onEdit: onEdit,
              onDelete: onDelete,
              index: index,
            ),
          ),
        ),
      ],
    );
  }
}
