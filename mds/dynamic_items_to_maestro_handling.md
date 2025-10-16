# Prompt: Mock de itens dinâmicos (para uso com Maestro)

## Objetivo

Gerar um mock de RemoteDataSource que produz uma lista de itens com tamanho e conteúdo randômicos/configuráveis toda vez que o app for iniciado. O propósito é permitir que testes com Maestro cubram cenários com contagens dinâmicas de botões/itens, verificando robustez contra variações no número e nos identificadores dos widgets.

## Quando usar este prompt

- Cenários de teste e2e com Maestro onde a UI contém listas/grades/coleções com número variável de elementos.
- Quando for necessário validar ações repetitivas (selecionar/deletar/editar) em itens que mudam de posição e quantidade a cada execução.

## Contrato do mock (entrada / saída)

### Entrada (parâmetros configuráveis):

- min_items (int): número mínimo de itens na lista (ex: 0).
- max_items (int): número máximo de itens na lista (ex: 50).
- seed (int | optional): semente para RNG para tornar a geração determinística quando necessário.
- locale (string | optional): idioma dos textos gerados (ex: "pt-BR", "en-US").
- title_pattern (string | optional): padrão para título, com placeholder {i} para índice (ex: "Task {i}").
- with_ids (bool): se true, o mock deve incluir um identificador estável para cada item (usado como id de acessibilidade/semântica).

### Saída (formato retornado pelo RemoteDataSource):

- Uma lista (array) de objetos JSON com a forma:

	{
		"id": "string",        // se with_ids=true: ex: "todo_item_0_ab12"
		"title": "string",
		"completed": bool
	}

## Regras de geração

- Escolher n aleatório entre min_items e max_items (incluir ambos). Se seed for fornecido, a escolha deve ser determinística.
- Para cada item i em 0..n-1:
	- "title": gerar a partir de title_pattern substituindo {i} ou, se não fornecido, usar um texto aleatório curto (no idioma locale quando possível).
	- "completed": valor booleano aleatório (50%/50%) ou controlado por um parâmetro adicional se necessário.
	- "id": se with_ids=true, gerar um id legível que combine um prefixo (ex: "todo_item"), o índice e uma pequena hash (ex: base36(seed + i) ou incremental) para evitar colisões entre execuções.

## IDs e semântica para uso com Maestro

O mock deve anexar propriedades de acessibilidade/semântica aos widgets renderizados, usando IDs estáveis quando possível. Convenção recomendada (widgets gerados):

- item container: `todo_item_container_{index}` (ex: `todo_item_container_0`)
- item title: `todo_item_title_{index}` (ex: `todo_item_title_0`)
- item checkbox: `todo_item_checkbox_{index}` (ex: `todo_item_checkbox_0`)
- item delete button: `todo_item_delete_{index}` (ex: `todo_item_delete_0`)

Observação: se with_ids=true, também inclua o campo `data-test-id` (ou similar) nos widgets com o valor do campo `id` retornado pelo mock. Isso permite que flows do Maestro usem seletores estáveis mesmo quando a ordem muda.

## Exemplos de uso com Maestro (snippet YAML)

- launchApp:
		appId: "com.example.maestro_test"
		clearState: true

# Exemplo: aguardar que exista pelo menos 1 item e apagar o primeiro
- assertExists:
		id: todo_item_title_0
- tapOn:
		id: todo_item_delete_0

# Exemplo: marcar o terceiro item (se existir)
- assertVisible:
		id: todo_item_title_2
- tapOn:
		id: todo_item_checkbox_2

## Como escrever flows robustos

- Não assuma um número fixo de itens. Use asserts condicionais:
	- `assertExists` / `assertVisible` para checar se o item existe antes de interagir.
	- Usar loops e retries no próprio flow (se a ferramenta permitir) para tentar ações em índices subsequentes até encontrar um item.
- Prefira selecionar itens por texto quando o título é previsível (ex: title_pattern com seed) ou por um `data-test-id` retornado pelo mock.
- Evite dependências em posições absolutas: se precisar testar "primeiro item", use index 0; para itens específicos, busque pelo id retornado.

## Templates de resposta esperada (JSON)

Exemplo determinístico (seed=42, min_items=3, max_items=5, with_ids=true):

```
[
	{"id": "todo_item_0_x7k", "title": "Task 0", "completed": false},
	{"id": "todo_item_1_x7l", "title": "Task 1", "completed": true},
	{"id": "todo_item_2_x7m", "title": "Task 2", "completed": false}
]
```

## Critérios de aceitação

- O mock deve respeitar os parâmetros min_items/max_items e seed.
- Quando with_ids=true, cada item deve expor um id único estável para seleção por testes.
- A aplicação deve renderizar widgets com acessibilidade/semântica baseada nesses ids (ex: data-test-id ou key/semanticsLabel).
- Flows de exemplo (acima) devem funcionar em pelo menos dois runs: um com seed definido (determinístico) e outro sem seed (aleatório).

## Checklist de testes (rápido)

- [ ] Executar app com seed fixo e verificar que a lista gerada é sempre igual.
- [ ] Executar app sem seed várias vezes e verificar variação no tamanho da lista.
- [ ] Testar flows do Maestro que: adicionar, marcar e deletar itens usando os ids gerados.
- [ ] Verificar que nenhuma exceção ocorre quando a lista é vazia (min_items=0).

## Notas e recomendações

- Quando possível, mantenha a geração de ids legível para facilitar debugging durante testes.
- Documente no código do mock a correspondência entre os ids gerados e os values que o Maestro deve usar, para evitar deriva entre implementações.

## Exemplo mínimo de implementação (pseudocódigo)

```
function generateItems(min, max, seed=null, titlePattern="Task {i}", withIds=true):
	rng = seed ? new RNG(seed) : new RNG(now())
	n = rng.intBetween(min, max)
	items = []
	for i in 0..n-1:
		id = withIds ? "todo_item_${i}_" + shortHash(rng.nextInt()) : null
		items.append({"id": id, "title": titlePattern.replace("{i}", i), "completed": rng.bool()})
	return items
```
