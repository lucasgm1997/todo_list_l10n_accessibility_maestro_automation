# Command Pattern - Quick Reference

Referência rápida para implementação do Command Pattern com Dartz Either.

## Instalação

```yaml
dependencies:
  dartz: ^0.10.1
```

## Estrutura Básica

```dart
// core/commands/command.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

typedef CommandAction0<T> = Future<Either<Failure, T>> Function();
typedef CommandAction1<T, A> = Future<Either<Failure, T>> Function(A);
typedef CommandAction2<T, A, B> = Future<Either<Failure, T>> Function(A, B);

abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;

  Either<Failure, T>? _result;

  bool get hasError => _result?.isLeft() ?? false;
  bool get isSuccess => _result?.isRight() ?? false;

  Failure? get failure => _result?.fold((f) => f, (_) => null);
  T? get value => _result?.fold((_) => null, (v) => v);

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

final class Command0<T> extends Command<T> {
  Command0(this._action);
  final CommandAction0<T> _action;

  Future<void> execute() async => await _execute(_action);
}

final class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final CommandAction1<T, A> _action;

  Future<void> execute(A arg) async => await _execute(() => _action(arg));
}

final class Command2<T, A, B> extends Command<T> {
  Command2(this._action);
  final CommandAction2<T, A, B> _action;

  Future<void> execute(A arg1, B arg2) async {
    await _execute(() => _action(arg1, arg2));
  }
}
```

## Uso no ViewModel

### Declaração

```dart
class MyViewModel extends ChangeNotifier {
  MyViewModel(this._repository);

  final MyRepository _repository;

  // Sem argumentos
  late final Command0<User> loadCommand = Command0(_load);

  // Com 1 argumento
  late final Command1<void, String> deleteCommand = Command1(_delete);

  // Com 2 argumentos
  late final Command2<User, String, String> loginCommand = Command2(_login);

  // Implementação privada
  Future<Either<Failure, User>> _load() async {
    return await _repository.getUser();
  }

  Future<Either<Failure, void>> _delete(String id) async {
    return await _repository.deleteUser(id);
  }

  Future<Either<Failure, User>> _login(String email, String password) async {
    return await _repository.login(email, password);
  }
}
```

### Auto-executar ao Criar

```dart
MyViewModel() {
  loadCommand = Command0(_load)..execute();
}
```

## Uso na View

### Setup

```dart
class MyView extends StatefulWidget {
  const MyView({super.key});

  @override
  State<MyView> createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
  late final MyViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<MyViewModel>();

    // Registrar listeners
    _vm.loadCommand.addListener(_onLoadChanged);
    _vm.deleteCommand.addListener(_onDeleteChanged);

    // Executar ação inicial
    _vm.loadCommand.execute();
  }

  @override
  void dispose() {
    // SEMPRE remover listeners
    _vm.loadCommand.removeListener(_onLoadChanged);
    _vm.deleteCommand.removeListener(_onDeleteChanged);
    super.dispose();
  }

  // Handlers de mudanças
  void _onLoadChanged() {
    if (_vm.loadCommand.hasError) {
      _vm.loadCommand.clearResult();
      _showError(_vm.loadCommand.failure!.message);
    }

    if (_vm.loadCommand.isSuccess) {
      // Sucesso - dados já atualizados no ViewModel
    }
  }

  void _onDeleteChanged() {
    if (_vm.deleteCommand.hasError) {
      _vm.deleteCommand.clearResult();
      _showError(_vm.deleteCommand.failure!.message);
    }

    if (_vm.deleteCommand.isSuccess) {
      _vm.deleteCommand.clearResult();
      _showSuccess('Deletado com sucesso');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
```

### UI com Loading/Error

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ListenableBuilder(
      listenable: _vm.loadCommand,
      builder: (context, child) {
        // Loading
        if (_vm.loadCommand.running) {
          return const Center(child: CircularProgressIndicator());
        }

        // Erro
        if (_vm.loadCommand.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erro: ${_vm.loadCommand.failure!.message}'),
                ElevatedButton(
                  onPressed: () => _vm.loadCommand.execute(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        // Conteúdo
        return child!;
      },
      child: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          // UI com dados
          return ListView(/* ... */);
        },
      ),
    ),
  );
}
```

## Estados do Command

```dart
// Verificar estado
command.running      // bool - está executando?
command.hasError     // bool - teve erro?
command.isSuccess    // bool - teve sucesso?

// Obter valores
command.failure      // Failure? - objeto de erro
command.value        // T? - valor de sucesso
command.result       // Either<Failure, T>? - resultado completo

// Limpar estado
command.clearResult()  // Limpa resultado (SEMPRE após consumir)
```

## Exemplo Completo: CRUD

```dart
class PostsViewModel extends ChangeNotifier {
  PostsViewModel(this._repository);

  final PostRepository _repository;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  // Commands
  late final Command0<List<Post>> loadCommand = Command0(_load);
  late final Command1<Post, String> createCommand = Command1(_create);
  late final Command2<Post, String, String> updateCommand = Command2(_update);
  late final Command1<void, String> deleteCommand = Command1(_delete);

  // Implementações
  Future<Either<Failure, List<Post>>> _load() async {
    final result = await _repository.getPosts();
    result.fold(
      (_) => null,
      (posts) => _posts = posts,
    );
    notifyListeners();
    return result;
  }

  Future<Either<Failure, Post>> _create(String title) async {
    final result = await _repository.createPost(title);
    result.fold(
      (_) => null,
      (post) {
        _posts.add(post);
        notifyListeners();
      },
    );
    return result;
  }

  Future<Either<Failure, Post>> _update(String id, String newTitle) async {
    final result = await _repository.updatePost(id, newTitle);
    result.fold(
      (_) => null,
      (updatedPost) {
        final index = _posts.indexWhere((p) => p.id == id);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
      },
    );
    return result;
  }

  Future<Either<Failure, void>> _delete(String id) async {
    final result = await _repository.deletePost(id);
    result.fold(
      (_) => null,
      (_) {
        _posts.removeWhere((p) => p.id == id);
        notifyListeners();
      },
    );
    return result;
  }
}
```

## Padrões de Uso

### Pattern 1: Executar e Ignorar Resultado

```dart
// Não precisa de listener
ElevatedButton(
  onPressed: () => viewModel.saveCommand.execute(),
  child: const Text('Salvar'),
)
```

### Pattern 2: Executar e Mostrar Erro

```dart
// Listener apenas para erro
void _onSaveChanged() {
  if (_vm.saveCommand.hasError) {
    _vm.saveCommand.clearResult();
    _showError(_vm.saveCommand.failure!.message);
  }
}
```

### Pattern 3: Executar e Navegar no Sucesso

```dart
void _onLoginChanged() {
  if (_vm.loginCommand.hasError) {
    _vm.loginCommand.clearResult();
    _showError(_vm.loginCommand.failure!.message);
  }

  if (_vm.loginCommand.isSuccess) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
```

### Pattern 4: Desabilitar Botão Durante Execução

```dart
ElevatedButton(
  onPressed: _vm.submitCommand.running
    ? null
    : () => _vm.submitCommand.execute(),
  child: _vm.submitCommand.running
    ? const CircularProgressIndicator()
    : const Text('Enviar'),
)
```

## Failures

```dart
// core/failures/failure.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
```

## Repository com Either

```dart
class UserRepository {
  final UserService _service;

  UserRepository(this._service);

  Future<Either<Failure, User>> getUser() async {
    try {
      final response = await _service.getUser();

      final user = User(
        id: response.id,
        name: response.name,
      );

      return right(user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return left(const NotFoundFailure('User not found'));
      }
      return left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return left(ServerFailure('Unknown error: $e'));
    }
  }
}
```

## Testes

```dart
void main() {
  late MyViewModel viewModel;
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    viewModel = MyViewModel(mockRepository);
  });

  test('loadCommand deve atualizar running corretamente', () async {
    when(() => mockRepository.getData()).thenAnswer(
      (_) async => right([]),
    );

    expect(viewModel.loadCommand.running, false);

    final future = viewModel.loadCommand.execute();
    expect(viewModel.loadCommand.running, true);

    await future;
    expect(viewModel.loadCommand.running, false);
    expect(viewModel.loadCommand.isSuccess, true);
  });

  test('loadCommand deve capturar erros', () async {
    when(() => mockRepository.getData()).thenAnswer(
      (_) async => left(const ServerFailure('Error')),
    );

    await viewModel.loadCommand.execute();

    expect(viewModel.loadCommand.hasError, true);
    expect(viewModel.loadCommand.failure, isA<ServerFailure>());
  });
}
```

## Checklist

- [ ] Criar `Command0`, `Command1`, `Command2` em `core/commands/`
- [ ] Criar `Failure` classes em `core/failures/`
- [ ] Repository retorna `Either<Failure, T>`
- [ ] ViewModel declara Commands como `late final`
- [ ] View registra listeners no `initState()`
- [ ] View remove listeners no `dispose()`
- [ ] View chama `clearResult()` após consumir
- [ ] Testar cada command isoladamente

## Boas Práticas

### ✅ Fazer

1. Sempre use `clearResult()` após consumir erro/sucesso
2. Remova listeners no `dispose()`
3. Use `late final` para commands
4. Nomeie commands de forma descritiva (`loadCommand`, não `load`)
5. Mantenha implementação privada (`_load`, não `load`)

### ❌ Evitar

1. Esquecer de chamar `clearResult()` (duplica mensagens)
2. Esquecer de remover listeners (memory leak)
3. Executar durante `running == true` (já prevenido)
4. Usar commands para estado simples (use notifyListeners)
5. Lógica complexa dentro do command (use repository)

## Recursos

- [Guia Completo](./guia_command_pattern.md)
- [MVVM Architecture](./reference_mvvm_architecture.md)
