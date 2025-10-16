import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';

class TodoDeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const TodoDeleteButton({
    super.key,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, size: 20),
      onPressed: onDelete,
      color: AppColors.error,
      tooltip: 'Excluir',
    );
  }
}
