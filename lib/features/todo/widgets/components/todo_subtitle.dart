import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_typography.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';
import 'package:maestro_test/l10n/app_localizations.dart';

class TodoSubtitle extends StatelessWidget {
  final DateTime createdAt;

  const TodoSubtitle({
    super.key,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedDate = _formatDate(createdAt);

    return Semantics(
      identifier: AppSemantics.todoItemSubtitle,
      label: l10n.todo_item_subtitle(formattedDate),
      value: formattedDate,
      child: Text(
        formattedDate,
        style: AppTypography.caption,
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
