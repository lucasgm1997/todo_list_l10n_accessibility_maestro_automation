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
- Implementar geração de código para as strings traduzidas via `gen-l10n`
- Criar arquivos ARB para português (default) e inglês
- Utilizar classes geradas para acesso type-safe às traduções (evitar strings literais)
- Definir keys significativas e estáveis nos ARBs para uso como identificadores
- Evitar uso de strings hardcoded para textos visíveis ao usuário
- **ARB keys NUNCA devem mudar** - apenas valores (traduções)

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
    app_en.arb                      # Traduções em inglês
    app_pt.arb                      # Traduções em português (FONTE DA VERDADE)
    l10n.yaml                       # Configuração do gen-l10n
  core/
    semantics/
      app_semantics.dart            # Constantes geradas a partir do ARB
tools/
  generate_semantics.dart           # Script de geração das constantes
maestro_flows/
  constants.yaml                    # Variáveis para Maestro (mesmas keys do ARB)
  flows/
    add_todo.yaml                   # Flows usando variáveis
    delete_todo.yaml
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
Semantics(
  identifier: AppSemantics.todoItemDeleteButton,
  label: AppLocalizations.of(context).todo_item_delete_button,
  child: IconButton(...),
)
```

### Uso no Maestro
```yaml
- tapOn:
    id: ${TODO_ITEM_DELETE_BUTTON}
```

## Fluxo de Geração (Build Pipeline)

1. **Desenvolvedor cria/edita** `lib/l10n/app_pt.arb` com novas keys
2. **Script automático** `tools/generate_semantics.dart`:
   - Lê todas as keys do `app_pt.arb`
   - Gera `lib/core/semantics/app_semantics.dart` com constantes Dart
   - Gera `maestro_flows/constants.yaml` com variáveis de ambiente
3. **Flutter gen-l10n** (nativo) gera `AppLocalizations`
4. **Widgets** usam `AppSemantics` + `AppLocalizations`
5. **Maestro flows** usam variáveis do `constants.yaml`

### Comando de Geração
```bash
# Gera semantics e constantes do Maestro
dart run tools/generate_semantics.dart

# Gera AppLocalizations (Flutter nativo)
flutter gen-l10n
```

## Critérios de Aceitação

1. Todas as strings visíveis devem ser acessadas via `AppLocalizations` gerado
2. Todos os identificadores Semantics devem usar constantes de `AppSemantics`, não strings literais
3. Identificadores devem ser baseados em keys ARB, não em valores traduzidos
4. Testes E2E com Maestro devem usar apenas variáveis do `constants.yaml`
5. Nenhuma string literal deve ser usada para textos ou identificadores
6. Alterações nas traduções (valores ARB) não devem quebrar os testes E2E
7. A aplicação deve funcionar corretamente em português e inglês
8. O código deve compilar com type-safety total
9. **Script de geração deve rodar automaticamente antes do build**
10. **Adicionar key nova no ARB deve refletir automaticamente em Dart e Maestro**
11. **ARB é a única fonte - modificar apenas ARB, nunca as constantes geradas**
