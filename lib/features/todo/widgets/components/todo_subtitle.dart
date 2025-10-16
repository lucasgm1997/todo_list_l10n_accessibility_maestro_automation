import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_typography.dart';

class TodoSubtitle extends StatelessWidget {
  final DateTime createdAt;

  const TodoSubtitle({
    super.key,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDate(createdAt),
      style: AppTypography.caption,
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
