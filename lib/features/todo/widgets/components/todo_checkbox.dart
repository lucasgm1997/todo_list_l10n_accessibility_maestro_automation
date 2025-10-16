import 'package:flutter/material.dart';

class TodoCheckbox extends StatelessWidget {
  final bool completed;
  final bool isPending;
  final VoidCallback onToggle;

  const TodoCheckbox({
    super.key,
    required this.completed,
    required this.isPending,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: completed,
      onChanged: isPending ? null : (_) => onToggle(),
    );
  }
}
