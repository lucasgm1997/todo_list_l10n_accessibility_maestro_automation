import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';
import 'package:maestro_test/core/design_system/app_typography.dart';

class TodoTitle extends StatelessWidget {
  final String title;
  final bool completed;
  final bool isPending;

  const TodoTitle({
    super.key,
    required this.title,
    required this.completed,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.bodyLarge.copyWith(
        decoration: completed ? TextDecoration.lineThrough : null,
        color: isPending || completed
            ? AppColors.textSecondary
            : AppColors.textPrimary,
      ),
    );
  }
}
