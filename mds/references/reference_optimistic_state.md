# Optimistic State - Quick Reference

Referência rápida para implementação de Optimistic State (UI Otimista).

## Conceito

**Optimistic State:** Atualizar a UI ANTES da API responder, assumindo sucesso. Reverter se falhar.

```text
Tradicional:  Tap → Loading → API → Update UI (1-2s delay)
Optimistic:   Tap → Update UI → API em background → Revert se falhar
```

## Quando Usar?

### ✅ Use quando:

- **Alta taxa de sucesso** (>95%)
- **Operação reversível** (pode desfazer)
- **Feedback imediato esperado** (like, follow)
- **Não-crítico** (falha não causa prejuízo)

**Exemplos:** Like, Follow, Add to Cart, Toggle Settings

### ❌ NÃO use quando:

- **Alta taxa de falha**
- **Operação irreversível** (delete account, payment)
- **Crítico** (confirmação de compra)
- **Requer validação complexa** (signup, file upload)

**Exemplos:** Pagamentos, Deletar Conta, Transferências

## Pattern Básico

```dart
class MyViewModel extends ChangeNotifier {
  bool _state = false;
  bool get state => _state;

  Future<void> toggle() async {
    // 1. Salvar estado anterior (para rollback)
    final previousState = _state;

    // 2. ⭐ OPTIMISTIC UPDATE ⭐
    _state = !_state;
    notifyListeners();

    try {
      // 3. Fazer requisição real
      await repository.toggle();
      // 4. Sucesso - UI já está correta!
    } catch (e) {
      // 5. ⚠️ ROLLBACK ⚠️
      _state = previousState;
      notifyListeners();

      rethrow; // Para View tratar erro
    }
  }
}
```

## Exemplos Práticos

### 1. Like Button

```dart
class LikeViewModel extends ChangeNotifier {
  LikeViewModel(this._repository);
  final PostRepository _repository;

  bool _liked = false;
  bool get liked => _liked;

  int _count = 0;
  int get count => _count;

  void initialize(bool initialLiked, int initialCount) {
    _liked = initialLiked;
    _count = initialCount;
    notifyListeners();
  }

  Future<void> toggleLike(String postId) async {
    // Salvar estado
    final prevLiked = _liked;
    final prevCount = _count;

    // Optimistic update
    _liked = !_liked;
    _count += _liked ? 1 : -1;
    notifyListeners();

    try {
      if (_liked) {
        await _repository.like(postId);
      } else {
        await _repository.unlike(postId);
      }
    } catch (e) {
      // Rollback
      _liked = prevLiked;
      _count = prevCount;
      notifyListeners();

      rethrow;
    }
  }
}
```

**View:**

```dart
IconButton(
  icon: Icon(
    viewModel.liked ? Icons.favorite : Icons.favorite_border,
    color: viewModel.liked ? Colors.red : Colors.grey,
  ),
  onPressed: () => viewModel.toggleLike(postId),
)
Text('${viewModel.count}')
```

### 2. Subscribe Button

```dart
class SubscribeViewModel extends ChangeNotifier {
  SubscribeViewModel(this._repository);
  final SubscriptionRepository _repository;

  bool subscribed = false;
  bool error = false;

  Future<void> subscribe() async {
    if (subscribed) return;

    // Optimistic
    subscribed = true;
    notifyListeners();

    try {
      await _repository.subscribe();
    } catch (e) {
      // Revert
      subscribed = false;
      error = true;
      notifyListeners();
    }
  }
}
```

**View com Error Handling:**

```dart
@override
void initState() {
  super.initState();
  widget.viewModel.addListener(_onViewModelChange);
}

void _onViewModelChange() {
  if (widget.viewModel.error) {
    widget.viewModel.error = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao inscrever')),
    );
  }
}

@override
Widget build(BuildContext context) {
  return ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) {
      return FilledButton(
        onPressed: widget.viewModel.subscribe,
        style: widget.viewModel.subscribed
          ? greenStyle
          : redStyle,
        child: Text(widget.viewModel.subscribed ? 'Inscrito' : 'Inscrever'),
      );
    },
  );
}
```

### 3. Todo List (Add/Toggle/Delete)

```dart
class TodoViewModel extends ChangeNotifier {
  TodoViewModel(this._repository);
  final TodoRepository _repository;

  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  // ADD com temp ID
  Future<void> addTodo(String title) async {
    final tempTodo = Todo(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      completed: false,
      isPending: true,
    );

    // Optimistic add
    _todos.add(tempTodo);
    notifyListeners();

    try {
      final createdTodo = await _repository.create(title);

      // Substituir temp por real
      final index = _todos.indexWhere((t) => t.id == tempTodo.id);
      if (index != -1) {
        _todos[index] = createdTodo;
        notifyListeners();
      }
    } catch (e) {
      // Remove temp
      _todos.removeWhere((t) => t.id == tempTodo.id);
      notifyListeners();
      rethrow;
    }
  }

  // TOGGLE
  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final previousState = _todos[index];

    // Optimistic toggle
    _todos[index] = _todos[index].copyWith(
      completed: !_todos[index].completed,
    );
    notifyListeners();

    try {
      await _repository.update(_todos[index]);
    } catch (e) {
      // Rollback
      _todos[index] = previousState;
      notifyListeners();
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final deletedTodo = _todos[index];

    // Optimistic delete
    _todos.removeAt(index);
    notifyListeners();

    try {
      await _repository.delete(id);
    } catch (e) {
      // Rollback - reinsere na posição original
      _todos.insert(index, deletedTodo);
      notifyListeners();
      rethrow;
    }
  }
}
```

**View com Estado Pendente:**

```dart
ListTile(
  leading: Checkbox(
    value: todo.completed,
    onChanged: (_) => viewModel.toggleTodo(todo.id),
  ),
  title: Text(
    todo.title,
    style: TextStyle(
      decoration: todo.completed ? TextDecoration.lineThrough : null,
      color: todo.isPending ? Colors.grey : null,
    ),
  ),
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
)
```

## Estado Triplo (Avançado)

Para mostrar estado "pendente" durante a requisição:

```dart
enum SubscriptionState {
  unsubscribed,  // Inicial
  pending,       // Aguardando API
  subscribed,    // Sucesso
}

class ViewModel extends ChangeNotifier {
  SubscriptionState _state = SubscriptionState.unsubscribed;
  SubscriptionState get state => _state;

  bool get isPending => _state == SubscriptionState.pending;

  Future<void> subscribe() async {
    if (_state != SubscriptionState.unsubscribed) return;

    // Muda para pending (mostra loading)
    _state = SubscriptionState.pending;
    notifyListeners();

    try {
      await repository.subscribe();
      _state = SubscriptionState.subscribed;
    } catch (e) {
      _state = SubscriptionState.unsubscribed;
    } finally {
      notifyListeners();
    }
  }
}
```

**View:**

```dart
FilledButton(
  onPressed: viewModel.subscribe,
  style: _getStyle(viewModel.state),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(_getText(viewModel.state)),
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

ButtonStyle _getStyle(SubscriptionState state) {
  switch (state) {
    case SubscriptionState.unsubscribed:
      return redStyle;
    case SubscriptionState.pending:
      return orangeStyle;
    case SubscriptionState.subscribed:
      return greenStyle;
  }
}

String _getText(SubscriptionState state) {
  switch (state) {
    case SubscriptionState.unsubscribed: return 'Inscrever';
    case SubscriptionState.pending: return 'Inscrevendo...';
    case SubscriptionState.subscribed: return 'Inscrito';
  }
}
```

## Chat com Retry

```dart
enum MessageStatus { sending, sent, failed }

class ChatMessage {
  final String id;
  final String content;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.status,
  });

  ChatMessage copyWith({MessageStatus? status}) {
    return ChatMessage(
      id: id,
      content: content,
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
    // Mensagem temporária
    final tempMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      status: MessageStatus.sending,
    );

    // Optimistic add
    _messages.add(tempMsg);
    notifyListeners();

    try {
      final sentMsg = await _repository.send(content);

      // Atualizar com mensagem real
      final index = _messages.indexWhere((m) => m.id == tempMsg.id);
      if (index != -1) {
        _messages[index] = sentMsg;
        notifyListeners();
      }
    } catch (e) {
      // Marcar como falha
      final index = _messages.indexWhere((m) => m.id == tempMsg.id);
      if (index != -1) {
        _messages[index] = tempMsg.copyWith(status: MessageStatus.failed);
        notifyListeners();
      }
    }
  }

  Future<void> retryMessage(String messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final message = _messages[index];

    // Marcar como enviando novamente
    _messages[index] = message.copyWith(status: MessageStatus.sending);
    notifyListeners();

    try {
      final sentMsg = await _repository.send(message.content);
      _messages[index] = sentMsg;
    } catch (e) {
      _messages[index] = message.copyWith(status: MessageStatus.failed);
    } finally {
      notifyListeners();
    }
  }
}
```

**View:**

```dart
ListTile(
  title: Text(message.content),
  trailing: _buildTrailing(message),
)

Widget _buildTrailing(ChatMessage message) {
  switch (message.status) {
    case MessageStatus.sending:
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    case MessageStatus.sent:
      return const Icon(Icons.check, color: Colors.green);
    case MessageStatus.failed:
      return IconButton(
        icon: const Icon(Icons.refresh, color: Colors.red),
        onPressed: () => viewModel.retryMessage(message.id),
      );
  }
}
```

## Checklist

### ✅ Antes de Implementar

- [ ] Operação tem alta taxa de sucesso (>95%)?
- [ ] Operação é reversível?
- [ ] Usuário espera feedback imediato?
- [ ] Falha não causa prejuízo crítico?

### ✅ Durante Implementação

- [ ] Salvar estado anterior para rollback
- [ ] Atualizar UI ANTES da requisição
- [ ] Fazer requisição em background
- [ ] Implementar rollback em caso de erro
- [ ] (Opcional) Mostrar estado "pendente"
- [ ] Tratar erro na View com Snackbar/Dialog

## Boas Práticas

### ✅ Fazer

1. **Sempre permita rollback** - Salve estado anterior
2. **Use estado intermediário** para operações longas (pending)
3. **Feedback visual claro** - Mostre "enviando..." com ícone
4. **Trate erros graciosamente** - Snackbar com retry
5. **Considere timeouts** - Não deixe pendente infinitamente

### ❌ Evitar

1. **Operações críticas** - Pagamentos, deletar conta
2. **Alta probabilidade de falha** - Validações complexas
3. **Sem rollback** - Sempre implemente reversão
4. **Sem feedback de erro** - Usuário precisa saber se falhou
5. **Estado inconsistente** - Mantenha sincronizado

## Combinação com Commands

```dart
class LikeViewModel extends ChangeNotifier {
  late final Command1<void, String> likeCommand = Command1(_like);

  bool _liked = false;
  bool get liked => _liked;

  Future<Either<Failure, void>> _like(String postId) async {
    // Salvar estado
    final prevLiked = _liked;

    // Optimistic
    _liked = !_liked;
    notifyListeners();

    try {
      if (_liked) {
        await repository.like(postId);
      } else {
        await repository.unlike(postId);
      }
      return right(null);
    } catch (e) {
      // Rollback
      _liked = prevLiked;
      notifyListeners();

      return left(ServerFailure('Failed to like'));
    }
  }
}
```

## Recursos

- [Guia Completo](./guia_optimistic_state.md)
- [Command Pattern](./reference_command_pattern.md)
- [MVVM Architecture](./reference_mvvm_architecture.md)
