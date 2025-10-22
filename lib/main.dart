import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_theme.dart';
import 'package:maestro_test/di/service_locator.dart';
import 'package:maestro_test/features/todo/views/list_page.dart';
import 'package:maestro_test/features/todo/views/todo_view.dart';
import 'package:maestro_test/l10n/app_localizations.dart';

void main() {
  setupDI();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('pt'); // Default: Português

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,

      // Internationalization configuration
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale, // Current selected locale
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // home: ListPageBuilder(),
      home: TodoView(currentLocale: _locale, onLocaleChanged: _changeLocale),
    );
  }
}
