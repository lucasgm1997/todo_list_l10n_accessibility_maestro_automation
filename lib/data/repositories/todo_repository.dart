import 'package:dartz/dartz.dart';
import 'package:maestro_test/core/failures/failure.dart';
import 'package:maestro_test/data/models/domain/todo.dart';
import 'package:maestro_test/data/services/todo_service.dart';

class TodoRepository {
  final TodoService _service;

  TodoRepository(this._service);

  Future<Either<Failure, List<Todo>>> getTodos() async {
    try {
      final response = await _service.getTodos();

      final todos = response.map((dto) {
        return Todo(
          id: dto.id,
          title: dto.title,
          completed: dto.completed,
          createdAt: DateTime.parse(dto.createdAt),
        );
      }).toList();

      return right(todos);
    } catch (e) {
      return left(ServerFailure('Failed to load todos: $e'));
    }
  }

  Future<Either<Failure, Todo>> createTodo(String title) async {
    try {
      if (title.trim().isEmpty) {
        return left(const ValidationFailure('Title cannot be empty'));
      }

      final response = await _service.createTodo(title);

      final todo = Todo(
        id: response.id,
        title: response.title,
        completed: response.completed,
        createdAt: DateTime.parse(response.createdAt),
      );

      return right(todo);
    } catch (e) {
      return left(ServerFailure('Failed to create todo: $e'));
    }
  }

  Future<Either<Failure, Todo>> updateTodo(Todo todo) async {
    try {
      final response = await _service.updateTodo(
        todo.id,
        title: todo.title,
        completed: todo.completed,
      );

      final updatedTodo = Todo(
        id: response.id,
        title: response.title,
        completed: response.completed,
        createdAt: DateTime.parse(response.createdAt),
      );

      return right(updatedTodo);
    } catch (e) {
      return left(ServerFailure('Failed to update todo: $e'));
    }
  }

  Future<Either<Failure, void>> deleteTodo(String id) async {
    try {
      await _service.deleteTodo(id);
      return right(null);
    } catch (e) {
      return left(ServerFailure('Failed to delete todo: $e'));
    }
  }
}
