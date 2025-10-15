# Guia do Command Pattern no Flutter

Este guia apresenta o padrão **Command** para simplificar ViewModels e gerenciar estados de ações de forma reutilizável, baseado na [documentação oficial do Flutter](https://docs.flutter.dev/app-architecture/design-patterns/command).

## Índice

1. [O que é o Command Pattern?](#o-que-é-o-command-pattern)
2. [Problemas que o Command Resolve](#problemas-que-o-command-resolve)
3. [Implementação Básica](#implementação-básica)
4. [Usando Dartz Either](#usando-dartz-either)
5. [Implementação Completa](#implementação-completa)
6. [Exemplos Práticos](#exemplos-práticos)
7. [Boas Práticas](#boas-práticas)

## O que é o Command Pattern?

Um **Command** é uma classe que encapsula um método e gerencia os diferentes estados desse método, como:

- ✅ **Running** (executando)
- ✅ **Completed** (concluído com sucesso)
- ✅ **Error** (concluído com erro)

Commands são usados em **ViewModels** para:

1. Gerenciar interações do usuário
2. Executar ações assíncronas
3. Exibir diferentes estados da UI (loading, sucesso, erro)
4. Reutilizar lógica de tratamento de estados

## Problemas que o Command Resolve

### Problema 1: Estados duplicados no ViewModel

Sem Commands, cada ação precisa de seus próprios estados:

```dart
class HomeViewModel extends ChangeNotifier {
  User? get user => _user;

  // Estados para a ação load
  bool get runningLoad => _runningLoad;
  Exception? get errorLoad => _errorLoad;

  // Estados para a ação edit
  bool get runningEdit => _runningEdit;
  Exception? get errorEdit => _errorEdit;

  // Estados para a ação delete
  bool get runningDelete => _runningDelete;
  Exception? get errorDelete => _errorDelete;

  void load() { /* ... */ }
  void edit(String name) { /* ... */ }
  void delete() { /* ... */ }
}
```

❌ **Problemas:**

- Código repetitivo
- Difícil de manter
- Estados se acumulam rapidamente

### Problema 2: Execução múltipla de ações

Sem controle adequado, o usuário pode disparar uma ação múltiplas vezes:

```dart
Future<void> load() async {
  // Usuário pode apertar o botão várias vezes
  _isLoading = true;
  notifyListeners();

  await repository.loadUser();

  _isLoading = false;
  notifyListeners();
}
```

### Problema 3: Tratamento manual de erros

Cada ação precisa de seu próprio try-catch:

```dart
Future<void> load() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _user = await repository.loadUser();
  } catch (e) {
    _error = e;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### Solução: Command Pattern

Com Commands, tudo isso é encapsulado:

```dart
class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    load = Command0(_load)..execute();
    edit = Command1<String>(_edit);
    delete = Command0(_delete);
  }

  late final Command0 load;
  late final Command1<String> edit;
  late final Command0 delete;

  Future<void> _load() async {
    // apenas a lógica de negócio
  }

  Future<void> _edit(String name) async {
    // apenas a lógica de negócio
  }

  Future<void> _delete() async {
    // apenas a lógica de negócio
  }
}
```

## Implementação Básica

### Estrutura do Command

```dart
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;

  Exception? _error;
  Exception? get error => _error;

  bool _completed = false;
  bool get completed => _completed;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

### Command0 (sem parâmetros)

```dart
class Command0<T> extends Command<T> {
  Command0(this._action);

  final Future<T> Function() _action;

  Future<void> execute() async {
    if (_running) return;

    _running = true;
    _completed = false;
    _error = null;
    notifyListeners();

    try {
      await _action();
      _completed = true;
    } on Exception catch (e) {
      _error = e;
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}
```

### Command1 (com 1 parâmetro)

```dart
class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final Future<T> Function(A) _action;

  Future<void> execute(A argument) async {
    if (_running) return;

    _running = true;
    _completed = false;
    _error = null;
    notifyListeners();

    try {
      await _action(argument);
      _completed = true;
    } on Exception catch (e) {
      _error = e;
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}
```

## Usando Dartz Either

O pacote **dartz** fornece o tipo `Either<L, R>` para representar um resultado que pode ser sucesso ou falha.

### Instalação

```yaml
# pubspec.yaml
dependencies:
  dartz: ^0.10.1
```

### Estrutura de Failure

```dart
// core/failures/failure.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```

### Command com Either

Definimos tipos para as ações:

```dart
// core/commands/command_action.dart
import 'package:dartz/dartz.dart';

/// Ação de comando sem argumentos que retorna Either<Failure, T>
typedef CommandAction0<T> = Future<Either<Failure, T>> Function();

/// Ação de comando com 1 argumento que retorna Either<Failure, T>
typedef CommandAction1<T, A> = Future<Either<Failure, T>> Function(A);

/// Ação de comando com 2 argumentos que retorna Either<Failure, T>
typedef CommandAction2<T, A, B> = Future<Either<Failure, T>> Function(A, B);
```

### Implementação do Command com Either

```dart
// core/commands/command.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;

  Either<Failure, T>? _result;
  Either<Failure, T>? get result => _result;

  /// Retorna true se o comando completou com erro
  bool get hasError => _result?.isLeft() ?? false;

  /// Retorna true se o comando completou com sucesso
  bool get isSuccess => _result?.isRight() ?? false;

  /// Obtém o erro, se existir
  Failure? get failure => _result?.fold(
        (failure) => failure,
        (_) => null,
      );

  /// Obtém o valor de sucesso, se existir
  T? get value => _result?.fold(
        (_) => null,
        (value) => value,
      );

  /// Limpa o resultado atual
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  /// Executa a ação fornecida
  Future<void> _execute(CommandAction0<T> action) async {
    // Previne execução múltipla
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
```

### Command0 com Either

```dart
/// Command sem argumentos
final class Command0<T> extends Command<T> {
  Command0(this._action);

  final CommandAction0<T> _action;

  Future<void> execute() async {
    await _execute(_action);
  }
}
```

### Command1 com Either

```dart
/// Command com 1 argumento
final class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
```

### Command2 com Either

```dart
/// Command com 2 argumentos
final class Command2<T, A, B> extends Command<T> {
  Command2(this._action);

  final CommandAction2<T, A, B> _action;

  Future<void> execute(A arg1, B arg2) async {
    await _execute(() => _action(arg1, arg2));
  }
}
```

## Implementação Completa

### Arquivo completo: command.dart

```dart
// core/commands/command.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../failures/failure.dart';

/// Ação de comando sem argumentos
typedef CommandAction0<T> = Future<Either<Failure, T>> Function();

/// Ação de comando com 1 argumento
typedef CommandAction1<T, A> = Future<Either<Failure, T>> Function(A);

/// Ação de comando com 2 argumentos
typedef CommandAction2<T, A, B> = Future<Either<Failure, T>> Function(A, B);

/// Classe base para Commands
///
/// Encapsula uma ação e gerencia seus estados (running, error, completed).
/// Actions devem retornar Either<Failure, T>.
///
/// Use [Command0] para ações sem argumentos.
/// Use [Command1] para ações com um argumento.
/// Use [Command2] para ações com dois argumentos.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;

  /// Se a ação está em execução
  bool get running => _running;

  Either<Failure, T>? _result;

  /// Resultado da execução mais recente
  Either<Failure, T>? get result => _result;

  /// Se a última execução resultou em erro
  bool get hasError => _result?.isLeft() ?? false;

  /// Se a última execução foi bem-sucedida
  bool get isSuccess => _result?.isRight() ?? false;

  /// Obtém o Failure se a execução falhou
  Failure? get failure => _result?.fold(
        (failure) => failure,
        (_) => null,
      );

  /// Obtém o valor se a execução foi bem-sucedida
  T? get value => _result?.fold(
        (_) => null,
        (value) => value,
      );

  /// Limpa o resultado da execução
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  /// Executa a ação fornecida
  Future<void> _execute(CommandAction0<T> action) async {
    // Previne execução múltipla
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

/// Command que não aceita argumentos
final class Command0<T> extends Command<T> {
  Command0(this._action);

  final CommandAction0<T> _action;

  /// Executa a ação
  Future<void> execute() async {
    await _execute(_action);
  }
}

/// Command que aceita 1 argumento
final class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final CommandAction1<T, A> _action;

  /// Executa a ação com o argumento fornecido
  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}

/// Command que aceita 2 argumentos
final class Command2<T, A, B> extends Command<T> {
  Command2(this._action);

  final CommandAction2<T, A, B> _action;

  /// Executa a ação com os argumentos fornecidos
  Future<void> execute(A arg1, B arg2) async {
    await _execute(() => _action(arg1, arg2));
  }
}
```

## Exemplos Práticos

### Exemplo 1: Login com Command

#### Repository

```dart
// data/repositories/auth_repository.dart
class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return left(const ValidationFailure('Email e senha são obrigatórios'));
      }

      final response = await _authService.login(email, password);

      return right(User(
        id: response.userId,
        email: response.email,
        name: response.name,
      ));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Erro desconhecido: $e'));
    }
  }
}
```

#### ViewModel

```dart
// features/auth/view_models/login_view_model.dart
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final AuthRepository _authRepository;

  String _email = '';
  String _password = '';

  late final Command2<User, String, String> loginCommand =
    Command2<User, String, String>(_login);

  void onEmailChanged(String value) {
    _email = value;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    _password = value;
    notifyListeners();
  }

  Future<Either<Failure, User>> _login(String email, String password) async {
    return await _authRepository.login(email, password);
  }

  void login() {
    loginCommand.execute(_email, _password);
  }
}
```

#### View

```dart
// features/auth/views/login_view.dart
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LoginViewModel>();
    _viewModel.loginCommand.addListener(_onLoginCommandChanged);
  }

  @override
  void dispose() {
    _viewModel.loginCommand.removeListener(_onLoginCommandChanged);
    super.dispose();
  }

  void _onLoginCommandChanged() {
    if (_viewModel.loginCommand.hasError) {
      final failure = _viewModel.loginCommand.failure!;
      _viewModel.loginCommand.clearResult();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }

    if (_viewModel.loginCommand.isSuccess) {
      // Navegar para home
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: _viewModel.loginCommand,
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  onChanged: _viewModel.onEmailChanged,
                  decoration: const InputDecoration(labelText: 'Email'),
                  enabled: !_viewModel.loginCommand.running,
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: _viewModel.onPasswordChanged,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  enabled: !_viewModel.loginCommand.running,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: _viewModel.loginCommand.running
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _viewModel.login,
                          child: const Text('Entrar'),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

### Exemplo 2: Carregar e Deletar Posts

#### ViewModel

```dart
// features/posts/view_models/posts_view_model.dart
class PostsViewModel extends ChangeNotifier {
  PostsViewModel(this._postRepository);

  final PostRepository _postRepository;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  late final Command0<List<Post>> loadCommand = Command0(_loadPosts);
  late final Command1<void, String> deleteCommand = Command1(_deletePost);

  Future<Either<Failure, List<Post>>> _loadPosts() async {
    final result = await _postRepository.getPosts();

    result.fold(
      (_) => null,
      (posts) => _posts = posts,
    );

    return result;
  }

  Future<Either<Failure, void>> _deletePost(String postId) async {
    final result = await _postRepository.deletePost(postId);

    result.fold(
      (_) => null,
      (_) {
        _posts.removeWhere((post) => post.id == postId);
        notifyListeners();
      },
    );

    return result;
  }
}
```

#### View

```dart
// features/posts/views/posts_view.dart
class PostsView extends StatefulWidget {
  const PostsView({super.key});

  @override
  State<PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<PostsView> {
  late final PostsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<PostsViewModel>();
    _viewModel.loadCommand
      ..addListener(_onLoadCommandChanged)
      ..execute();
    _viewModel.deleteCommand.addListener(_onDeleteCommandChanged);
  }

  @override
  void dispose() {
    _viewModel.loadCommand.removeListener(_onLoadCommandChanged);
    _viewModel.deleteCommand.removeListener(_onDeleteCommandChanged);
    super.dispose();
  }

  void _onLoadCommandChanged() {
    if (_viewModel.loadCommand.hasError) {
      _viewModel.loadCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.loadCommand.failure!.message),
        ),
      );
    }
  }

  void _onDeleteCommandChanged() {
    if (_viewModel.deleteCommand.hasError) {
      _viewModel.deleteCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.deleteCommand.failure!.message),
        ),
      );
    }

    if (_viewModel.deleteCommand.isSuccess) {
      _viewModel.deleteCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deletado com sucesso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: ListenableBuilder(
        listenable: _viewModel.loadCommand,
        builder: (context, _) {
          if (_viewModel.loadCommand.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.loadCommand.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: ${_viewModel.loadCommand.failure!.message}'),
                  ElevatedButton(
                    onPressed: () => _viewModel.loadCommand.execute(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return ListView.builder(
                itemCount: _viewModel.posts.length,
                itemBuilder: (context, index) {
                  final post = _viewModel.posts[index];
                  return ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.content),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _viewModel.deleteCommand.execute(post.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _viewModel.loadCommand.execute(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

### Exemplo 3: Múltiplos ListenableBuilders

Você pode combinar múltiplos listeners para gerenciar estados complexos:

```dart
body: ListenableBuilder(
  // Listener do comando
  listenable: viewModel.loadCommand,
  builder: (context, child) {
    // Mostra loading
    if (viewModel.loadCommand.running) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostra erro
    if (viewModel.loadCommand.hasError) {
      return Center(
        child: Text('Error: ${viewModel.loadCommand.failure!.message}'),
      );
    }

    // Retorna o conteúdo principal
    return child!;
  },
  child: ListenableBuilder(
    // Listener do ViewModel para atualizações de dados
    listenable: viewModel,
    builder: (context, _) {
      return ListView.builder(
        itemCount: viewModel.posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: viewModel.posts[index]);
        },
      );
    },
  ),
),
```

## Boas Práticas

### 1. Nomeação de Commands

Use substantivos descritivos que representam a ação:

```dart
// ✅ Bom
late final Command0<User> loadCommand;
late final Command1<void, String> deleteCommand;
late final Command2<User, String, String> loginCommand;

// ❌ Evite
late final Command0<User> load;
late final Command1<void, String> delete;
```

### 2. Limpeza de Resultados

Sempre limpe o resultado após consumi-lo para evitar ações duplicadas:

```dart
void _onCommandChanged() {
  if (viewModel.loadCommand.hasError) {
    viewModel.loadCommand.clearResult(); // ✅ Limpa o resultado
    // Mostra erro
  }
}
```

### 3. Execute no Constructor Quando Necessário

Para ações que devem executar imediatamente:

```dart
class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    loadCommand = Command0(_load)..execute(); // ✅ Executa ao criar
  }

  late final Command0<User> loadCommand;

  Future<Either<Failure, User>> _load() async {
    // ...
  }
}
```

### 4. Combine com Provider/Riverpod

```dart
// Com Provider
ChangeNotifierProvider(
  create: (_) => PostsViewModel(getIt<PostRepository>()),
  child: const PostsView(),
)

// Com Riverpod
final postsViewModelProvider = ChangeNotifierProvider.autoDispose(
  (ref) => PostsViewModel(ref.read(postRepositoryProvider)),
);
```

### 5. Teste Commands Isoladamente

```dart
void main() {
  late PostsViewModel viewModel;
  late MockPostRepository mockRepository;

  setUp(() {
    mockRepository = MockPostRepository();
    viewModel = PostsViewModel(mockRepository);
  });

  test('loadCommand deve definir estado running corretamente', () async {
    when(() => mockRepository.getPosts()).thenAnswer(
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
    when(() => mockRepository.getPosts()).thenAnswer(
      (_) async => left(const ServerFailure('Erro do servidor')),
    );

    await viewModel.loadCommand.execute();

    expect(viewModel.loadCommand.hasError, true);
    expect(viewModel.loadCommand.failure, isA<ServerFailure>());
    expect(viewModel.loadCommand.failure!.message, 'Erro do servidor');
  });
}
```

### 6. Estrutura de Pastas Recomendada

```text
lib/
├── core/
│   ├── commands/
│   │   └── command.dart
│   └── failures/
│       └── failure.dart
│
├── features/
│   └── auth/
│       ├── views/
│       │   └── login_view.dart
│       └── view_models/
│           └── login_view_model.dart
│
└── data/
    └── repositories/
        └── auth_repository.dart
```

## Vantagens do Command Pattern

### ✅ Código mais limpo

```dart
// Sem Command
class ViewModel extends ChangeNotifier {
  bool _loadRunning = false;
  Exception? _loadError;
  bool _editRunning = false;
  Exception? _editError;
  bool _deleteRunning = false;
  Exception? _deleteError;
  // ...
}

// Com Command
class ViewModel extends ChangeNotifier {
  late final Command0 load;
  late final Command1<String> edit;
  late final Command0 delete;
}
```

### ✅ Reutilização

Commands podem ser reutilizados em diferentes ViewModels sem duplicar código.

### ✅ Testabilidade

Cada command pode ser testado isoladamente, facilitando testes unitários.

### ✅ Prevenção de bugs

- Previne execução múltipla automaticamente
- Captura exceções automaticamente
- Gerencia estados de forma consistente

### ✅ Separação de responsabilidades

- ViewModel: lógica de negócio
- Command: gerenciamento de estado da ação
- View: apresentação

## Comparação: Sem Command vs Com Command

### Sem Command

```dart
class PostsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Future<void> loadPosts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await repository.getPosts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Com Command

```dart
class PostsViewModel extends ChangeNotifier {
  late final Command0<List<Post>> loadCommand = Command0(_loadPosts);

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Future<Either<Failure, List<Post>>> _loadPosts() async {
    final result = await repository.getPosts();
    result.fold(
      (_) => null,
      (posts) => _posts = posts,
    );
    return result;
  }
}
```

✅ **Benefícios:**

- Menos boilerplate
- Estados gerenciados automaticamente
- Código mais legível

## Conclusão

O **Command Pattern** é uma ferramenta poderosa para:

- ✅ Simplificar ViewModels
- ✅ Gerenciar estados de ações de forma consistente
- ✅ Evitar código duplicado
- ✅ Melhorar testabilidade
- ✅ Prevenir bugs comuns

Combinado com **Dartz Either**, oferece uma solução robusta e type-safe para gerenciar operações assíncronas no Flutter.

## Recursos Adicionais

- [Documentação Oficial - Command Pattern](https://docs.flutter.dev/app-architecture/design-patterns/command)
- [Pacote Dartz](https://pub.dev/packages/dartz)
- [Compass App Example](https://github.com/flutter/samples/tree/main/compass_app)
