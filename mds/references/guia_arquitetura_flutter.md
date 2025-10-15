# Guia de Implementação da Arquitetura Flutter

Este guia apresenta as melhores práticas para arquitetar aplicações Flutter, baseado na [documentação oficial](https://docs.flutter.dev/app-architecture/guide). As recomendações podem ser aplicadas à maioria dos apps, tornando-os mais fáceis de escalar, testar e manter.

## Índice

1. [Visão Geral](#visão-geral)
2. [Camada de UI](#camada-de-ui)
3. [Camada de Dados](#camada-de-dados)
4. [Camada de Domínio (Opcional)](#camada-de-domínio-opcional)
5. [Estrutura de Pastas Sugerida](#estrutura-de-pastas-sugerida)
6. [Fluxo de Dados](#fluxo-de-dados)
7. [Boas Práticas](#boas-práticas)

## Visão Geral

A arquitetura recomendada segue o padrão **MVVM (Model-View-ViewModel)** e divide a aplicação em camadas:

```text
┌─────────────────────────────────────┐
│         CAMADA DE UI                │
│  ┌──────────┐      ┌─────────────┐  │
│  │   View   │ ←──→ │  ViewModel  │  │
│  └──────────┘      └─────────────┘  │
└─────────────────────────────────────┘
              ↕
┌─────────────────────────────────────┐
│       CAMADA DE DADOS               │
│  ┌────────────┐    ┌──────────┐    │
│  │ Repository │ ←→ │ Service  │    │
│  └────────────┘    └──────────┘    │
└─────────────────────────────────────┘
```

### Componentes Principais

- **Views**: Descrevem como apresentar dados ao usuário (composição de widgets)
- **ViewModels**: Contêm a lógica que converte dados em UI State
- **Repositories**: Fonte da verdade para os dados da aplicação
- **Services**: Encapsulam APIs externas, plugins e fontes de dados

## Camada de UI

A camada de UI é responsável por interagir com o usuário, composta por **Views** e **ViewModels**.

### Views

Views são as classes de widgets da aplicação. Devem ser **stateless** sempre que possível e receber todos os dados do ViewModel.

**Responsabilidades:**

- Renderizar a interface do usuário
- Capturar eventos do usuário (taps, inputs, etc.)
- Passar eventos para o ViewModel

**O que Views DEVEM conter:**

- ✅ Lógica de animação
- ✅ Lógica de layout baseada em tamanho/orientação da tela
- ✅ `if` statements simples para mostrar/esconder widgets
- ✅ Lógica simples de navegação

**O que Views NÃO DEVEM conter:**

- ❌ Lógica de negócio
- ❌ Manipulação direta de dados
- ❌ Chamadas para repositories ou services

**Exemplo:**

```dart
// views/login_view.dart
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: viewModel.onEmailChanged,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              onChanged: viewModel.onPasswordChanged,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            if (viewModel.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: viewModel.login,
                child: const Text('Entrar'),
              ),
            if (viewModel.errorMessage != null)
              Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
```

### ViewModels

ViewModels expõem os dados necessários para renderizar a View e contêm a maior parte da lógica da aplicação.

**Responsabilidades:**

- Recuperar dados dos repositories
- Transformar dados para formato adequado à UI
- Manter o estado atual da View
- Expor **commands** (callbacks) para a View

**Exemplo:**

```dart
// view_models/login_view_model.dart
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  // Estado da UI
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Callbacks para eventos da UI
  void onEmailChanged(String value) {
    _email = value;
    _errorMessage = null;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    _password = value;
    _errorMessage = null;
    notifyListeners();
  }

  // Commands
  Future<void> login() async {
    if (_email.isEmpty || _password.isEmpty) {
      _errorMessage = 'Preencha todos os campos';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(_email, _password);
      // Navegação ou outra ação de sucesso
    } catch (e) {
      _errorMessage = 'Erro ao fazer login: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Relacionamento View ↔ ViewModel

- **Proporção 1:1**: Cada View deve ter um ViewModel correspondente
- Uma feature = uma View + um ViewModel
- Use gerenciamento de estado (Provider, Riverpod, Bloc, etc.) para conectar View e ViewModel

## Camada de Dados

A camada de dados gerencia os dados de negócio e lógica, composta por **Repositories** e **Services**.

### Repositories

Repositories são a **fonte da verdade** para os dados do modelo. Transformam dados brutos em **domain models**.

**Responsabilidades:**

- Buscar dados dos services
- Transformar dados brutos em domain models
- Cache de dados
- Tratamento de erros
- Lógica de retry
- Atualização de dados

**Exemplo:**

```dart
// repositories/auth_repository.dart
class AuthRepository {
  final AuthService _authService;
  final LocalStorageService _localStorage;

  AuthRepository(this._authService, this._localStorage);

  User? _currentUser;

  // Expõe um Stream do usuário atual
  Stream<User?> get userStream => _userStreamController.stream;
  final _userStreamController = StreamController<User?>.broadcast();

  Future<void> login(String email, String password) async {
    try {
      // Chama o service
      final authResponse = await _authService.login(email, password);

      // Transforma em domain model
      _currentUser = User(
        id: authResponse.userId,
        email: authResponse.email,
        name: authResponse.name,
      );

      // Salva token localmente (cache)
      await _localStorage.saveToken(authResponse.token);

      // Notifica listeners
      _userStreamController.add(_currentUser);
    } on NetworkException catch (e) {
      // Tratamento de erro específico
      throw AuthException('Erro de conexão: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _localStorage.clearToken();
    _currentUser = null;
    _userStreamController.add(null);
  }

  void dispose() {
    _userStreamController.close();
  }
}

// models/user.dart (Domain Model)
class User {
  final String id;
  final String email;
  final String name;

  User({
    required this.id,
    required this.email,
    required this.name,
  });
}
```

**Regras:**

- Um repository por tipo de dado (UserRepository, ProductRepository, etc.)
- Repositories nunca devem conhecer outros repositories
- Relacionamento many-to-many com ViewModels

### Services

Services encapsulam endpoints de API e expõem objetos assíncronos (`Future`, `Stream`). Não mantêm estado.

**Responsabilidades:**

- Isolar carregamento de dados
- Fazer requisições HTTP
- Acessar APIs de plataforma (iOS/Android)
- Ler arquivos locais

**Exemplo:**

```dart
// services/auth_service.dart
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Erro de rede');
    }
  }
}

// models/auth_response.dart (Data Transfer Object)
class AuthResponse {
  final String userId;
  final String email;
  final String name;
  final String token;

  AuthResponse({
    required this.userId,
    required this.email,
    required this.name,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'],
      email: json['email'],
      name: json['name'],
      token: json['token'],
    );
  }
}
```

**Regras:**

- Um service por fonte de dados
- Relacionamento many-to-many com Repositories
- Services são úteis quando os dados estão fora do código Dart

## Camada de Domínio (Opcional)

À medida que o app cresce, pode ser necessário abstrair lógica complexa em **use-cases** (ou interactors).

### Quando usar Use-Cases?

Use-cases são úteis quando a lógica:

1. ✅ Requer combinar dados de múltiplos repositories
2. ✅ É extremamente complexa
3. ✅ Será reutilizada por diferentes ViewModels

### Prós e Contras

| Prós | Contras |
|------|---------|
| ✅ Evita duplicação de código nos ViewModels | ❌ Aumenta complexidade da arquitetura |
| ✅ Melhora testabilidade | ❌ Requer mocks adicionais nos testes |
| ✅ Melhora legibilidade | ❌ Adiciona boilerplate |

### Exemplo de Use-Case

```dart
// use_cases/get_user_profile_use_case.dart
class GetUserProfileUseCase {
  final UserRepository _userRepository;
  final PostRepository _postRepository;
  final FollowerRepository _followerRepository;

  GetUserProfileUseCase(
    this._userRepository,
    this._postRepository,
    this._followerRepository,
  );

  Future<UserProfile> execute(String userId) async {
    // Combina dados de múltiplos repositories
    final user = await _userRepository.getUserById(userId);
    final posts = await _postRepository.getPostsByUser(userId);
    final followers = await _followerRepository.getFollowers(userId);

    // Lógica complexa de transformação
    return UserProfile(
      user: user,
      postCount: posts.length,
      followerCount: followers.length,
      topPosts: _getTopPosts(posts),
    );
  }

  List<Post> _getTopPosts(List<Post> posts) {
    return posts
      ..sort((a, b) => b.likes.compareTo(a.likes))
      ..take(5).toList();
  }
}
```

## Estrutura de Pastas Sugerida

```text
lib/
├── main.dart
├── app.dart
│
├── features/                    # Organização por feature
│   ├── auth/
│   │   ├── views/
│   │   │   ├── login_view.dart
│   │   │   └── register_view.dart
│   │   ├── view_models/
│   │   │   ├── login_view_model.dart
│   │   │   └── register_view_model.dart
│   │   └── widgets/            # Widgets específicos da feature
│   │       └── auth_button.dart
│   │
│   ├── home/
│   │   ├── views/
│   │   │   └── home_view.dart
│   │   └── view_models/
│   │       └── home_view_model.dart
│   │
│   └── profile/
│       ├── views/
│       ├── view_models/
│       └── use_cases/          # Use-cases específicos da feature
│           └── get_user_profile_use_case.dart
│
├── data/
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   └── post_repository.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── api_service.dart
│   │   └── local_storage_service.dart
│   │
│   └── models/
│       ├── dto/               # Data Transfer Objects (da API)
│       │   └── auth_response.dart
│       └── domain/            # Domain Models (da aplicação)
│           ├── user.dart
│           └── post.dart
│
├── shared/                     # Código compartilhado
│   ├── widgets/               # Widgets reutilizáveis
│   ├── utils/
│   ├── constants/
│   └── theme/
│
└── di/                        # Dependency Injection
    └── service_locator.dart
```

## Fluxo de Dados

### 1. Fluxo de Carregamento de Dados

```text
User Action → View → ViewModel → Repository → Service → API
                ↓         ↓            ↓
              Update    Update      Cache
               UI       State       Data
```

**Exemplo passo a passo:**

1. Usuário toca em um botão na **View**
2. View chama um **command** do ViewModel (ex: `viewModel.loadPosts()`)
3. ViewModel chama o **Repository** (ex: `await _postRepository.getPosts()`)
4. Repository chama o **Service** (ex: `await _apiService.fetchPosts()`)
5. Service faz requisição HTTP e retorna dados brutos
6. Repository transforma dados em domain models e faz cache
7. Repository retorna domain models para o ViewModel
8. ViewModel atualiza seu estado interno
9. ViewModel notifica a View (`notifyListeners()`)
10. View reconstrói exibindo os novos dados

### 2. Fluxo com Use-Case

```text
View → ViewModel → Use-Case → [Repository 1, Repository 2] → Services
         ↓
       Update UI
```

## Boas Práticas

### 1. Separation of Concerns (Separação de Responsabilidades)

- ✅ Cada classe deve ter uma única responsabilidade
- ✅ Views apenas renderizam e capturam eventos
- ✅ ViewModels gerenciam estado e lógica de apresentação
- ✅ Repositories gerenciam dados e lógica de negócio
- ✅ Services apenas acessam fontes de dados externas

### 2. Dependency Injection

Use injeção de dependência para facilitar testes e manter baixo acoplamento:

```dart
// di/service_locator.dart
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt()));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt(), getIt()),
  );

  // ViewModels (factories para criar novas instâncias)
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt()),
  );
}
```

### 3. Gerenciamento de Estado

Escolha uma solução de gerenciamento de estado adequada:

**Provider:**

```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => getIt<LoginViewModel>()),
  ],
  child: const MyApp(),
)
```

**Riverpod:**

```dart
final loginViewModelProvider = ChangeNotifierProvider.autoDispose(
  (ref) => LoginViewModel(ref.read(authRepositoryProvider)),
);
```

### 4. Tratamento de Erros

Crie exceções customizadas para diferentes tipos de erro:

```dart
// shared/exceptions/app_exception.dart
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}
```

### 5. Testes

Com essa arquitetura, você pode testar cada camada isoladamente:

**Teste de ViewModel:**

```dart
void main() {
  late LoginViewModel viewModel;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = LoginViewModel(mockRepository);
  });

  test('login deve atualizar isLoading corretamente', () async {
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => Future.delayed(Duration(seconds: 1)));

    expect(viewModel.isLoading, false);

    final loginFuture = viewModel.login();
    expect(viewModel.isLoading, true);

    await loginFuture;
    expect(viewModel.isLoading, false);
  });
}
```

### 6. Nomeação de Arquivos e Classes

- **Views**: `login_view.dart` → `LoginView`
- **ViewModels**: `login_view_model.dart` → `LoginViewModel`
- **Repositories**: `auth_repository.dart` → `AuthRepository`
- **Services**: `auth_service.dart` → `AuthService`
- **Use-Cases**: `get_user_profile_use_case.dart` → `GetUserProfileUseCase`

### 7. Commands (Callbacks)

Use comandos descritivos nos ViewModels:

```dart
class ProductListViewModel extends ChangeNotifier {
  // Commands
  Future<void> loadProducts() async { /* ... */ }
  Future<void> refreshProducts() async { /* ... */ }
  void onProductTapped(Product product) { /* ... */ }
  void onFilterChanged(String filter) { /* ... */ }
  Future<void> deleteProduct(String id) async { /* ... */ }
}
```

## Exemplo Completo: Feature de Login

### 1. Service

```dart
// data/services/auth_service.dart
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(response.data);
  }
}
```

### 2. Repository

```dart
// data/repositories/auth_repository.dart
class AuthRepository {
  final AuthService _authService;
  final LocalStorageService _localStorage;

  User? _currentUser;
  final _userController = StreamController<User?>.broadcast();

  Stream<User?> get userStream => _userController.stream;
  User? get currentUser => _currentUser;

  AuthRepository(this._authService, this._localStorage);

  Future<void> login(String email, String password) async {
    final response = await _authService.login(email, password);
    _currentUser = User(
      id: response.userId,
      email: response.email,
      name: response.name,
    );
    await _localStorage.saveToken(response.token);
    _userController.add(_currentUser);
  }
}
```

### 3. ViewModel

```dart
// features/auth/view_models/login_view_model.dart
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canSubmit => _email.isNotEmpty && _password.isNotEmpty;

  LoginViewModel(this._authRepository);

  void onEmailChanged(String value) {
    _email = value;
    _errorMessage = null;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    _password = value;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(_email, _password);
    } catch (e) {
      _errorMessage = 'Erro ao fazer login';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 4. View

```dart
// features/auth/views/login_view.dart
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<LoginViewModel>(),
      child: const _LoginViewContent(),
    );
  }
}

class _LoginViewContent extends StatelessWidget {
  const _LoginViewContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: viewModel.onEmailChanged,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: viewModel.onPasswordChanged,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 24),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: viewModel.canSubmit ? viewModel.login : null,
                      child: const Text('Entrar'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Conclusão

Esta arquitetura baseada em MVVM oferece:

- ✅ **Separação clara de responsabilidades**
- ✅ **Facilidade de testes** (cada camada pode ser testada isoladamente)
- ✅ **Escalabilidade** (fácil adicionar novas features)
- ✅ **Manutenibilidade** (código organizado e previsível)
- ✅ **Reutilização de código** (repositories e services compartilhados)

Lembre-se: estas são **diretrizes, não regras absolutas**. Adapte a arquitetura às necessidades específicas do seu projeto.

## Recursos Adicionais

- [Documentação Oficial do Flutter - App Architecture](https://docs.flutter.dev/app-architecture/guide)
- [App Architecture Case Study](https://docs.flutter.dev/app-architecture/case-study)
- [State Management Fundamentals](https://docs.flutter.dev/get-started/fundamentals/state-management)
