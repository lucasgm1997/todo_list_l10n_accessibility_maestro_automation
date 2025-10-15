# Guia de Optimistic State no Flutter

Este guia apresenta o padrão **Optimistic State** (Estado Otimista) para melhorar a percepção de performance em aplicações Flutter, baseado na [documentação oficial](https://docs.flutter.dev/app-architecture/design-patterns/optimistic-state).

## Índice

1. [O que é Optimistic State?](#o-que-é-optimistic-state)
2. [Por que usar?](#por-que-usar)
3. [Quando usar?](#quando-usar)
4. [Implementação Passo a Passo](#implementação-passo-a-passo)
5. [Exemplos Práticos](#exemplos-práticos)
6. [Optimistic State Avançado](#optimistic-state-avançado)
7. [Boas Práticas](#boas-práticas)

## O que é Optimistic State?

**Optimistic State** (também conhecido como **Optimistic UI** ou **Optimistic User Experience**) é uma técnica onde a interface do usuário mostra o estado de sucesso **antes** da operação assíncrona ser concluída.

### Fluxo Tradicional vs Optimistic

#### ❌ Fluxo Tradicional

```text
1. Usuário clica no botão "Inscrever"
2. UI mostra loading
3. Aguarda resposta da API (1-2 segundos)
4. API responde com sucesso
5. UI atualiza para "Inscrito"
```

⏱️ **Problema:** Usuário espera 1-2 segundos para ver o resultado.

#### ✅ Fluxo Optimistic

```text
1. Usuário clica no botão "Inscrever"
2. UI atualiza IMEDIATAMENTE para "Inscrito"
3. Requisição da API acontece em background
4a. Se sucesso: nada muda (já está correto)
4b. Se falha: UI reverte para "Inscrever" e mostra erro
```

⚡ **Benefício:** Interface instantaneamente responsiva.

## Por que usar?

### Percepção de Performance

A percepção de performance é tão importante quanto a performance real. Usuários não gostam de esperar para ver o resultado de suas ações.

### Dados de UX

- ⏱️ Qualquer operação acima de **100ms** é percebida como lenta
- 📱 Usuários esperam feedback **instantâneo** em ações simples
- ✨ Apps que respondem imediatamente parecem mais "polidos"

### Exemplos do Mundo Real

- **Twitter/X:** Curtida aparece instantaneamente
- **Instagram:** Comentário aparece imediatamente na lista
- **YouTube:** Inscrição muda estado antes da API responder
- **Gmail:** Email vai para "Enviados" antes de ser realmente enviado

## Quando usar?

### ✅ Use Optimistic State quando

1. **Alta probabilidade de sucesso**
   - A operação raramente falha (> 95% de sucesso)
   - Exemplo: curtir um post, seguir um usuário

2. **Operação reversível**
   - É possível desfazer a ação
   - Exemplo: marcar como favorito, adicionar ao carrinho

3. **Feedback imediato é esperado**
   - Usuários esperam resposta instantânea
   - Exemplo: toggle buttons, checkboxes

4. **Operação não-crítica**
   - Falha não causa prejuízo severo
   - Exemplo: preferências de UI, like/unlike

### ❌ NÃO use Optimistic State quando

1. **Alta probabilidade de falha**
   - Operações que frequentemente falham
   - Exemplo: pagamentos, validações complexas

2. **Operação irreversível**
   - Não é possível desfazer
   - Exemplo: deletar conta, transferência bancária

3. **Operação crítica**
   - Falha causa prejuízo significativo
   - Exemplo: confirmação de compra, submissão de documentos

4. **Requer validação complexa**
   - Servidor precisa validar antes de prosseguir
   - Exemplo: cadastro de usuário, upload de arquivos grandes

## Implementação Passo a Passo

Vamos implementar um botão de inscrição (subscribe) que usa Optimistic State.

### Passo 1: Arquitetura da Feature

Seguindo a arquitetura Flutter, crie estas classes:

```dart
// features/subscription/views/subscribe_button.dart
class SubscribeButton extends StatefulWidget {
  const SubscribeButton({super.key, required this.viewModel});

  final SubscribeButtonViewModel viewModel;

  @override
  State<SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// features/subscription/view_models/subscribe_button_view_model.dart
class SubscribeButtonViewModel extends ChangeNotifier {
  SubscribeButtonViewModel(this._subscriptionRepository);

  final SubscriptionRepository _subscriptionRepository;
}

// data/repositories/subscription_repository.dart
class SubscriptionRepository {
  SubscriptionRepository(this._subscriptionService);

  final SubscriptionService _subscriptionService;
}
```

### Passo 2: Implementar o Repository

```dart
// data/repositories/subscription_repository.dart
class SubscriptionRepository {
  SubscriptionRepository(this._subscriptionService);

  final SubscriptionService _subscriptionService;

  /// Inscreve o usuário
  Future<void> subscribe() async {
    try {
      await _subscriptionService.subscribe();
    } catch (e) {
      throw Exception('Falha ao se inscrever: $e');
    }
  }

  /// Cancela a inscrição
  Future<void> unsubscribe() async {
    try {
      await _subscriptionService.unsubscribe();
    } catch (e) {
      throw Exception('Falha ao cancelar inscrição: $e');
    }
  }
}
```

### Passo 3: Implementar o Service (Mock)

Para demonstração, vamos simular um serviço que pode falhar:

```dart
// data/services/subscription_service.dart
class SubscriptionService {
  /// Simula uma requisição de rede que demora 1 segundo e falha
  Future<void> subscribe() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simula falha
    throw Exception('Erro de conexão');
  }

  /// Simula cancelamento de inscrição
  Future<void> unsubscribe() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
```

### Passo 4: Implementar o ViewModel com Optimistic State

```dart
// features/subscription/view_models/subscribe_button_view_model.dart
class SubscribeButtonViewModel extends ChangeNotifier {
  SubscribeButtonViewModel(this._subscriptionRepository);

  final SubscriptionRepository _subscriptionRepository;

  // Estado da inscrição
  bool subscribed = false;

  // Estado de erro
  bool error = false;

  /// Ação de inscrever
  Future<void> subscribe() async {
    // Ignora cliques quando já está inscrito
    if (subscribed) {
      return;
    }

    // ⭐ OPTIMISTIC STATE ⭐
    // Atualiza a UI ANTES da requisição completar
    subscribed = true;
    notifyListeners();

    try {
      // Faz a requisição real
      await _subscriptionRepository.subscribe();
      // Se chegou aqui, sucesso! UI já está correta.
    } catch (e) {
      print('Erro ao inscrever: $e');

      // ⚠️ REVERTER O ESTADO ⚠️
      // Como falhou, volta ao estado anterior
      subscribed = false;
      error = true;
    } finally {
      // Notifica a UI para atualizar
      notifyListeners();
    }
  }

  /// Ação de cancelar inscrição
  Future<void> unsubscribe() async {
    if (!subscribed) {
      return;
    }

    // Optimistic state
    subscribed = false;
    notifyListeners();

    try {
      await _subscriptionRepository.unsubscribe();
    } catch (e) {
      print('Erro ao cancelar inscrição: $e');

      // Reverter
      subscribed = true;
      error = true;
    } finally {
      notifyListeners();
    }
  }
}
```

### Passo 5: Implementar a View

```dart
// features/subscription/views/subscribe_button.dart
class SubscribeButton extends StatefulWidget {
  const SubscribeButton({super.key, required this.viewModel});

  final SubscribeButtonViewModel viewModel;

  @override
  State<SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton> {
  @override
  void initState() {
    super.initState();
    // Escuta mudanças no ViewModel
    widget.viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChange);
    super.dispose();
  }

  /// Chamado quando o ViewModel notifica mudanças
  void _onViewModelChange() {
    // Se houve erro, mostra Snackbar
    if (widget.viewModel.error) {
      widget.viewModel.error = false; // Reseta o erro

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao processar inscrição'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return FilledButton(
          onPressed: widget.viewModel.subscribed
              ? widget.viewModel.unsubscribe
              : widget.viewModel.subscribe,
          style: widget.viewModel.subscribed
              ? _subscribedStyle
              : _unsubscribedStyle,
          child: Text(
            widget.viewModel.subscribed ? 'Inscrito' : 'Inscrever',
          ),
        );
      },
    );
  }

  static const _unsubscribedStyle = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.red),
  );

  static const _subscribedStyle = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.green),
  );
}
```

### Passo 6: Usar o Widget

```dart
// Em qualquer tela
SubscribeButton(
  viewModel: SubscribeButtonViewModel(
    SubscriptionRepository(
      SubscriptionService(),
    ),
  ),
)
```

## Exemplos Práticos

### Exemplo 1: Botão de Curtir (Like)

```dart
class LikeButtonViewModel extends ChangeNotifier {
  LikeButtonViewModel(this._postRepository);

  final PostRepository _postRepository;

  bool _liked = false;
  bool get liked => _liked;

  int _likeCount = 0;
  int get likeCount => _likeCount;

  void initialize(bool initialLiked, int initialCount) {
    _liked = initialLiked;
    _likeCount = initialCount;
    notifyListeners();
  }

  Future<void> toggleLike(String postId) async {
    // Salva estado anterior para possível rollback
    final previousLiked = _liked;
    final previousCount = _likeCount;

    // Optimistic update
    _liked = !_liked;
    _likeCount += _liked ? 1 : -1;
    notifyListeners();

    try {
      if (_liked) {
        await _postRepository.likePost(postId);
      } else {
        await _postRepository.unlikePost(postId);
      }
    } catch (e) {
      // Rollback em caso de erro
      _liked = previousLiked;
      _likeCount = previousCount;
      notifyListeners();

      rethrow; // Para a View tratar o erro
    }
  }
}
```

### Exemplo 2: Adicionar ao Carrinho

```dart
class AddToCartViewModel extends ChangeNotifier {
  AddToCartViewModel(this._cartRepository);

  final CartRepository _cartRepository;

  bool _addedToCart = false;
  bool get addedToCart => _addedToCart;

  Future<void> addToCart(Product product) async {
    if (_addedToCart) return;

    // Optimistic update
    _addedToCart = true;
    notifyListeners();

    try {
      await _cartRepository.addItem(product);
    } catch (e) {
      // Rollback
      _addedToCart = false;
      notifyListeners();

      rethrow;
    }
  }

  void reset() {
    _addedToCart = false;
    notifyListeners();
  }
}
```

### Exemplo 3: Lista de Tarefas (Todo)

```dart
class TodoListViewModel extends ChangeNotifier {
  TodoListViewModel(this._todoRepository);

  final TodoRepository _todoRepository;

  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  /// Adiciona um todo com optimistic update
  Future<void> addTodo(String title) async {
    // Cria um todo temporário com ID local
    final tempTodo = Todo(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      completed: false,
      isPending: true, // Flag para indicar estado pendente
    );

    // Adiciona otimisticamente à lista
    _todos.add(tempTodo);
    notifyListeners();

    try {
      // Cria no servidor
      final createdTodo = await _todoRepository.createTodo(title);

      // Substitui o temporário pelo real
      final index = _todos.indexWhere((t) => t.id == tempTodo.id);
      if (index != -1) {
        _todos[index] = createdTodo;
        notifyListeners();
      }
    } catch (e) {
      // Remove o todo temporário em caso de erro
      _todos.removeWhere((t) => t.id == tempTodo.id);
      notifyListeners();

      rethrow;
    }
  }

  /// Marca como completo com optimistic update
  Future<void> toggleTodo(String todoId) async {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;

    final previousState = _todos[index];

    // Optimistic update
    _todos[index] = _todos[index].copyWith(
      completed: !_todos[index].completed,
    );
    notifyListeners();

    try {
      await _todoRepository.updateTodo(_todos[index]);
    } catch (e) {
      // Rollback
      _todos[index] = previousState;
      notifyListeners();

      rethrow;
    }
  }

  /// Deleta com optimistic update
  Future<void> deleteTodo(String todoId) async {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;

    final deletedTodo = _todos[index];

    // Remove otimisticamente
    _todos.removeAt(index);
    notifyListeners();

    try {
      await _todoRepository.deleteTodo(todoId);
    } catch (e) {
      // Reinsere na posição original
      _todos.insert(index, deletedTodo);
      notifyListeners();

      rethrow;
    }
  }
}

// Model
class Todo {
  final String id;
  final String title;
  final bool completed;
  final bool isPending; // Indica se está aguardando confirmação do servidor

  const Todo({
    required this.id,
    required this.title,
    required this.completed,
    this.isPending = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? completed,
    bool? isPending,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isPending: isPending ?? this.isPending,
    );
  }
}
```

### Exemplo 4: Widget de Todo com Estado Pendente

```dart
class TodoListView extends StatelessWidget {
  const TodoListView({super.key, required this.viewModel});

  final TodoListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return ListView.builder(
          itemCount: viewModel.todos.length,
          itemBuilder: (context, index) {
            final todo = viewModel.todos[index];

            return ListTile(
              leading: Checkbox(
                value: todo.completed,
                onChanged: (_) => viewModel.toggleTodo(todo.id),
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : null,
                  // Mostra em cinza se está pendente
                  color: todo.isPending ? Colors.grey : null,
                ),
              ),
              // Mostra ícone de "enviando" se está pendente
              trailing: todo.isPending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => viewModel.deleteTodo(todo.id),
                    ),
            );
          },
        );
      },
    );
  }
}
```

## Optimistic State Avançado

### Estado Triplo: Pendente, Sucesso, Erro

Em vez de apenas sucesso/erro, adicione um terceiro estado "pendente":

```dart
enum SubscriptionState {
  unsubscribed,   // Não inscrito
  pending,        // Aguardando resposta do servidor
  subscribed,     // Inscrito
}

class SubscribeButtonViewModel extends ChangeNotifier {
  final SubscriptionRepository _repository;

  SubscriptionState _state = SubscriptionState.unsubscribed;
  SubscriptionState get state => _state;

  bool get isSubscribed => _state == SubscriptionState.subscribed;
  bool get isPending => _state == SubscriptionState.pending;

  SubscribeButtonViewModel(this._repository);

  Future<void> subscribe() async {
    if (_state != SubscriptionState.unsubscribed) return;

    // Muda para estado pendente
    _state = SubscriptionState.pending;
    notifyListeners();

    try {
      await _repository.subscribe();
      _state = SubscriptionState.subscribed;
    } catch (e) {
      _state = SubscriptionState.unsubscribed;
    } finally {
      notifyListeners();
    }
  }
}
```

### View com Estado Pendente

```dart
FilledButton(
  onPressed: viewModel.subscribe,
  style: _getButtonStyle(viewModel.state),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(_getButtonText(viewModel.state)),
      if (viewModel.isPending) ...[
        const SizedBox(width: 8),
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      ],
    ],
  ),
)

ButtonStyle _getButtonStyle(SubscriptionState state) {
  switch (state) {
    case SubscriptionState.unsubscribed:
      return const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red));
    case SubscriptionState.pending:
      return const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.orange));
    case SubscriptionState.subscribed:
      return const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green));
  }
}

String _getButtonText(SubscriptionState state) {
  switch (state) {
    case SubscriptionState.unsubscribed:
      return 'Inscrever';
    case SubscriptionState.pending:
      return 'Inscrevendo...';
    case SubscriptionState.subscribed:
      return 'Inscrito';
  }
}
```

### Exemplo: Chat com Mensagens Pendentes

```dart
enum MessageStatus {
  sending,    // Enviando (optimistic)
  sent,       // Enviada com sucesso
  failed,     // Falha ao enviar
}

class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.status,
  });

  ChatMessage copyWith({MessageStatus? status}) {
    return ChatMessage(
      id: id,
      content: content,
      timestamp: timestamp,
      status: status ?? this.status,
    );
  }
}

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  ChatViewModel(this._repository);

  Future<void> sendMessage(String content) async {
    // Cria mensagem temporária
    final tempMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    // Adiciona otimisticamente
    _messages.add(tempMessage);
    notifyListeners();

    try {
      // Envia para o servidor
      final sentMessage = await _repository.sendMessage(content);

      // Atualiza com a mensagem real do servidor
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = sentMessage;
        notifyListeners();
      }
    } catch (e) {
      // Marca como falha
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = tempMessage.copyWith(status: MessageStatus.failed);
        notifyListeners();
      }
    }
  }

  Future<void> retryMessage(String messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final message = _messages[index];

    // Marca como enviando novamente
    _messages[index] = message.copyWith(status: MessageStatus.sending);
    notifyListeners();

    try {
      final sentMessage = await _repository.sendMessage(message.content);
      _messages[index] = sentMessage;
    } catch (e) {
      _messages[index] = message.copyWith(status: MessageStatus.failed);
    } finally {
      notifyListeners();
    }
  }
}
```

## Boas Práticas

### 1. Sempre Permita Rollback

```dart
// ✅ Bom - salva estado anterior
Future<void> toggleLike() async {
  final previousState = _liked;

  _liked = !_liked;
  notifyListeners();

  try {
    await repository.toggleLike();
  } catch (e) {
    _liked = previousState; // Rollback
    notifyListeners();
  }
}

// ❌ Ruim - não há como reverter
Future<void> toggleLike() async {
  _liked = !_liked;
  notifyListeners();

  await repository.toggleLike(); // E se falhar?
}
```

### 2. Use Estados Intermediários para Operações Longas

```dart
// ✅ Bom - mostra estado "enviando"
enum State { idle, sending, sent, error }

// ❌ Ruim - usuário não sabe se está processando
enum State { idle, sent, error }
```

### 3. Feedback Visual Claro

```dart
// ✅ Bom - mostra diferentes estados visualmente
if (isPending) {
  return const CircularProgressIndicator();
} else if (isSuccess) {
  return const Icon(Icons.check, color: Colors.green);
} else if (isError) {
  return const Icon(Icons.error, color: Colors.red);
}
```

### 4. Trate Erros Graciosamente

```dart
// ✅ Bom - mostra erro e permite retry
void _onError() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Erro ao processar'),
      action: SnackBarAction(
        label: 'Tentar novamente',
        onPressed: viewModel.retry,
      ),
    ),
  );
}
```

### 5. Considere Timeouts

```dart
Future<void> subscribe() async {
  _state = State.pending;
  notifyListeners();

  try {
    await _repository.subscribe().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Operação demorou muito');
      },
    );
    _state = State.subscribed;
  } catch (e) {
    _state = State.unsubscribed;
  } finally {
    notifyListeners();
  }
}
```

### 6. Evite Optimistic State em Operações Críticas

```dart
// ❌ NÃO use optimistic state aqui
Future<void> processPayment() async {
  // Pagamento é crítico - aguarde confirmação!
  _isProcessing = true;
  notifyListeners();

  final result = await paymentRepository.process();

  _isProcessing = false;
  _isSuccess = result.isSuccess;
  notifyListeners();
}
```

## Conclusão

**Optimistic State** é uma técnica poderosa para:

- ✅ Melhorar a percepção de performance
- ✅ Criar interfaces mais responsivas
- ✅ Aumentar a satisfação do usuário

**Use com sabedoria:**

- ✅ Em operações com alta taxa de sucesso
- ✅ Quando a reversão é possível
- ❌ Evite em operações críticas
- ❌ Não use quando reversão é impossível

Combinado com a arquitetura MVVM e o Command Pattern, você pode criar aplicações Flutter com excelente experiência de usuário.

## Recursos Adicionais

- [Documentação Oficial - Optimistic State](https://docs.flutter.dev/app-architecture/design-patterns/optimistic-state)
- [Command Pattern Guide](https://docs.flutter.dev/app-architecture/design-patterns/command)
- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
