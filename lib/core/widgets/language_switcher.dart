import 'package:flutter/material.dart';

/// Widget para alternar entre idiomas suportados
class LanguageSwitcher extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const LanguageSwitcher({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: 'Mudar idioma / Change language',
      onSelected: onLocaleChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('pt'),
          child: Row(
            children: [
              Text(
                '🇧🇷',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              const Text('Português'),
              if (currentLocale.languageCode == 'pt') ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, size: 20),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              Text(
                '🇺🇸',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              const Text('English'),
              if (currentLocale.languageCode == 'en') ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, size: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
