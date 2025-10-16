# Guia Maestro - Testes E2E para Flutter

## 📋 Índice

- [O que é Maestro](#o-que-é-maestro)
- [Instalação](#instalação)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Comandos Básicos](#comandos-básicos)
- [Configuração de Variáveis](#configuração-de-variáveis)
- [Comandos Úteis](#comandos-úteis)
- [Exemplos Práticos](#exemplos-práticos)
- [Debugging](#debugging)
- [Dicas e Boas Práticas](#dicas-e-boas-práticas)

## O que é Maestro

Maestro é um framework de testes E2E (end-to-end) para aplicativos móveis que oferece:

- ✅ Sintaxe declarativa em YAML
- ✅ Tolerância a flakiness
- ✅ Iteração rápida
- ✅ Suporte para Android, iOS e Web
- ✅ Fácil integração com CI/CD

## Instalação

### macOS

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

### Windows (WSL2)

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

### Verificar instalação

```bash
maestro --version
```

## Estrutura do Projeto

```
maestro_test/
├── .env                          # Variáveis de ambiente
├── maestro_flows/                # Pasta com os flows de teste
│   ├── Flow.yaml                 # Flow principal
│   └── constants.yaml            # Constantes (opcional)
└── .maestro/                     # Configurações do workspace
    └── config.yaml               # Configuração global
```

## Comandos Básicos

### Rodar teste

```bash
maestro test maestro_flows/Flow.yaml
```

### Rodar com variáveis de ambiente

```bash
set -a && source .env && set +a && maestro test maestro_flows/Flow.yaml
```

### Rodar passando variáveis via CLI

```bash
maestro test -e USERNAME=user@example.com -e PASSWORD=123 maestro_flows/Flow.yaml
```

### Ver hierarquia da UI

```bash
maestro hierarchy
```

### Rodar no Maestro Cloud

```bash
maestro cloud --api-key <API_KEY> --project-id <PROJECT_ID> app.apk maestro_flows/
```

## Configuração de Variáveis

### Opção 1: Arquivo .env (Recomendado)

**Arquivo `.env`:**

```bash
MAESTRO_TODO_ADD_INPUT=todo_add_input
MAESTRO_TODO_ADD_BUTTON=todo_add_button
MAESTRO_TODO_ITEM_TITLE=todo_item_title
```

**Flow.yaml:**

```yaml
appId: com.example.maestro_test
---
- launchApp
- tapOn:
    id: ${MAESTRO_TODO_ADD_INPUT}
```

**Comando para rodar:**

```bash
set -a && source .env && set +a && maestro test maestro_flows/Flow.yaml
```

### Opção 2: Variáveis inline no Flow

```yaml
appId: com.example.maestro_test
env:
    TODO_ADD_INPUT: todo_add_input
    TODO_ADD_BUTTON: todo_add_button
---
- launchApp
- tapOn:
    id: ${TODO_ADD_INPUT}
```

### Opção 3: Via linha de comando

```bash
maestro test \
  -e TODO_ADD_INPUT=todo_add_input \
  -e TODO_ADD_BUTTON=todo_add_button \
  maestro_flows/Flow.yaml
```

## Comandos Úteis

### Comandos de Interação

#### launchApp

```yaml
- launchApp:
    appId: "com.example.maestro_test"
    clearState: true  # Limpa dados do app antes de iniciar
```

#### tapOn

```yaml
# Por ID
- tapOn:
    id: "button_id"

# Por texto
- tapOn: "Login"

# Por coordenadas
- tapOn:
    point: "50%,50%"
```

#### inputText

```yaml
- inputText: "Texto para digitar"

# Com campo específico
- tapOn:
    id: "input_field"
- inputText: "Texto"
```

#### assertVisible

```yaml
# Por ID
- assertVisible:
    id: "element_id"

# Por texto
- assertVisible: "Texto esperado"
```

#### assertNotVisible

```yaml
- assertNotVisible:
    id: "element_id"
```

#### swipe

```yaml
# Swipe para cima
- swipe:
    direction: UP

# Swipe com mais controle
- swipe:
    start: 50%,80%
    end: 50%,20%
```

#### scroll

```yaml
- scroll
```

#### scrollUntilVisible

```yaml
- scrollUntilVisible:
    element:
      id: "item_id"
```

#### takeScreenshot

```yaml
- takeScreenshot: screenshot_name
```

#### stopApp

```yaml
- stopApp:
    appId: "com.example.maestro_test"
```

### Comandos Condicionais

#### runFlow com condições

```yaml
# Executar se elemento visível
- runFlow:
    when:
      visible: "Some Text"
    file: subflow.yaml

# Executar por plataforma
- runFlow:
    when:
      platform: Android
    file: android_flow.yaml

# JavaScript condicional
- runFlow:
    when:
      true: ${MY_PARAMETER == 'Something'}
    file: subflow.yaml
```

### Comandos JavaScript

#### evalScript

```yaml
- evalScript: ${output.myVar = 'Hello World'}
- inputText: ${output.myVar}
```

#### runScript

```yaml
- runScript: myScript.js
```

### Comandos de Fluxo

#### runFlow

```yaml
# Executar outro flow
- runFlow: anotherFlow.yaml

# Com variáveis
- runFlow:
    file: subflow.yaml
    env:
      MY_PARAM: "123"

# Inline
- runFlow:
    commands:
      - tapOn: "Button"
      - inputText: "Text"
```

## Exemplos Práticos

### Exemplo 1: Login Flow

```yaml
appId: com.example.app
env:
    USERNAME: user@example.com
    PASSWORD: password123
---
- launchApp:
    clearState: true

# Fazer login
- tapOn:
    id: "email_input"
- inputText: ${USERNAME}

- tapOn:
    id: "password_input"
- inputText: ${PASSWORD}

- tapOn:
    id: "login_button"

# Verificar sucesso
- assertVisible:
    id: "home_screen"
```

### Exemplo 2: Todo App (Atual)

```yaml
appId: com.example.maestro_test
---
- launchApp:
    clearState: true

# Adicionar nova tarefa
- tapOn:
    id: ${MAESTRO_TODO_ADD_INPUT}
- inputText: "Test task from Maestro"
- tapOn:
    id: ${MAESTRO_TODO_ADD_BUTTON}

# Verificar que foi adicionada
- assertVisible:
    id: ${MAESTRO_TODO_ITEM_TITLE}

# Marcar como completa
- tapOn:
    id: ${MAESTRO_TODO_ITEM_CHECKBOX}

# Deletar
- tapOn:
    id: ${MAESTRO_TODO_ITEM_DELETE_BUTTON}
```

### Exemplo 3: Flow com múltiplas plataformas

```yaml
appId: com.example.app
---
- launchApp

# Android specific
- runFlow:
    when:
      platform: Android
    commands:
      - tapOn: "Android Menu"

# iOS specific
- runFlow:
    when:
      platform: iOS
    commands:
      - tapOn: "iOS Menu"

# Comum para ambos
- tapOn: "Settings"
```

### Exemplo 4: Scroll e busca

```yaml
appId: com.example.app
---
- launchApp

# Scroll até encontrar elemento
- scrollUntilVisible:
    element:
      id: "item_100"
    direction: DOWN

- tapOn:
    id: "item_100"

# Verificar resultado
- assertVisible: "Item Details"
```

## Debugging

### Ver logs de debug

```bash
maestro test --debug-output /path/to/logs maestro_flows/Flow.yaml
```

### Configurar diretório de output

```bash
maestro test --test-output-dir=test_output maestro_flows/Flow.yaml
```

### Ver hierarquia da UI em tempo real

```bash
maestro hierarchy
```

### Screenshots automáticos

Os screenshots são salvos automaticamente em falhas em:

```
~/.maestro/tests/<timestamp>/
```

## Dicas e Boas Práticas

### 1. Use IDs semânticos no Flutter

```dart
TextField(
  key: Key('todo_add_input'),
  decoration: InputDecoration(hintText: 'Nova tarefa'),
)
```

### 2. Organize flows em arquivos separados

```
maestro_flows/
├── login.yaml
├── signup.yaml
├── todo_create.yaml
└── todo_delete.yaml
```

### 3. Use runFlow para reutilizar

```yaml
# main_flow.yaml
---
- runFlow: login.yaml
- runFlow: todo_create.yaml
- runFlow: todo_delete.yaml
```

### 4. Configure timeout quando necessário

```yaml
- tapOn:
    id: "slow_button"
    timeout: 10000  # 10 segundos
```

### 5. Use tags para organizar testes

```yaml
appId: com.example.app
tags:
  - smoke
  - login
---
- launchApp
```

Rodar apenas testes com tag específica:

```bash
maestro test --include-tags smoke maestro_flows/
```

### 6. Adicione permissões no AndroidManifest.xml

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <application>
        ...
    </application>
</manifest>
```

### 7. Use variáveis de ambiente para dados sensíveis

```bash
# .env
MAESTRO_USERNAME=user@example.com
MAESTRO_PASSWORD=secret123
```

Nunca commite o arquivo `.env` no Git:

```bash
# .gitignore
.env
```

### 8. Espere por elementos antes de interagir

```yaml
# Maestro faz isso automaticamente, mas você pode configurar
- tapOn:
    id: "button"
    waitToSettleTimeoutMs: 5000
```

## Integração CI/CD

### GitHub Actions

```yaml
- name: Run Maestro Tests
  run: |
    curl -Ls "https://get.maestro.mobile.dev" | bash
    export PATH="$PATH":"$HOME/.maestro/bin"
    set -a && source .env && set +a
    maestro test maestro_flows/
```

### CircleCI

```yaml
- run:
    name: Run Maestro Tests
    command: |
      curl -Ls "https://get.maestro.mobile.dev" | bash
      export PATH="$PATH":"$HOME/.maestro/bin"
      maestro test maestro_flows/
```

## Recursos Adicionais

- [Documentação Oficial](https://maestro.mobile.dev)
- [GitHub](https://github.com/mobile-dev-inc/maestro)
- [Discord Community](https://discord.gg/maestro)

## Troubleshooting Comum

### Problema: "Unable to launch app"

**Solução:**

1. Verifique se o app está instalado
2. Adicione permissão INTERNET no AndroidManifest.xml
3. Tente sem `clearState: true`

### Problema: "Element not found"

**Solução:**

1. Use `maestro hierarchy` para ver os IDs disponíveis
2. Verifique se o ID está correto no código Flutter
3. Adicione timeout maior se o elemento demora para aparecer

### Problema: Variáveis não estão funcionando

**Solução:**

1. Use prefixo `MAESTRO_` para variáveis de ambiente
2. Carregue o `.env` corretamente: `set -a && source .env && set +a`
3. Verifique a sintaxe: `${VARIABLE_NAME}`
