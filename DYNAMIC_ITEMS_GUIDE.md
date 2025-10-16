# Guia de Testes com Itens Dinâmicos - Maestro

## Visão Geral

Este guia explica como usar o sistema de mock com itens dinâmicos para testes robustos com Maestro, permitindo testar a UI com contagens variáveis de elementos.

## Componentes Implementados

### 1. MockTodoService (`lib/data/services/mock_todo_service.dart`)

Service que gera uma lista dinâmica de itens toda vez que o app é iniciado.

**Parâmetros configuráveis:**
- `minItems`: Número mínimo de itens (padrão: 0)
- `maxItems`: Número máximo de itens (padrão: 10)
- `seed`: Semente para geração determinística (opcional)
- `titlePattern`: Padrão de título com placeholder `{i}` (padrão: "Task {i}")
- `withStableIds`: Gerar IDs estáveis para testes (padrão: true)

**Exemplo de uso:**
```dart
// Geração aleatória (diferente a cada execução)
final mockService = MockTodoService(
  minItems: 3,
  maxItems: 10,
);

// Geração determinística (sempre os mesmos itens)
final mockService = MockTodoService(
  minItems: 5,
  maxItems: 5,
  seed: 42,  // Sempre gera os mesmos 5 itens
);
```

### 2. IDs Semânticos por Índice

Todos os widgets TodoItem agora geram IDs baseados no índice na lista:

- Container: `todo_item_container_{index}`
- Título: `todo_item_title_{index}`
- Checkbox: `todo_item_checkbox_{index}`
- Botão Delete: `todo_item_delete_{index}`
- Botão Edit: `todo_item_edit_{index}`

**Exemplos:**
```
todo_item_container_0   # Primeiro item
todo_item_title_0
todo_item_checkbox_0
todo_item_delete_0

todo_item_container_1   # Segundo item
todo_item_title_1
todo_item_checkbox_1
todo_item_delete_1
```

## Configuração

### Arquivo `lib/data/services/mock_config.dart`

```dart
class MockConfig {
  // Para testes aleatórios
  static const int? seed = null;
  static const int minItems = 3;
  static const int maxItems = 10;

  // Para testes determinísticos
  static const int? seed = 42;  // Descomente para testes determinísticos
  static const int minItems = 5;
  static const int maxItems = 5;  // Mesma quantidade sempre
}
```

## Flows do Maestro

### Flow 1: DynamicItems.yaml

Testa interações básicas com itens dinâmicos usando condicionais.

**Características:**
- Usa `runFlow` com `when: visible` para ações condicionais
- Não assume quantidade fixa de itens
- Testa adicionar, marcar e deletar itens

**Executar:**
```bash
set -a && source .env && set +a && maestro test maestro_flows/DynamicItems.yaml
```

### Flow 2: RobustDynamicTest.yaml

Teste mais robusto que adiciona vários itens e testa em múltiplos índices.

**Características:**
- Adiciona 3 novos itens independente do estado inicial
- Tenta deletar itens em vários índices possíveis (2-10)
- Verifica que ainda é possível adicionar itens após operações

**Executar:**
```bash
set -a && source .env && set +a && maestro test maestro_flows/RobustDynamicTest.yaml
```

## Estratégias de Teste

### 1. Testes Condicionais

Use `runFlow` com `when` para executar ações apenas se o elemento existir:

```yaml
- runFlow:
    when:
      visible:
        id: todo_item_title_0
    commands:
      - tapOn:
          id: todo_item_checkbox_0
```

### 2. Busca por Múltiplos Índices

Para encontrar um item específico, tente múltiplos índices:

```yaml
# Tentar deletar item no índice 0
- runFlow:
    when:
      visible:
        id: todo_item_delete_0
    commands:
      - tapOn:
          id: todo_item_delete_0

# Tentar deletar item no índice 1
- runFlow:
    when:
      visible:
        id: todo_item_delete_1
    commands:
      - tapOn:
          id: todo_item_delete_1
```

### 3. Busca por Texto

Quando o título é previsível, busque por texto:

```yaml
- tapOn:
    id: ${MAESTRO_TODO_ADD_INPUT}
- inputText: "Specific Item"
- tapOn:
    id: ${MAESTRO_TODO_ADD_BUTTON}

# Verificar que foi adicionado
- assertVisible: "Specific Item"
```

### 4. Scroll para Itens Não Visíveis

Se a lista for longa:

```yaml
- scrollUntilVisible:
    element:
      id: todo_item_title_5
    direction: DOWN
```

## Cenários de Teste

### Cenário 1: Lista Vazia (min=0, max=0)

```dart
final mockService = MockTodoService(
  minItems: 0,
  maxItems: 0,
);
```

**Flow Maestro:**
```yaml
- assertVisible: ${MAESTRO_TODO_ADD_INPUT}
- assertVisible:
    text: "Nenhuma tarefa"  # Empty state
```

### Cenário 2: Lista com Itens Fixos (min=max)

```dart
final mockService = MockTodoService(
  minItems: 5,
  maxItems: 5,
  seed: 42,  // Determinístico
);
```

**Flow Maestro:**
```yaml
- assertVisible:
    id: todo_item_title_0
- assertVisible:
    id: todo_item_title_4
- assertNotVisible:
    id: todo_item_title_5  # Não existe
```

### Cenário 3: Lista Variável (min < max)

```dart
final mockService = MockTodoService(
  minItems: 3,
  maxItems: 10,
  seed: null,  // Aleatório
);
```

**Flow Maestro:**
```yaml
# Sempre terá pelo menos 3 itens
- assertVisible:
    id: todo_item_title_0
- assertVisible:
    id: todo_item_title_2

# Pode ou não ter item no índice 5
- runFlow:
    when:
      visible:
        id: todo_item_title_5
    commands:
      - tapOn:
          id: todo_item_checkbox_5
```

## Checklist de Testes

- [ ] **Teste com seed fixo (determinístico)**
  ```bash
  # Configurar MockConfig.seed = 42
  maestro test maestro_flows/RobustDynamicTest.yaml
  ```

- [ ] **Teste sem seed (aleatório)**
  ```bash
  # Configurar MockConfig.seed = null
  maestro test maestro_flows/RobustDynamicTest.yaml
  # Executar múltiplas vezes para verificar robustez
  ```

- [ ] **Teste com lista vazia**
  ```bash
  # Configurar minItems = 0, maxItems = 0
  maestro test maestro_flows/DynamicItems.yaml
  ```

- [ ] **Teste com lista cheia (>10 itens)**
  ```bash
  # Configurar minItems = 15, maxItems = 20
  maestro test maestro_flows/RobustDynamicTest.yaml
  ```

- [ ] **Teste com scrolling**
  - Verificar que itens fora da tela são acessíveis

## Boas Práticas

### ✅ Faça

1. **Use condicionais para ações em itens opcionais**
   ```yaml
   - runFlow:
       when:
         visible:
           id: todo_item_title_0
       commands:
         - tapOn:
             id: todo_item_checkbox_0
   ```

2. **Adicione waits após operações**
   ```yaml
   - tapOn:
       id: todo_item_delete_0
   - waitToSettleMs: 500  # Aguardar animação
   ```

3. **Verifique por texto quando possível**
   ```yaml
   - assertVisible: "Task 0"
   ```

4. **Use múltiplas tentativas para encontrar elementos**
   ```yaml
   # Tentar índices 0-5 até encontrar
   - runFlow:
       when:
         visible:
           id: todo_item_title_0
       commands: [...]
   - runFlow:
       when:
         visible:
           id: todo_item_title_1
       commands: [...]
   ```

### ❌ Evite

1. **Assumir contagem fixa de itens**
   ```yaml
   # ❌ Ruim
   - assertVisible:
       id: todo_item_title_5  # Pode não existir

   # ✅ Bom
   - runFlow:
       when:
         visible:
           id: todo_item_title_5
       commands:
         - assertVisible:
             id: todo_item_title_5
   ```

2. **Depender de posições absolutas**
   ```yaml
   # ❌ Ruim
   - tapOn:
       point: "50%,300px"  # Posição pode mudar

   # ✅ Bom
   - tapOn:
       id: todo_item_checkbox_0
   ```

3. **Não tratar casos vazios**
   ```yaml
   # ✅ Sempre verificar se há itens antes
   - runFlow:
       when:
         visible:
           id: todo_item_container_0
       commands:
         - tapOn:
             id: todo_item_checkbox_0
   ```

## Integração com CI/CD

### GitHub Actions

```yaml
- name: Test with Fixed Seed
  run: |
    # Editar MockConfig para usar seed fixo
    sed -i 's/seed = null/seed = 42/' lib/data/services/mock_config.dart
    flutter build apk
    maestro test maestro_flows/RobustDynamicTest.yaml

- name: Test with Random Seed
  run: |
    # Executar 3 vezes com seeds diferentes
    for i in {1..3}; do
      flutter build apk
      maestro test maestro_flows/DynamicItems.yaml
    done
```

## Troubleshooting

### Problema: Elemento não encontrado mesmo existindo

**Causa:** Item pode estar fora da tela.

**Solução:**
```yaml
- scrollUntilVisible:
    element:
      id: todo_item_title_5
```

### Problema: Teste passa às vezes e falha outras

**Causa:** Contagem de itens varia entre execuções (seed = null).

**Solução:** Use condicionais ou fixe o seed para testes determinísticos.

```yaml
- runFlow:
    when:
      visible:
        id: todo_item_title_3
    commands:
      - tapOn:
          id: todo_item_checkbox_3
```

### Problema: IDs não estão sendo reconhecidos

**Causa:** Hot reload pode não atualizar os IDs semânticos.

**Solução:** Faça full restart do app:
```bash
flutter clean
flutter build apk
flutter install
```

## Referências

- [Documentação Maestro - Condicionais](https://maestro.mobile.dev)
- [Flutter Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- Arquivo de especificação: `mds/dynamic_items_to_maestro_handling.md`
