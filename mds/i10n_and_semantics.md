# Internacionalização e Semântica dos Componentes

## Objetivo

1. Suporte a múltiplos idiomas através de arquivos ARB com acesso type-safe
2. Testes E2E robustos usando Maestro com identificadores estáveis baseados em keys
3. Manutenção consistente de identificadores através de código gerado

## Requisitos Técnicos

### Fonte Única da Verdade (Single Source of Truth)

**Princípio Central**: As keys dos arquivos ARB são a **única fonte da verdade** para identificadores em toda a aplicação.

- ARB keys são identificadores estáveis e imutáveis (ex: `todo_item_delete_button`)
- Valores ARB (traduções) podem mudar sem afetar testes ou identificadores
- Keys ARB alimentam três sistemas:
  1. **Geração de constantes Semantics** (via script)
  2. **Variáveis de ambiente do Maestro** (para testes E2E)
  3. **AppLocalizations** (via gen-l10n nativo do Flutter)

### Internacionalização (i18n)

- Utilizar o sistema de ARB (Application Resource Bundle) do Flutter
- Implementar geração de código para as strings traduzidas via `flutter gen-l10n`
- Criar arquivos ARB: `app_en.arb` (template) e `app_pt.arb` (tradução)
- Flutter gera automaticamente em `.dart_tool/flutter_gen/gen_l10n/`:
  - `app_localizations.dart` - classe abstrata
  - `app_localizations_en.dart` - implementação inglês
  - `app_localizations_pt.dart` - implementação português
- Utilizar classes geradas para acesso type-safe às traduções (evitar strings literais)
- Definir keys significativas e estáveis nos ARBs para uso como identificadores
- Evitar uso de strings hardcoded para textos visíveis ao usuário
- **ARB keys NUNCA devem mudar** - apenas valores (traduções)
- Flutter converte keys snake_case em getters camelCase automaticamente

### Semantics e Identificadores Type-Safe

- Criar classe de constantes **gerada automaticamente** a partir das keys dos ARBs
- Utilizar as keys dos ARBs (não os valores traduzidos) como base para identificadores
- Implementar identificadores constantes e estáveis para testes E2E com Maestro
- Garantir que cada elemento interativo tenha um identificador único e type-safe
- Manter keys ARB estáveis mesmo quando as traduções mudam
- Adicionar Semantics em todos os componentes interativos usando as constantes geradas
- Script de geração deve ler `app_pt.arb` e criar `lib/core/semantics/app_semantics.dart`

### Integração com Maestro

- Maestro flows devem usar variáveis de ambiente para identificadores
- Variáveis devem ter os mesmos valores das keys ARB
- Criar arquivo `maestro_flows/constants.yaml` com todas as variáveis
- Flows nunca devem usar strings literais para identificadores
- Exemplo: `tapOn: { id: ${TODO_DELETE_BUTTON} }` onde `TODO_DELETE_BUTTON: todo_item_delete_button`

## Componentes a Serem Atualizados

- TodoCheckbox: Adicionar semantics para estado de conclusão
- TodoDeleteButton: Adicionar semantics para ação de exclusão
- TodoEditButton: Adicionar semantics para ação de edição
- TodoTitle: Adicionar semantics para título e estado
- TodoSubtitle: Adicionar semantics para data de criação
- TodoItem: Coordenar semantics dos subcomponentes

## Estrutura de Arquivos

```
lib/
  l10n/
    app_en.arb                      # Traduções em inglês (template)
    app_pt.arb                      # Traduções em português
  core/
    semantics/
      app_semantics.dart            # Constantes geradas a partir do ARB
l10n.yaml                           # Configuração do gen-l10n (raiz do projeto)
tools/
  generate_semantics.dart           # Script de geração das constantes Semantics + Maestro
maestro_flows/
  constants.yaml                    # Variáveis para Maestro (mesmas keys do ARB)
  flows/
    add_todo.yaml                   # Flows usando variáveis
    delete_todo.yaml

# Código gerado automaticamente pelo Flutter (NÃO COMMITAR):
.dart_tool/flutter_gen/gen_l10n/
  app_localizations.dart            # Classe abstrata base
  app_localizations_en.dart         # Implementação inglês
  app_localizations_pt.dart         # Implementação português
```

## Padrão de Nomenclatura

### ARB Keys (Fonte da Verdade)
Formato: `feature_component_action`
- Exemplo: `todo_item_delete_button`
- Uso: Identificador imutável usado em todos os sistemas
- **NUNCA deve mudar após criação**

### ARB Values (Traduções)
- Exemplo PT: `"Excluir tarefa"`
- Exemplo EN: `"Delete task"`
- Uso: Texto visível ao usuário
- **PODE mudar sem impacto nos testes**

### Constantes Dart Geradas
A partir da key `todo_item_delete_button`:
```dart
class AppSemantics {
  static const String todoItemDeleteButton = 'todo_item_delete_button';
}
```

### Variáveis Maestro Geradas
A partir da mesma key:
```yaml
env:
  TODO_ITEM_DELETE_BUTTON: todo_item_delete_button
```

### Uso nos Widgets
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';

// No widget:
final l10n = AppLocalizations.of(context);

Semantics(
  identifier: AppSemantics.todoItemDeleteButton,
  label: l10n.todoItemDeleteButton,  // Getter gerado pelo Flutter
  child: IconButton(...),
)
```

**Nota**: O Flutter gera getters camelCase a partir das keys snake_case.
- Key ARB: `todo_item_delete_button`
- Getter gerado: `l10n.todoItemDeleteButton`

### Uso no Maestro
```yaml
- tapOn:
    id: ${TODO_ITEM_DELETE_BUTTON}
```

## Fluxo de Geração (Build Pipeline)

### Passo a Passo

1. **Desenvolvedor edita** `lib/l10n/app_en.arb` (arquivo template) com novas keys/values
2. **Desenvolvedor edita** `lib/l10n/app_pt.arb` (e outros idiomas) com traduções
3. **Script customizado** `tools/generate_semantics.dart`:
   - Lê todas as keys do arquivo template ARB (`app_en.arb`)
   - Gera `lib/core/semantics/app_semantics.dart` (constantes para Semantics)
   - Gera `maestro_flows/constants.yaml` (variáveis para Maestro)
4. **Flutter gen-l10n** (automático ou manual):
   - Lê `l10n.yaml` e todos os ARB files
   - Gera classes em `.dart_tool/flutter_gen/gen_l10n/`
   - Cria `AppLocalizations` abstrata e implementações por locale
5. **Widgets** usam:
   - `AppSemantics.constantName` para identificadores
   - `AppLocalizations.of(context).getterName` para textos traduzidos
6. **Maestro flows** usam:
   - Variáveis de `constants.yaml`: `${CONSTANT_NAME}`

### Comandos de Geração

```bash
# 1. Gerar constantes Semantics + Maestro (script customizado)
dart run tools/generate_semantics.dart

# 2. Gerar AppLocalizations (Flutter nativo - roda automaticamente no flutter run)
flutter gen-l10n

# Ou gerar tudo e rodar:
dart run tools/generate_semantics.dart && flutter gen-l10n && flutter run
```

### Configuração l10n.yaml (raiz do projeto)

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### Configuração pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true  # Ativa geração automática
```

## Exemplo Completo ARB → Dart → Maestro

### 1. Arquivo ARB (app_en.arb)
```json
{
  "@@locale": "en",
  "todo_item_delete_button": "Delete task",
  "@todo_item_delete_button": {
    "description": "Label for delete button in todo item"
  },
  "todo_item_checkbox": "Mark as complete",
  "todo_add_button": "Add"
}
```

### 2. Código Gerado pelo Flutter (app_localizations_en.dart)
```dart
class AppLocalizationsEn extends AppLocalizations {
  @override
  String get todoItemDeleteButton => 'Delete task';

  @override
  String get todoItemCheckbox => 'Mark as complete';

  @override
  String get todoAddButton => 'Add';
}
```

### 3. Constantes Geradas pelo Script (app_semantics.dart)
```dart
class AppSemantics {
  static const String todoItemDeleteButton = 'todo_item_delete_button';
  static const String todoItemCheckbox = 'todo_item_checkbox';
  static const String todoAddButton = 'todo_add_button';
}
```

### 4. Variáveis Geradas pelo Script (constants.yaml)
```yaml
env:
  TODO_ITEM_DELETE_BUTTON: todo_item_delete_button
  TODO_ITEM_CHECKBOX: todo_item_checkbox
  TODO_ADD_BUTTON: todo_add_button
```

### 5. Uso no Widget
```dart
Semantics(
  identifier: AppSemantics.todoItemDeleteButton,  // 'todo_item_delete_button'
  label: l10n.todoItemDeleteButton,               // 'Delete task' ou 'Excluir'
  child: IconButton(onPressed: onDelete, icon: Icon(Icons.delete)),
)
```

### 6. Uso no Maestro Flow
```yaml
- tapOn:
    id: ${TODO_ITEM_DELETE_BUTTON}  # Expande para 'todo_item_delete_button'
```

## Critérios de Aceitação

1. Todas as strings visíveis devem ser acessadas via `AppLocalizations.of(context).getterName`
2. Todos os identificadores Semantics devem usar `AppSemantics.constantName`, não strings literais
3. Identificadores devem ser baseados em keys ARB (snake_case), não em valores traduzidos
4. Testes E2E com Maestro devem usar apenas variáveis do `constants.yaml`
5. Nenhuma string literal deve ser usada para textos ou identificadores
6. Alterações nas traduções (valores ARB) não devem quebrar os testes E2E
7. A aplicação deve funcionar corretamente em português e inglês
8. O código deve compilar com type-safety total
9. Flutter deve gerar getters camelCase a partir das keys snake_case
10. Script customizado deve gerar constantes snake_case preservando as keys originais
11. **ARB é a única fonte - modificar apenas ARB, nunca as constantes geradas**
12. Código gerado pelo Flutter vai para `.dart_tool/` (não commitar)
13. Código gerado pelo script customizado vai para `lib/core/semantics/` (commitar)
