# Sistema de Internacionalização + Semantics + Maestro

Sistema completo de internacionalização type-safe integrado com testes E2E Maestro.

## Visão Geral

Este projeto implementa uma arquitetura onde **ARB keys são a única fonte da verdade** para todos os identificadores na aplicação.

```
┌─────────────────────────────────────────────────────────────┐
│                    app_en.arb (Template)                    │
│                         ARB Keys                             │
│              (Única Fonte da Verdade)                       │
└──────────────┬──────────────┬───────────────┬───────────────┘
               │              │               │
               ▼              ▼               ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │   Flutter    │ │   Python     │ │   Python     │
    │  gen-l10n    │ │   Script     │ │   Script     │
    └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
           │                │                │
           ▼                ▼                ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │AppLocalizations│ │AppSemantics  │ │constants.yaml│
    │  (getters)   │ │ (constantes) │ │ (variáveis)  │
    └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
           │                │                │
           ▼                ▼                ▼
    ┌──────────────────────────────────────────┐
    │            Widgets Flutter               │
    └──────────────────────────────────────────┘
                           │
                           ▼
                  ┌──────────────┐
                  │ Testes E2E   │
                  │   Maestro    │
                  └──────────────┘
```

## Arquivos Principais

### Fonte da Verdade
- `lib/l10n/app_en.arb` - Arquivo template com todas as keys
- `lib/l10n/app_pt.arb` - Traduções em português

### Gerados Automaticamente (NÃO EDITAR)
- `lib/core/semantics/app_semantics.dart` - Constantes Dart
- `maestro_flows/constants.yaml` - Variáveis Maestro
- `lib/l10n/app_localizations*.dart` - Classes de localização

### Scripts e Configuração
- `tools/generate_semantics.py` - Gerador Python
- `l10n.yaml` - Configuração Flutter i18n
- `pubspec.yaml` - Dependências

## Quick Start

### 1. Instalar Dependências

```bash
flutter pub get
```

### 2. Gerar Código

```bash
# Gerar AppSemantics + constants.yaml
python3 tools/generate_semantics.py

# Gerar AppLocalizations
flutter gen-l10n

# Ou gerar tudo de uma vez:
python3 tools/generate_semantics.py && flutter gen-l10n
```

### 3. Usar no Código

Veja `example_widget.dart` para exemplos completos.

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';

// No widget:
final l10n = AppLocalizations.of(context)!;

Semantics(
  identifier: AppSemantics.todoAddButton,
  label: l10n.todo_add_button,
  button: true,
  child: ElevatedButton(
    onPressed: onAdd,
    child: Text(l10n.todo_add_button),
  ),
)
```

### 4. Usar no Maestro

```yaml
# maestro_flows/my_flow.yaml
appId: com.example.maestro_test

env:
  extends:
    - constants.yaml

---
- tapOn:
    id: ${TODO_ADD_BUTTON}
```

## Estrutura de Arquivos

```
maestro_test/
├── lib/
│   ├── l10n/
│   │   ├── app_en.arb                    ← EDITAR AQUI
│   │   ├── app_pt.arb                    ← EDITAR AQUI
│   │   ├── app_localizations.dart        (gerado)
│   │   ├── app_localizations_en.dart     (gerado)
│   │   └── app_localizations_pt.dart     (gerado)
│   └── core/
│       └── semantics/
│           └── app_semantics.dart        (gerado)
├── tools/
│   └── generate_semantics.py             (script)
├── maestro_flows/
│   ├── constants.yaml                    (gerado)
│   └── Flow.yaml
├── l10n.yaml                              (config)
├── pubspec.yaml
├── USAGE_GUIDE.md                         (guia detalhado)
├── example_widget.dart                    (exemplos)
└── README_I18N.md                         (este arquivo)
```

## Fluxo de Trabalho Completo

### Adicionar Nova Funcionalidade

1. **Editar ARB template** (`lib/l10n/app_en.arb`):

```json
{
  "new_feature_button": "Click Me",
  "@new_feature_button": {
    "description": "Button for new feature"
  }
}
```

2. **Adicionar tradução** (`lib/l10n/app_pt.arb`):

```json
{
  "new_feature_button": "Clique Aqui"
}
```

3. **Gerar código**:

```bash
python3 tools/generate_semantics.py && flutter gen-l10n
```

4. **Usar no widget**:

```dart
Semantics(
  identifier: AppSemantics.newFeatureButton,
  label: l10n.new_feature_button,
  child: ElevatedButton(
    onPressed: onPress,
    child: Text(l10n.new_feature_button),
  ),
)
```

5. **Usar no Maestro**:

```yaml
- tapOn:
    id: ${NEW_FEATURE_BUTTON}
```

## Mapeamento de Nomenclatura

| Localização | Formato | Exemplo |
|-------------|---------|---------|
| ARB Key | `snake_case` | `todo_add_button` |
| AppSemantics | `camelCase` | `AppSemantics.todoAddButton` |
| AppLocalizations | `snake_case` (getter) | `l10n.todo_add_button` |
| Maestro Variable | `UPPER_SNAKE_CASE` | `${TODO_ADD_BUTTON}` |

## Identificadores Disponíveis

Gerados automaticamente a partir de `app_en.arb`:

```dart
// Aplicação
AppSemantics.appTitle

// Lista de Tarefas
AppSemantics.todoListTitle
AppSemantics.todoListEmptyMessage
AppSemantics.todoLoadingIndicator
AppSemantics.todoErrorMessage

// Item de Tarefa
AppSemantics.todoItemCheckbox
AppSemantics.todoItemCheckboxCompleted
AppSemantics.todoItemDeleteButton
AppSemantics.todoItemEditButton
AppSemantics.todoItemTitle
AppSemantics.todoItemSubtitle

// Adicionar Tarefa
AppSemantics.todoAddInput
AppSemantics.todoAddButton
AppSemantics.todoAddField
```

## Regras Importantes

### ✅ O QUE FAZER

- ✅ Editar apenas arquivos ARB (`app_en.arb`, `app_pt.arb`)
- ✅ Usar `AppSemantics` para identificadores Semantics
- ✅ Usar `AppLocalizations.of(context)` para textos
- ✅ Regenerar após editar ARB
- ✅ Manter keys ARB estáveis (nunca mudar)
- ✅ Adicionar descrições `@key` nos ARBs

### ❌ O QUE NÃO FAZER

- ❌ Editar `app_semantics.dart` manualmente
- ❌ Editar `constants.yaml` manualmente
- ❌ Editar `app_localizations*.dart` manualmente
- ❌ Usar strings literais para textos
- ❌ Usar strings literais para identificadores
- ❌ Mudar ARB keys existentes
- ❌ Commitar arquivos `.dart_tool/`

## Benefícios

### 1. Type-Safety Total
```dart
// ✅ Correto - IDE detecta erro
AppSemantics.todoAddButtonn  // Erro de compilação

// ❌ Errado - Só falha em runtime
Semantics(identifier: 'todo_add_buttonn')  // Erro só no teste
```

### 2. Testes Estáveis
```dart
// Mudar tradução "Add" → "Add Task" não quebra testes
// porque Maestro usa a key, não o valor
```

### 3. Autocomplete e Refatoração
- IDE sugere todas as constantes
- Rename funciona em todo projeto
- Find References mostra todos os usos

### 4. Single Source of Truth
- ARB é a única fonte
- Impossível ter inconsistências
- Fácil adicionar novos idiomas

## Comandos Úteis

```bash
# Gerar tudo
python3 tools/generate_semantics.py && flutter gen-l10n

# Ver strings geradas
cat lib/core/semantics/app_semantics.dart

# Ver variáveis Maestro
cat maestro_flows/constants.yaml

# Rodar app
flutter run

# Rodar Maestro flow
maestro test maestro_flows/Flow.yaml
```

## Troubleshooting

### AppLocalizations não encontrado

```bash
flutter clean
flutter pub get
flutter gen-l10n
```

### AppSemantics não encontrado

```bash
python3 tools/generate_semantics.py
```

### Maestro não encontra elemento

1. Verificar se widget tem `Semantics` com `identifier`
2. Verificar se usa `AppSemantics.constantName`
3. Verificar se Maestro usa `${CONSTANT_NAME}`
4. Regenerar constants.yaml se adicionou nova key

### Erro no Python script

```bash
# Verificar se Python 3 está instalado
python3 --version

# Verificar se ARB template existe
ls -la lib/l10n/app_en.arb
```

## Recursos Adicionais

- `USAGE_GUIDE.md` - Guia de uso detalhado com exemplos
- `example_widget.dart` - Widgets de exemplo completos
- `mds/i10n_and_semantics.md` - Especificação técnica completa

## Suporte a Novos Idiomas

Para adicionar espanhol:

1. Criar `lib/l10n/app_es.arb`:

```json
{
  "@@locale": "es",
  "todo_add_button": "Agregar"
}
```

2. Regenerar:

```bash
flutter gen-l10n
```

3. Flutter automaticamente detecta e adiciona aos `supportedLocales`

## Contribuindo

Ao adicionar novas features:

1. Adicione keys no ARB primeiro
2. Rode os geradores
3. Use as constantes geradas
4. Teste com Maestro usando as variáveis

Nunca edite arquivos gerados diretamente!
