# Guia de Uso: i18n + Semantics + Maestro

Este guia mostra como usar o sistema de internacionalização com identificadores type-safe para Semantics e testes Maestro.

## Arquitetura

```
ARB Keys (app_en.arb)
    ↓
    ├─→ Flutter gen-l10n → AppLocalizations (getters snake_case)
    ├─→ Python Script → AppSemantics (constantes camelCase)
    └─→ Python Script → Maestro constants.yaml (variáveis UPPER_SNAKE_CASE)
```

## Fluxo de Trabalho

### 1. Adicionar Nova String/Identificador

Edite **apenas** `lib/l10n/app_en.arb`:

```json
{
  "@@locale": "en",
  "new_button_label": "Click Here",
  "@new_button_label": {
    "description": "Label for the new button"
  }
}
```

Adicione a tradução em `lib/l10n/app_pt.arb`:

```json
{
  "@@locale": "pt",
  "new_button_label": "Clique Aqui"
}
```

### 2. Gerar Código

```bash
# Gerar AppSemantics + constants.yaml
python3 tools/generate_semantics.py

# Gerar AppLocalizations
flutter gen-l10n
```

### 3. Usar no Widget

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      identifier: AppSemantics.newButtonLabel,  // 'new_button_label'
      label: l10n.new_button_label,              // 'Click Here' ou 'Clique Aqui'
      button: true,
      child: ElevatedButton(
        onPressed: () {},
        child: Text(l10n.new_button_label),
      ),
    );
  }
}
```

### 4. Usar no Maestro

```yaml
# maestro_flows/my_flow.yaml
appId: com.example.maestro_test
---
- launchApp
- tapOn:
    id: ${NEW_BUTTON_LABEL}  # Expande para 'new_button_label'
- assertVisible:
    id: ${NEW_BUTTON_LABEL}
```

## Exemplos Práticos

### Exemplo 1: Todo Checkbox

**ARB (app_en.arb)**
```json
{
  "todo_item_checkbox": "Mark task as complete"
}
```

**Dart (gerado automaticamente)**
```dart
// lib/core/semantics/app_semantics.dart
class AppSemantics {
  static const String todoItemCheckbox = 'todo_item_checkbox';
}

// lib/l10n/app_localizations_en.dart
class AppLocalizationsEn extends AppLocalizations {
  @override
  String get todo_item_checkbox => 'Mark task as complete';
}
```

**Widget**
```dart
Semantics(
  identifier: AppSemantics.todoItemCheckbox,
  label: l10n.todo_item_checkbox,
  checked: todo.isCompleted,
  child: Checkbox(
    value: todo.isCompleted,
    onChanged: onToggle,
  ),
)
```

**Maestro (constants.yaml gerado)**
```yaml
env:
  TODO_ITEM_CHECKBOX: todo_item_checkbox
```

**Maestro Flow**
```yaml
- tapOn:
    id: ${TODO_ITEM_CHECKBOX}
```

### Exemplo 2: String com Parâmetro

**ARB**
```json
{
  "todo_item_subtitle": "Created on {date}",
  "@todo_item_subtitle": {
    "description": "Subtitle showing task creation date",
    "placeholders": {
      "date": {
        "type": "String",
        "example": "2024-01-15"
      }
    }
  }
}
```

**Widget**
```dart
Semantics(
  identifier: AppSemantics.todoItemSubtitle,
  label: l10n.todo_item_subtitle(formattedDate),  // Método com parâmetro
  child: Text(l10n.todo_item_subtitle(formattedDate)),
)
```

## Mapeamento de Nomenclatura

| ARB Key | AppSemantics | AppLocalizations | Maestro Var |
|---------|--------------|------------------|-------------|
| `todo_item_checkbox` | `AppSemantics.todoItemCheckbox` | `l10n.todo_item_checkbox` | `${TODO_ITEM_CHECKBOX}` |
| `todo_add_button` | `AppSemantics.todoAddButton` | `l10n.todo_add_button` | `${TODO_ADD_BUTTON}` |
| `app_title` | `AppSemantics.appTitle` | `l10n.app_title` | `${APP_TITLE}` |

## Regras Importantes

1. **NUNCA modifique arquivos gerados**:
   - ❌ `lib/core/semantics/app_semantics.dart`
   - ❌ `maestro_flows/constants.yaml`
   - ❌ `lib/l10n/app_localizations*.dart`

2. **Sempre edite apenas os ARB files**:
   - ✅ `lib/l10n/app_en.arb`
   - ✅ `lib/l10n/app_pt.arb`

3. **ARB keys NUNCA mudam** - apenas valores (traduções)

4. **Regenerar após editar ARB**:
   ```bash
   python3 tools/generate_semantics.py && flutter gen-l10n
   ```

## Configuração no main.dart

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Configuração i18n
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      home: HomePage(),
    );
  }
}
```

## Troubleshooting

### Erro: "AppLocalizations not found"
```bash
flutter gen-l10n
flutter pub get
```

### Erro: "AppSemantics not found"
```bash
python3 tools/generate_semantics.py
```

### Maestro não encontra elemento
Verifique:
1. Widget tem `Semantics` com `identifier`
2. `identifier` usa `AppSemantics.constantName`
3. Maestro flow usa `${CONSTANT_NAME}` do `constants.yaml`

## Benefícios

1. **Type-Safety Total**: Erros de digitação detectados em tempo de compilação
2. **Testes Estáveis**: Mudar tradução não quebra testes
3. **Autocomplete**: IDE sugere todas as constantes disponíveis
4. **Single Source of Truth**: ARB é a única fonte
5. **Refatoração Segura**: Rename funciona em todo o projeto
