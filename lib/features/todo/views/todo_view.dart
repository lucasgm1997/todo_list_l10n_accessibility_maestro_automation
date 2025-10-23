import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';
import 'package:maestro_test/core/design_system/app_spacing.dart';
import 'package:maestro_test/core/design_system/app_typography.dart';
import 'package:maestro_test/core/widgets/language_switcher.dart';
import 'package:maestro_test/core/widgets/text_input.dart';
import 'package:maestro_test/core/widgets/primary_button.dart';
import 'package:maestro_test/di/service_locator.dart';
import 'package:maestro_test/features/todo/view_models/todo_view_model.dart';
import 'package:maestro_test/features/todo/widgets/todo_item.dart';
import 'package:maestro_test/features/todo/views/bottom_sheet_button.dart';
import 'package:maestro_test/l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TodoView extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const TodoView({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

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
      final l10n = AppLocalizations.of(context)!;
      _showSuccessSnackbar(l10n.todo_success_deleted);
    }
  }

  void _onEditCommandChanged() {
    if (_viewModel.editCommand.hasError) {
      _viewModel.editCommand.clearResult();
      _showErrorSnackbar(_viewModel.editCommand.failure!.message);
    }

    if (_viewModel.editCommand.isSuccess) {
      _viewModel.editCommand.clearResult();
      final l10n = AppLocalizations.of(context)!;
      _showSuccessSnackbar(l10n.todo_success_edited);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showEditDialog(String id, String currentTitle) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.todo_edit_dialog_title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.todo_edit_dialog_label,
            hintText: l10n.todo_edit_dialog_hint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.todo_action_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                _viewModel.editCommand.execute(id, newTitle);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.todo_action_save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String id) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.todo_delete_dialog_title),
        content: Text(l10n.todo_delete_dialog_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.todo_action_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              _viewModel.deleteCommand.execute(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.todo_action_delete),
          ),
        ],
      ),
    );
  }

  void _showTodosBottomSheet() {
    final l10n = AppLocalizations.of(context)!;

    showCupertinoModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.todo_list_title, style: AppTypography.h2),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.todos.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.todo_empty_state_message,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _viewModel.todos.length,
                    itemBuilder: (context, index) {
                      final todo = _viewModel.todos[index];
                      return TodoItem(
                        todo: todo,
                        index: index,
                        onToggle: () =>
                            _viewModel.toggleCommand.execute(todo.id),
                        onDelete: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(todo.id);
                        },
                        onEdit: () {
                          Navigator.pop(context);
                          _showEditDialog(todo.id, todo.title);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      bottomSheet: SizedBox(
        width: double.infinity,
        height: 300,
        child: Container(
          color: Colors.orange,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              BottomSheetButton(onPressed: () {}),
              BottomSheetButton(onPressed: () {}),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(l10n.todo_list_title),

        actions: [
          // Language switcher button
          LanguageSwitcher(
            currentLocale: widget.currentLocale,
            onLocaleChanged: widget.onLocaleChanged,
          ),
          // Task counter
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final completedCount = _viewModel.todos
                  .where((t) => t.completed)
                  .length;
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
                  child: TextInput(
                    controller: _textController,
                    labelText: l10n.todo_add_field,
                    hintText: l10n.todo_add_input,
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
                    return PrimaryButton(
                      onPressed: () {
                        final text = _textController.text.trim();
                        if (text.isNotEmpty) {
                          _viewModel.addCommand.execute(text);
                        }
                      },
                      isLoading: _viewModel.addCommand.running,
                      child: Text(l10n.todo_add_button),
                      minWidth: 100,
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
                  return const Center(child: CircularProgressIndicator());
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
                          label: Text(l10n.todo_action_retry),
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
                            l10n.todo_empty_state_title,
                            style: AppTypography.h3,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.todo_empty_state_message,
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
                        index: index,
                        onToggle: () =>
                            _viewModel.toggleCommand.execute(todo.id),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTodosBottomSheet,
        icon: const Icon(Icons.list),
        label: const Text('View Modal'),
      ),
    );
  }
}
