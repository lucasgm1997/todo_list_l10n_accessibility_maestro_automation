// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Todo List';

  @override
  String get todo_list_title => 'My Tasks';

  @override
  String get todo_list_empty_message => 'No tasks yet. Add one to get started!';

  @override
  String get todo_item_checkbox => 'Mark task as complete';

  @override
  String get todo_item_checkbox_completed => 'Task completed';

  @override
  String get todo_item_delete_button => 'Delete task';

  @override
  String get todo_item_edit_button => 'Edit task';

  @override
  String get todo_item_title => 'Task title';

  @override
  String todo_item_subtitle(String date) {
    return 'Created on $date';
  }

  @override
  String get todo_add_input => 'Type a task...';

  @override
  String get todo_add_button => 'Add';

  @override
  String get todo_add_field => 'New task';

  @override
  String get todo_loading_indicator => 'Loading tasks...';

  @override
  String get todo_error_message => 'Error loading tasks. Please try again.';

  @override
  String get todo_edit_dialog_title => 'Edit Task';

  @override
  String get todo_edit_dialog_label => 'Title';

  @override
  String get todo_edit_dialog_hint => 'Enter new title';

  @override
  String get todo_delete_dialog_title => 'Confirm deletion';

  @override
  String get todo_delete_dialog_message =>
      'Do you really want to delete this task?';

  @override
  String get todo_action_cancel => 'Cancel';

  @override
  String get todo_action_save => 'Save';

  @override
  String get todo_action_delete => 'Delete';

  @override
  String get todo_action_retry => 'Try again';

  @override
  String get todo_success_deleted => 'Task deleted successfully';

  @override
  String get todo_success_edited => 'Task edited successfully';

  @override
  String get todo_empty_state_title => 'No tasks';

  @override
  String get todo_empty_state_message => 'Add a new task to get started';
}
