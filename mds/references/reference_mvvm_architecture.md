# MVVM Architecture - Quick Reference

Referência rápida para implementação da arquitetura MVVM no Flutter.

## Estrutura de Pastas

```text
lib/
├── features/{feature_name}/
│   ├── views/              # Widgets (UI)
│   ├── view_models/        # Lógica de apresentação
│   └── widgets/            # Componentes reutilizáveis da feature
├── data/
│   ├── repositories/       # Fonte da verdade dos dados
│   ├── services/           # APIs, HTTP, Platform APIs
│   └── models/
│       ├── dto/           # Data Transfer Objects (API)
│       └── domain/        # Domain Models (App)
├── core/
│   ├── commands/          # Command Pattern
│   ├── failures/          # Error handling
│   └── utils/
└── di/                    # Dependency Injection
```

## Checklist de Implementação

### 1️⃣ Service (Acesso a Dados)

**Responsabilidade:** Apenas buscar dados de APIs externas.

```dart
class {Entity}Service {
  final Dio _dio;

  {Entity}Service(this._dio);

  Future<{Entity}Response> get{Entity}() async {
    final response = await _dio.get('/endpoint');
    return {Entity}Response.fromJson(response.data);
  }
}
```

**✅ Fazer:**

- Requisições HTTP
- Acessar APIs de plataforma
- Retornar DTOs (Data Transfer Objects)

**❌ Evitar:**

- Lógica de negócio
- Transformação de dados
- Manter estado

---

### 2️⃣ Repository (Lógica de Negócio)

**Responsabilidade:** Transformar dados e gerenciar estado da aplicação.

```dart
class {Entity}Repository {
  final {Entity}Service _service;

  {Entity}Repository(this._service);

  Future<Either<Failure, {Entity}>> get{Entity}() async {
    try {
      final response = await _service.get{Entity}();

      // Transforma DTO em Domain Model
      final entity = {Entity}(
        id: response.id,
        name: response.name,
      );

      return right(entity);
    } on DioException catch (e) {
      return left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return left(ServerFailure('Unknown error: $e'));
    }
  }
}
```

**✅ Fazer:**

- Transformar DTOs em Domain Models
- Cache de dados
- Tratamento de erros
- Retornar `Either<Failure, T>`

**❌ Evitar:**

- Lógica de UI
- Conhecer outros repositories
- Fazer requisições diretas (use Services)

---

### 3️⃣ ViewModel (Estado da UI)

**Responsabilidade:** Gerenciar estado e expor dados para a View.

```dart
class {Feature}ViewModel extends ChangeNotifier {
  final {Entity}Repository _repository;

  {Feature}ViewModel(this._repository);

  // Estado
  {Entity}? _entity;
  {Entity}? get entity => _entity;

  // Commands
  late final Command0<{Entity}> loadCommand = Command0(_load);

  Future<Either<Failure, {Entity}>> _load() async {
    final result = await _repository.get{Entity}();

    result.fold(
      (_) => null,
      (entity) => _entity = entity,
    );

    notifyListeners();
    return result;
  }
}
```

**✅ Fazer:**

- Manter estado da UI
- Usar Commands para ações
- Transformar dados para formato de apresentação
- Notificar mudanças (`notifyListeners()`)

**❌ Evitar:**

- Lógica de negócio complexa
- Acessar Services diretamente
- Lógica de navegação complexa

---

### 4️⃣ View (Interface)

**Responsabilidade:** Renderizar UI e capturar eventos.

```dart
class {Feature}View extends StatefulWidget {
  const {Feature}View({super.key});

  @override
  State<{Feature}View> createState() => _{Feature}ViewState();
}

class _{Feature}ViewState extends State<{Feature}View> {
  late final {Feature}ViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<{Feature}ViewModel>();
    _viewModel.loadCommand
      ..addListener(_onLoadCommandChanged)
      ..execute();
  }

  @override
  void dispose() {
    _viewModel.loadCommand.removeListener(_onLoadCommandChanged);
    super.dispose();
  }

  void _onLoadCommandChanged() {
    if (_viewModel.loadCommand.hasError) {
      _viewModel.loadCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.loadCommand.failure!.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel.loadCommand,
        builder: (context, _) {
          if (_viewModel.loadCommand.running) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              // UI com dados
              return Text(_viewModel.entity?.name ?? '');
            },
          );
        },
      ),
    );
  }
}
```

**✅ Fazer:**

- Renderizar widgets
- Escutar Commands
- Mostrar loading/erro
- Capturar eventos do usuário

**❌ Evitar:**

- Lógica de negócio
- Transformação de dados
- Acessar Repositories

---

## Commands (Padrão Command)

### Definição Rápida

```dart
// Sem argumentos
late final Command0<User> loadCommand = Command0(_load);

// Com 1 argumento
late final Command1<void, String> deleteCommand = Command1(_delete);

// Com 2 argumentos
late final Command2<User, String, String> loginCommand = Command2(_login);
```

### Estados do Command

```dart
command.running      // true se executando
command.hasError     // true se falhou
command.isSuccess    // true se sucesso
command.failure      // Failure object
command.value        // Valor de sucesso
```

### Uso na View

```dart
// Executar
viewModel.loadCommand.execute();
viewModel.deleteCommand.execute(id);
viewModel.loginCommand.execute(email, password);

// Escutar mudanças
viewModel.loadCommand.addListener(_onCommandChanged);

// Limpar resultado
viewModel.loadCommand.clearResult();
```

---

## Failures (Tratamento de Erros)

```dart
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
```

---

## Dependency Injection (GetIt)

```dart
// di/service_locator.dart
final getIt = GetIt.instance;

void setupDI() {
  // Services
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<{Entity}Service>(
    () => {Entity}Service(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<{Entity}Repository>(
    () => {Entity}Repository(getIt()),
  );

  // ViewModels (Factory - nova instância)
  getIt.registerFactory<{Feature}ViewModel>(
    () => {Feature}ViewModel(getIt()),
  );
}
```

---

## Models

### DTO (Data Transfer Object)

```dart
// models/dto/{entity}_response.dart
class {Entity}Response {
  final String id;
  final String name;

  {Entity}Response({required this.id, required this.name});

  factory {Entity}Response.fromJson(Map<String, dynamic> json) {
    return {Entity}Response(
      id: json['id'],
      name: json['name'],
    );
  }
}
```

### Domain Model

```dart
// models/domain/{entity}.dart
class {Entity} {
  final String id;
  final String name;

  const {Entity}({required this.id, required this.name});
}
```

---

## Fluxo de Dados

```text
User Tap
  ↓
View.onPressed → viewModel.command.execute()
  ↓
ViewModel → repository.getData()
  ↓
Repository → service.fetchData()
  ↓
Service → HTTP Request → API
  ↓
Service → DTO
  ↓
Repository → Domain Model → Either<Failure, Data>
  ↓
ViewModel → Update State → notifyListeners()
  ↓
View → Rebuild
```

---

## Checklist de Nova Feature

- [ ] Criar estrutura de pastas em `features/{feature_name}/`
- [ ] Criar DTOs em `data/models/dto/`
- [ ] Criar Domain Models em `data/models/domain/`
- [ ] Criar Failures específicas (se necessário)
- [ ] Implementar Service
- [ ] Implementar Repository com `Either<Failure, T>`
- [ ] Implementar ViewModel com Commands
- [ ] Implementar View com listeners
- [ ] Registrar dependências no DI
- [ ] Testar cada camada isoladamente

---

## Boas Práticas

### ✅ Fazer

1. **Separação clara**: Cada camada tem UMA responsabilidade
2. **Either para erros**: Sempre use `Either<Failure, T>`
3. **Commands para ações**: Evite bool `isLoading` manual
4. **DI para tudo**: Use GetIt/Riverpod
5. **Testar isoladamente**: Mock dependências

### ❌ Evitar

1. **View com lógica**: Views apenas renderizam
2. **ViewModels com HTTP**: Use Repositories
3. **Repositories se conhecendo**: Mantém desacoplados
4. **Exceptions não tratadas**: Use try-catch e Either
5. **Estado global**: Use ViewModels com escopo

---

## Template Completo (Copy-Paste)

```dart
// 1. Service
class UserService {
  final Dio _dio;
  UserService(this._dio);

  Future<UserResponse> getUser() async {
    final response = await _dio.get('/user');
    return UserResponse.fromJson(response.data);
  }
}

// 2. Repository
class UserRepository {
  final UserService _service;
  UserRepository(this._service);

  Future<Either<Failure, User>> getUser() async {
    try {
      final response = await _service.getUser();
      return right(User(id: response.id, name: response.name));
    } on DioException catch (e) {
      return left(NetworkFailure(e.message ?? 'Error'));
    }
  }
}

// 3. ViewModel
class ProfileViewModel extends ChangeNotifier {
  final UserRepository _repository;
  ProfileViewModel(this._repository);

  User? _user;
  User? get user => _user;

  late final Command0<User> loadCommand = Command0(_load);

  Future<Either<Failure, User>> _load() async {
    final result = await _repository.getUser();
    result.fold((_) => null, (user) => _user = user);
    notifyListeners();
    return result;
  }
}

// 4. View
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<ProfileViewModel>();
    _vm.loadCommand
      ..addListener(_onLoadChanged)
      ..execute();
  }

  @override
  void dispose() {
    _vm.loadCommand.removeListener(_onLoadChanged);
    super.dispose();
  }

  void _onLoadChanged() {
    if (_vm.loadCommand.hasError) {
      _vm.loadCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.loadCommand.failure!.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _vm.loadCommand,
        builder: (context, _) {
          if (_vm.loadCommand.running) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListenableBuilder(
            listenable: _vm,
            builder: (context, _) => Text(_vm.user?.name ?? ''),
          );
        },
      ),
    );
  }
}
```

---

## Recursos

- [Guia Completo](./guia_arquitetura_flutter.md)
- [Command Pattern](./guia_command_pattern.md)
- [Optimistic State](./guia_optimistic_state.md)
