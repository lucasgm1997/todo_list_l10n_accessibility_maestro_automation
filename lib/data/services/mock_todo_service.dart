import 'dart:math';
import 'package:maestro_test/data/models/dto/todo_response.dart';
import 'package:maestro_test/data/services/todo_service.dart';

/// Mock service that generates dynamic todo items for Maestro testing
///
/// This service creates a random number of items with configurable parameters
/// to test UI robustness with varying data counts.
class MockTodoService extends TodoService {
  final List<TodoResponse> _todos = [];
  final Random _random;
  final int minItems;
  final int maxItems;
  final String titlePattern;
  final bool withStableIds;

  /// Creates a mock service with configurable parameters
  ///
  /// - [minItems]: Minimum number of items to generate (default: 0)
  /// - [maxItems]: Maximum number of items to generate (default: 10)
  /// - [seed]: Optional seed for deterministic random generation
  /// - [titlePattern]: Pattern for title with {i} placeholder (default: "Task {i}")
  /// - [withStableIds]: Generate stable IDs for testing (default: true)
  MockTodoService({
    this.minItems = 0,
    this.maxItems = 10,
    int? seed,
    this.titlePattern = 'Task {i}',
    this.withStableIds = true,
  }) : _random = Random(seed) {
    _generateInitialItems();
  }

  void _generateInitialItems() {
    final count = minItems + _random.nextInt(maxItems - minItems + 1);

    for (int i = 0; i < count; i++) {
      final id = _generateId(i);
      final title = titlePattern.replaceAll('{i}', i.toString());
      final completed = _random.nextBool();

      _todos.add(TodoResponse(
        id: id,
        title: title,
        completed: completed,
        createdAt: DateTime.now().subtract(Duration(hours: count - i)).toIso8601String(),
      ));
    }
  }

  String _generateId(int index) {
    // Always use simple numeric IDs for Maestro compatibility
    return index.toString();
  }

  @override
  Future<List<TodoResponse>> getTodos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_todos);
  }

  @override
  Future<TodoResponse> createTodo(String title) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _todos.length;
    final id = _generateId(index);

    final todo = TodoResponse(
      id: id,
      title: title,
      completed: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    _todos.add(todo);
    return todo;
  }

  @override
  Future<TodoResponse> updateTodo(String id, {String? title, bool? completed}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw Exception('Todo not found');
    }

    final updatedTodo = TodoResponse(
      id: _todos[index].id,
      title: title ?? _todos[index].title,
      completed: completed ?? _todos[index].completed,
      createdAt: _todos[index].createdAt,
    );

    _todos[index] = updatedTodo;
    return updatedTodo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw Exception('Todo not found');
    }

    _todos.removeAt(index);
  }

  /// Get the current count of todos
  int get count => _todos.length;

  /// Clear all todos
  void clear() {
    _todos.clear();
  }
}
