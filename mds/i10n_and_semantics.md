# Internacionalização e Semântica dos Componentes

## Objetivo

1. Suporte a múltiplos idiomas através de arquivos ARB com acesso type-safe
2. Testes E2E robustos usando Maestro com identificadores estáveis baseados em keys
3. Manutenção consistente de identificadores através de código gerado

## Requisitos Técnicos

### Internacionalização (i18n)

- Utilizar o sistema de ARB (Application Resource Bundle) do Flutter
- Implementar geração de código para as strings traduzidas via `gen-l10n`
- Criar arquivos ARB para português (default) e inglês
- Utilizar classes geradas para acesso type-safe às traduções (evitar strings literais)
- Definir keys significativas e estáveis nos ARBs para uso como identificadores
- Evitar uso de strings hardcoded para textos visíveis ao usuário

### Semantics e Identificadores Type-Safe

- Criar classe de constantes gerada para acessar os identificadores Semantics
- Utilizar as keys dos ARBs (não os valores traduzidos) como base para identificadores
- Implementar identificadores constantes e estáveis para testes E2E com Maestro
- Garantir que cada elemento interativo tenha um identificador único e type-safe
- Manter keys ARB estáveis mesmo quando as traduções mudam
- Adicionar Semantics em todos os componentes interativos usando as constantes geradas

## Componentes a Serem Atualizados

- TodoCheckbox: Adicionar semantics para estado de conclusão
- TodoDeleteButton: Adicionar semantics para ação de exclusão
- TodoEditButton: Adicionar semantics para ação de edição
- TodoTitle: Adicionar semantics para título e estado
- TodoSubtitle: Adicionar semantics para data de criação
- TodoItem: Coordenar semantics dos subcomponentes

## Estrutura de Arquivos

```yaml
lib/
  l10n/
    app_en.arb     # Traduções em inglês
    app_pt.arb     # Traduções em português
    l10n.yaml      # Configuração do gerador
```

## Padrão de Nomenclatura

- Keys ARB (base para identificadores): `feature_component_action`
  - Exemplo: `todo_item_delete_button`
  - Uso: Base para gerar constantes de Semantics
- Traduções (valores ARB): `featureComponentText`
  - Exemplo: `todoDeleteButtonLabel: "Excluir tarefa"`
  - Uso: Texto visível que pode mudar sem afetar testes
- Constantes Geradas:
  - Semantics: `TodoSemantics.deleteButton`
  - Traduções: `AppLocalizations.of(context).todoDeleteButtonLabel`

## Critérios de Aceitação

1. Todas as strings visíveis devem ser acessadas via `AppLocalizations` gerado
2. Todos os identificadores Semantics devem usar constantes geradas, não strings
3. Identificadores devem ser baseados em keys ARB, não em valores traduzidos
4. Testes E2E com Maestro devem usar apenas identificadores das constantes geradas
5. Nenhuma string literal deve ser usada para textos ou identificadores
6. Alterações nas traduções não devem quebrar os testes E2E
7. A aplicação deve funcionar corretamente em português e inglês
8. O código deve compilar se todas as traduções forem removidas (type-safety)
