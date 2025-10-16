import 'package:get_it/get_it.dart';
import 'package:maestro_test/data/repositories/todo_repository.dart';
import 'package:maestro_test/data/services/todo_service.dart';
import 'package:maestro_test/data/services/mock_todo_service.dart';
import 'package:maestro_test/data/services/mock_config.dart';
import 'package:maestro_test/features/todo/view_models/todo_view_model.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Services - Using MockTodoService with random items
  getIt.registerLazySingleton<TodoService>(
    () => MockTodoService(
      minItems: MockConfig.minItems,
      maxItems: MockConfig.maxItems,
      seed: MockConfig.seed,
      titlePattern: MockConfig.titlePattern,
      withStableIds: MockConfig.withStableIds,
    ),
  );

  // Repositories
  getIt.registerLazySingleton<TodoRepository>(
    () => TodoRepository(getIt()),
  );

  // ViewModels (Factory - nova instância)
  getIt.registerFactory<TodoViewModel>(
    () => TodoViewModel(getIt()),
  );
}
