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
}
