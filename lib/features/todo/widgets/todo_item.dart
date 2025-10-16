import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';
import 'package:maestro_test/core/design_system/app_spacing.dart';
import 'package:maestro_test/core/design_system/app_typography.dart';
import 'package:maestro_test/data/models/domain/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Checkbox(
          value: todo.completed,
          onChanged: todo.isPending ? null : (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: AppTypography.bodyLarge.copyWith(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            color: todo.isPending
                ? AppColors.textSecondary
                : todo.completed
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          _formatDate(todo.createdAt),
          style: AppTypography.caption,
        ),
        trailing: todo.isPending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    color: AppColors.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                    color: AppColors.error,
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Agora';
        }
        return '${diff.inMinutes}m atrás';
      }
      return '${diff.inHours}h atrás';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
