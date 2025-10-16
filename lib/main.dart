import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_theme.dart';
import 'package:maestro_test/di/service_locator.dart';
import 'package:maestro_test/features/todo/views/todo_view.dart';

void main() {
  setupDI();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const TodoView(),
    );
  }
}
