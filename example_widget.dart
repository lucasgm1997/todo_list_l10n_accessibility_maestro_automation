// EXEMPLO DE USO: i18n + Semantics + Maestro
// Este arquivo é apenas um exemplo e não faz parte da aplicação

import 'package:flutter/material.dart';
import 'package:maestro_test/core/semantics/app_semantics.dart';
import 'package:maestro_test/l10n/app_localizations.dart';

/// Exemplo de como usar AppLocalizations e AppSemantics juntos
class ExampleTodoWidget extends StatelessWidget {
  final String taskTitle;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ExampleTodoWidget({
    Key? key,
    required this.taskTitle,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obter instância de localização
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: ListTile(
        // Checkbox com Semantics
        leading: Semantics(
          // Identificador estável para testes Maestro
          identifier: AppSemantics.todoItemCheckbox,
          // Label traduzido que pode mudar sem quebrar testes
          label: isCompleted
              ? l10n.todo_item_checkbox_completed
              : l10n.todo_item_checkbox,
          checked: isCompleted,
          child: Checkbox(value: isCompleted, onChanged: (_) => onToggle()),
        ),

        // Título com Semantics
        title: Semantics(
          identifier: AppSemantics.todoItemTitle,
          label: l10n.todo_item_title,
          child: Text(
            taskTitle,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),

        // Subtítulo com parâmetro
        subtitle: Semantics(
          identifier: AppSemantics.todoItemSubtitle,
          label: l10n.todo_item_subtitle('2024-01-15'),
          child: Text(l10n.todo_item_subtitle('2024-01-15')),
        ),

        // Botões de ação
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão de editar
            Semantics(
              identifier: AppSemantics.todoItemEditButton,
              label: l10n.todo_item_edit_button,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: l10n.todo_item_edit_button,
              ),
            ),

            // Botão de deletar
            Semantics(
              identifier: AppSemantics.todoItemDeleteButton,
              label: l10n.todo_item_delete_button,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: l10n.todo_item_delete_button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exemplo de formulário de adição de tarefa
class ExampleAddTodoForm extends StatefulWidget {
  const ExampleAddTodoForm({Key? key}) : super(key: key);

  @override
  State<ExampleAddTodoForm> createState() => _ExampleAddTodoFormState();
}

class _ExampleAddTodoFormState extends State<ExampleAddTodoForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Campo de input
          Expanded(
            child: Semantics(
              identifier: AppSemantics.todoAddInput,
              label: l10n.todo_add_field,
              textField: true,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: l10n.todo_add_field,
                  hintText: l10n.todo_add_input,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Botão de adicionar
          Semantics(
            identifier: AppSemantics.todoAddButton,
            label: l10n.todo_add_button,
            button: true,
            child: ElevatedButton(
              onPressed: () {
                // Adicionar tarefa
                if (_controller.text.isNotEmpty) {
                  // Lógica de adição
                  _controller.clear();
                }
              },
              child: Text(l10n.todo_add_button),
            ),
          ),
        ],
      ),
    );
  }
}

/// Exemplo de lista vazia
class ExampleEmptyState extends StatelessWidget {
  const ExampleEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Semantics(
        identifier: AppSemantics.todoListEmptyMessage,
        label: l10n.todo_list_empty_message,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.todo_list_empty_message,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exemplo de indicador de loading
class ExampleLoadingIndicator extends StatelessWidget {
  const ExampleLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Semantics(
        identifier: AppSemantics.todoLoadingIndicator,
        label: l10n.todo_loading_indicator,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.todo_loading_indicator),
          ],
        ),
      ),
    );
  }
}

/// Exemplo de configuração do MaterialApp
void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Configuração de internacionalização
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Definir locale inicial (opcional)
      // locale: const Locale('pt'), // Força português
      // locale: const Locale('en'), // Força inglês
      home: Scaffold(
        appBar: AppBar(
          title: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Semantics(
                identifier: AppSemantics.appTitle,
                label: l10n.app_title,
                child: Text(l10n.app_title),
              );
            },
          ),
        ),
        body: Column(
          children: [
            const ExampleAddTodoForm(),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  ExampleTodoWidget(
                    taskTitle: 'Exemplo de tarefa',
                    isCompleted: false,
                    onToggle: () {},
                    onDelete: () {},
                    onEdit: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
