import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Todo List'**
  String get app_title;

  /// Title for the todo list screen
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get todo_list_title;

  /// Message shown when todo list is empty
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Add one to get started!'**
  String get todo_list_empty_message;

  /// Label for checkbox to mark task as complete
  ///
  /// In en, this message translates to:
  /// **'Mark task as complete'**
  String get todo_item_checkbox;

  /// Label for checkbox when task is already completed
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get todo_item_checkbox_completed;

  /// Label for delete button in todo item
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get todo_item_delete_button;

  /// Label for edit button in todo item
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get todo_item_edit_button;

  /// Label for task title text
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get todo_item_title;

  /// Subtitle showing task creation date
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String todo_item_subtitle(String date);

  /// Placeholder text for add task input field
  ///
  /// In en, this message translates to:
  /// **'Type a task...'**
  String get todo_add_input;

  /// Label for add task button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get todo_add_button;

  /// Label for new task input field
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get todo_add_field;

  /// Label for loading indicator
  ///
  /// In en, this message translates to:
  /// **'Loading tasks...'**
  String get todo_loading_indicator;

  /// Error message when tasks fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading tasks. Please try again.'**
  String get todo_error_message;

  /// Title for edit task dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get todo_edit_dialog_title;

  /// Label for task title input in edit dialog
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get todo_edit_dialog_label;

  /// Hint text for edit dialog input
  ///
  /// In en, this message translates to:
  /// **'Enter new title'**
  String get todo_edit_dialog_hint;

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get todo_delete_dialog_title;

  /// Message for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this task?'**
  String get todo_delete_dialog_message;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get todo_action_cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get todo_action_save;

  /// Delete button label in confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get todo_action_delete;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get todo_action_retry;

  /// Success message when task is deleted
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully'**
  String get todo_success_deleted;

  /// Success message when task is edited
  ///
  /// In en, this message translates to:
  /// **'Task edited successfully'**
  String get todo_success_edited;

  /// Title shown when todo list is empty
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get todo_empty_state_title;

  /// Message shown when todo list is empty
  ///
  /// In en, this message translates to:
  /// **'Add a new task to get started'**
  String get todo_empty_state_message;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
