import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';

class TodoEditButton extends StatelessWidget {
  final VoidCallback onEdit;

  const TodoEditButton({
    super.key,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, size: 20),
      onPressed: onEdit,
      color: AppColors.primary,
      tooltip: 'Editar',
    );
  }
}
