import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:maestro_test/core/commands/command.dart';
import 'package:maestro_test/core/failures/failure.dart';
import 'package:maestro_test/data/models/domain/todo.dart';
import 'package:maestro_test/data/repositories/todo_repository.dart';

class TodoViewModel extends ChangeNotifier {
  final TodoRepository _repository;

  TodoViewModel(this._repository);

  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  // Commands
  late final Command0<List<Todo>> loadCommand = Command0(_load);
  late final Command1<Todo, String> addCommand = Command1(_add);
  late final Command1<void, String> toggleCommand = Command1(_toggle);
  late final Command1<void, String> deleteCommand = Command1(_delete);
  late final Command2<Todo, String, String> editCommand = Command2(_edit);

  // Load todos
  Future<Either<Failure, List<Todo>>> _load() async {
    final result = await _repository.getTodos();
    result.fold(
      (_) => null,
      (todos) => _todos = todos,
    );
    notifyListeners();
    return result;
  }

  // Add todo with Optimistic State
  Future<Either<Failure, Todo>> _add(String title) async {
    final tempTodo = Todo(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      completed: false,
      isPending: true,
      createdAt: DateTime.now(),
    );

    // Optimistic add
    _todos.insert(0, tempTodo);
    notifyListeners();

    try {
      final result = await _repository.createTodo(title);

      return result.fold(
        (failure) {
          // Rollback - remove temp
          _todos.removeWhere((t) => t.id == tempTodo.id);
          notifyListeners();
          return left(failure);
        },
        (createdTodo) {
          // Replace temp with real
          final index = _todos.indexWhere((t) => t.id == tempTodo.id);
          if (index != -1) {
            _todos[index] = createdTodo;
            notifyListeners();
          }
          return right(createdTodo);
        },
      );
    } catch (e) {
      // Rollback on error
      _todos.removeWhere((t) => t.id == tempTodo.id);
      notifyListeners();
      return left(ServerFailure('Failed to add todo: $e'));
    }
  }

  // Toggle todo with Optimistic State
  Future<Either<Failure, void>> _toggle(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) {
      return left(const NotFoundFailure('Todo not found'));
    }

    final previousState = _todos[index];

    // Optimistic toggle
    _todos[index] = _todos[index].copyWith(
      completed: !_todos[index].completed,
      isPending: true,
    );
    notifyListeners();

    try {
      final result = await _repository.updateTodo(_todos[index].copyWith(isPending: false));

      return result.fold(
        (failure) {
          // Rollback
          _todos[index] = previousState;
          notifyListeners();
          return left(failure);
        },
        (updatedTodo) {
          // Update with real data
          _todos[index] = updatedTodo;
          notifyListeners();
          return right(null);
        },
      );
    } catch (e) {
      // Rollback on error
      _todos[index] = previousState;
      notifyListeners();
      return left(ServerFailure('Failed to toggle todo: $e'));
    }
  }

  // Delete todo with Optimistic State
  Future<Either<Failure, void>> _delete(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) {
      return left(const NotFoundFailure('Todo not found'));
    }

    final deletedTodo = _todos[index];

    // Optimistic delete
    _todos.removeAt(index);
    notifyListeners();

    try {
      final result = await _repository.deleteTodo(id);

      return result.fold(
        (failure) {
          // Rollback - reinsert at original position
          _todos.insert(index, deletedTodo);
          notifyListeners();
          return left(failure);
        },
        (_) => right(null),
      );
    } catch (e) {
      // Rollback on error
      _todos.insert(index, deletedTodo);
      notifyListeners();
      return left(ServerFailure('Failed to delete todo: $e'));
    }
  }

  // Edit todo with Optimistic State
  Future<Either<Failure, Todo>> _edit(String id, String newTitle) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) {
      return left(const NotFoundFailure('Todo not found'));
    }

    if (newTitle.trim().isEmpty) {
      return left(const ValidationFailure('Title cannot be empty'));
    }

    final previousState = _todos[index];

    // Optimistic update
    _todos[index] = _todos[index].copyWith(
      title: newTitle,
      isPending: true,
    );
    notifyListeners();

    try {
      final result = await _repository.updateTodo(_todos[index].copyWith(isPending: false));

      return result.fold(
        (failure) {
          // Rollback
          _todos[index] = previousState;
          notifyListeners();
          return left(failure);
        },
        (updatedTodo) {
          // Update with real data
          _todos[index] = updatedTodo;
          notifyListeners();
          return right(updatedTodo);
        },
      );
    } catch (e) {
      // Rollback on error
      _todos[index] = previousState;
      notifyListeners();
      return left(ServerFailure('Failed to edit todo: $e'));
    }
  }
}
