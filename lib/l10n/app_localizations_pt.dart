// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get app_title => 'Lista de Tarefas';

  @override
  String get todo_list_title => 'Minhas Tarefas';

  @override
  String get todo_list_empty_message =>
      'Nenhuma tarefa ainda. Adicione uma para começar!';

  @override
  String get todo_item_checkbox => 'Marcar tarefa como concluída';

  @override
  String get todo_item_checkbox_completed => 'Tarefa concluída';

  @override
  String get todo_item_delete_button => 'Excluir tarefa';

  @override
  String get todo_item_edit_button => 'Editar tarefa';

  @override
  String get todo_item_title => 'Título da tarefa';

  @override
  String todo_item_subtitle(String date) {
    return 'Criada em $date';
  }

  @override
  String get todo_add_input => 'Digite uma tarefa...';

  @override
  String get todo_add_button => 'Adicionar';

  @override
  String get todo_add_field => 'Nova tarefa';

  @override
  String get todo_loading_indicator => 'Carregando tarefas...';

  @override
  String get todo_error_message => 'Erro ao carregar tarefas. Tente novamente.';

  @override
  String get todo_edit_dialog_title => 'Editar Tarefa';

  @override
  String get todo_edit_dialog_label => 'Título';

  @override
  String get todo_edit_dialog_hint => 'Digite o novo título';

  @override
  String get todo_delete_dialog_title => 'Confirmar exclusão';

  @override
  String get todo_delete_dialog_message =>
      'Deseja realmente excluir esta tarefa?';

  @override
  String get todo_action_cancel => 'Cancelar';

  @override
  String get todo_action_save => 'Salvar';

  @override
  String get todo_action_delete => 'Excluir';

  @override
  String get todo_action_retry => 'Tentar novamente';

  @override
  String get todo_success_deleted => 'Tarefa removida com sucesso';

  @override
  String get todo_success_edited => 'Tarefa editada com sucesso';

  @override
  String get todo_empty_state_title => 'Nenhuma tarefa';

  @override
  String get todo_empty_state_message =>
      'Adicione uma nova tarefa para começar';
}
