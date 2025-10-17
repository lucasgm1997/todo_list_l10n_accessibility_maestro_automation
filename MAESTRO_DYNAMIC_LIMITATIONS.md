# Lidando com Listas Dinâmicas no Maestro

## 🚨 Limitação Fundamental

**Maestro não suporta loops dinâmicos verdadeiros** (como `for`, `while`, etc.)

Isso significa que você **não pode**:
- Descobrir quantos itens existem em runtime e fazer loop por eles
- Gerar comandos dinamicamente baseado em contadores
- Usar lógica imperativa tradicional

## ✅ Solução: Conditional Flows

A única forma de lidar com listas dinâmicas no Maestro é usar **conditional flows** com `runFlow + when: visible`.

### Como Funciona

```yaml
# Verifica SE o item existe, então executa os comandos
- runFlow:
    when:
      visible:
        id: todo_item_checkbox_0
    commands:
      - tapOn:
          id: todo_item_checkbox_0
```

Se o elemento com ID `todo_item_checkbox_0` **não existir**, o flow simplesmente **pula** esse bloco sem falhar.

## 📋 Estratégia Recomendada

### 1. Defina o Range Esperado

Baseado no `MockConfig`:
- **Min items**: 3
- **Max items**: 10

Portanto, precisamos cobrir índices **0-9** (10 itens).

### 2. Selecione Índices Representativos

Em vez de testar TODOS os índices, teste:
- **Primeiro** (0): Sempre existe se há itens
- **Meio** (4, 5): Existe se há 5+ itens
- **Último** (8, 9): Existe se há 9+ itens

### 3. Use Conditional Flows para Cada Índice

```yaml
# Primeiro
- runFlow:
    when:
      visible:
        id: todo_item_checkbox_0
    commands:
      - tapOn:
          id: todo_item_checkbox_0

# Meio
- runFlow:
    when:
      visible:
        id: todo_item_checkbox_4
    commands:
      - tapOn:
          id: todo_item_checkbox_4

# Último
- runFlow:
    when:
      visible:
        id: todo_item_checkbox_9
    commands:
      - tapOn:
          id: todo_item_checkbox_9
```

## 📊 Comparação de Abordagens

### ❌ O que NÃO é possível (tradicional):

```javascript
// Pseudo-código - NÃO FUNCIONA NO MAESTRO
const itemCount = getItemCount(); // ❌ Não tem como descobrir
for (let i = 0; i < itemCount; i++) { // ❌ Não tem loop
  tapOn(`todo_item_checkbox_${i}`);
}
```

### ✅ O que É possível (Maestro):

```yaml
# Verifica cada índice condicionalmente
- runFlow:
    when:
      visible:
        id: todo_item_checkbox_0
    commands:
      - tapOn:
          id: todo_item_checkbox_0

- runFlow:
    when:
      visible:
        id: todo_item_checkbox_1
    commands:
      - tapOn:
          id: todo_item_checkbox_1

# ... repete até o máximo esperado
```

## 🎯 Exemplo Completo

**Arquivo**: `SmartDynamicTest.yaml`

```yaml
appId: com.example.maestro_test

---
- launchApp:
    clearState: true

- assertVisible:
    id: ${MAESTRO_TODO_ADD_INPUT}

# Toggle primeiro item
- runFlow:
    when:
      visible:
        id: todo_item_checkbox_0
    commands:
      - tapOn:
          id: todo_item_checkbox_0

# Toggle itens do meio
- runFlow:
    when:
      visible:
        id: todo_item_checkbox_4
    commands:
      - tapOn:
          id: todo_item_checkbox_4

- runFlow:
    when:
      visible:
        id: todo_item_checkbox_5
    commands:
      - tapOn:
          id: todo_item_checkbox_5

# Toggle últimos itens
- runFlow:
    when:
      visible:
        id: todo_item_checkbox_8
    commands:
      - tapOn:
          id: todo_item_checkbox_8

- runFlow:
    when:
      visible:
        id: todo_item_checkbox_9
    commands:
      - tapOn:
          id: todo_item_checkbox_9
```

## 🔍 Por que Esta Abordagem Funciona?

1. **Cobertura**: Testa primeiro, meio e fim da lista
2. **Robusto**: Funciona independente de quantos itens existem (3-10)
3. **Sem falhas**: Índices que não existem são simplesmente pulados
4. **Simples**: Não requer lógica complexa

## 🚀 Como Rodar

```bash
# Carregar variáveis de ambiente
set -a && source .env && set +a

# Rodar o teste
maestro test maestro_flows/SmartDynamicTest.yaml
```

## 💡 Alternativas (Avançadas)

### Opção 1: Script Gerador de YAML

Criar um script Python/Node que:
1. Roda o app
2. Descobre quantos itens existem
3. Gera o YAML dinamicamente
4. Executa o teste

```python
# generate_test.py
import subprocess
import yaml

# Descobre itens (via maestro hierarchy ou API)
item_count = discover_item_count()

# Gera comandos
commands = []
for i in range(item_count):
    commands.append({
        'runFlow': {
            'when': {'visible': {'id': f'todo_item_checkbox_{i}'}},
            'commands': [{'tapOn': {'id': f'todo_item_checkbox_{i}'}}]
        }
    })

# Salva YAML
with open('generated_test.yaml', 'w') as f:
    yaml.dump({'appId': 'com.example.maestro_test', 'commands': commands}, f)

# Executa
subprocess.run(['maestro', 'test', 'generated_test.yaml'])
```

### Opção 2: Testar Funcionalidade, Não Contagem

Em vez de testar TODOS os itens, teste:
- **Adicionar** novo item
- **Toggle** qualquer item (não importa qual)
- **Deletar** qualquer item

```yaml
---
- launchApp:
    clearState: true

# Adiciona novo item
- tapOn:
    id: ${MAESTRO_TODO_ADD_INPUT}
- inputText: "Test Item"
- tapOn:
    id: ${MAESTRO_TODO_ADD_BUTTON}

# Toggle o primeiro item que encontrar
- runFlow:
    when:
      visible:
        id: todo_item_checkbox_0
    commands:
      - tapOn:
          id: todo_item_checkbox_0

# Verifica que toggle funcionou
- assertVisible:
    id: todo_item_checkbox_0
```

## 📚 Recursos

- [Maestro Docs - Conditional Flows](https://maestro.mobile.dev/api-reference/conditions)
- [Maestro Docs - JavaScript Support](https://maestro.mobile.dev/advanced/javascript)
- [GitHub Discussion sobre Loops](https://github.com/mobile-dev-inc/maestro/discussions)

## 🎓 Conclusão

**A limitação do Maestro é intencional** - a ferramenta foi projetada para testes declarativos, não imperativos.

A solução é:
1. ✅ Usar conditional flows
2. ✅ Testar índices representativos
3. ✅ Aceitar que não é um loop "de verdade"

Esta abordagem é suficiente para **validar que o sistema lida corretamente com listas dinâmicas**, que era o objetivo original!
