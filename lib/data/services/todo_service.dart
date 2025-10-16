import 'package:maestro_test/data/models/dto/todo_response.dart';

class TodoService {
  final List<TodoResponse> _todos = [];
  int _idCounter = 1;

  Future<List<TodoResponse>> getTodos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_todos);
  }

  Future<TodoResponse> createTodo(String title) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final todo = TodoResponse(
      id: _idCounter.toString(),
      title: title,
      completed: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    _idCounter++;
    _todos.add(todo);
    return todo;
  }

  Future<TodoResponse> updateTodo(String id, {String? title, bool? completed}) async {
    await Future.delayed(const Duration(milliseconds: 600));

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

  Future<void> deleteTodo(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw Exception('Todo not found');
    }

    _todos.removeAt(index);
  }
}
