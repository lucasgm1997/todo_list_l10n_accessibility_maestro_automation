import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';
import 'package:maestro_test/core/design_system/app_spacing.dart';
import 'package:maestro_test/core/design_system/app_typography.dart';
import 'package:maestro_test/di/service_locator.dart';
import 'package:maestro_test/features/todo/view_models/todo_view_model.dart';
import 'package:maestro_test/features/todo/widgets/todo_item.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  late final TodoViewModel _viewModel;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<TodoViewModel>();
    _viewModel.loadCommand
      ..addListener(_onLoadCommandChanged)
      ..execute();
    _viewModel.addCommand.addListener(_onAddCommandChanged);
    _viewModel.toggleCommand.addListener(_onToggleCommandChanged);
    _viewModel.deleteCommand.addListener(_onDeleteCommandChanged);
    _viewModel.editCommand.addListener(_onEditCommandChanged);
  }

  @override
  void dispose() {
    _viewModel.loadCommand.removeListener(_onLoadCommandChanged);
    _viewModel.addCommand.removeListener(_onAddCommandChanged);
    _viewModel.toggleCommand.removeListener(_onToggleCommandChanged);
    _viewModel.deleteCommand.removeListener(_onDeleteCommandChanged);
    _viewModel.editCommand.removeListener(_onEditCommandChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onLoadCommandChanged() {
    if (_viewModel.loadCommand.hasError) {
      _viewModel.loadCommand.clearResult();
      _showErrorSnackbar(_viewModel.loadCommand.failure!.message);
    }
  }

  void _onAddCommandChanged() {
    if (_viewModel.addCommand.hasError) {
      _viewModel.addCommand.clearResult();
      _showErrorSnackbar(_viewModel.addCommand.failure!.message);
    }

    if (_viewModel.addCommand.isSuccess) {
      _viewModel.addCommand.clearResult();
      _textController.clear();
    }
  }

  void _onToggleCommandChanged() {
    if (_viewModel.toggleCommand.hasError) {
      _viewModel.toggleCommand.clearResult();
      _showErrorSnackbar(_viewModel.toggleCommand.failure!.message);
    }
  }

  void _onDeleteCommandChanged() {
    if (_viewModel.deleteCommand.hasError) {
      _viewModel.deleteCommand.clearResult();
      _showErrorSnackbar(_viewModel.deleteCommand.failure!.message);
    }

    if (_viewModel.deleteCommand.isSuccess) {
      _viewModel.deleteCommand.clearResult();
      _showSuccessSnackbar('Tarefa removida com sucesso');
    }
  }

  void _onEditCommandChanged() {
    if (_viewModel.editCommand.hasError) {
      _viewModel.editCommand.clearResult();
      _showErrorSnackbar(_viewModel.editCommand.failure!.message);
    }

    if (_viewModel.editCommand.isSuccess) {
      _viewModel.editCommand.clearResult();
      _showSuccessSnackbar('Tarefa editada com sucesso');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showEditDialog(String id, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Título',
            hintText: 'Digite o novo título',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                _viewModel.editCommand.execute(id, newTitle);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _viewModel.deleteCommand.execute(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final completedCount =
                  _viewModel.todos.where((t) => t.completed).length;
              final totalCount = _viewModel.todos.length;

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Center(
                  child: Text(
                    '$completedCount/$totalCount',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Nova tarefa',
                      hintText: 'Digite uma tarefa...',
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _viewModel.addCommand.execute(value.trim());
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ListenableBuilder(
                  listenable: _viewModel.addCommand,
                  builder: (context, _) {
                    return ElevatedButton(
                      onPressed: _viewModel.addCommand.running
                          ? null
                          : () {
                              final text = _textController.text.trim();
                              if (text.isNotEmpty) {
                                _viewModel.addCommand.execute(text);
                              }
                            },
                      child: _viewModel.addCommand.running
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Adicionar'),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel.loadCommand,
              builder: (context, child) {
                if (_viewModel.loadCommand.running) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_viewModel.loadCommand.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Erro ao carregar tarefas',
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _viewModel.loadCommand.failure!.message,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton.icon(
                          onPressed: () => _viewModel.loadCommand.execute(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                return child!;
              },
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.todos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Nenhuma tarefa',
                            style: AppTypography.h3,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Adicione uma nova tarefa para começar',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _viewModel.todos.length,
                    itemBuilder: (context, index) {
                      final todo = _viewModel.todos[index];
                      return TodoItem(
                        todo: todo,
                        onToggle: () => _viewModel.toggleCommand.execute(todo.id),
                        onDelete: () => _showDeleteConfirmation(todo.id),
                        onEdit: () => _showEditDialog(todo.id, todo.title),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
