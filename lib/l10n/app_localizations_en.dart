// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RoutineUp';

  @override
  String get home => 'H O M E';

  @override
  String get settings => 'S E T T I N G S';

  @override
  String get logout => 'L O G O U T';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get noHabitsYet => 'No habits yet';

  @override
  String get createFirstHabit =>
      'Create your first habit by pressing the \'+\' button above!';

  @override
  String get createHabit => 'Create New Habit';

  @override
  String get editHabit => 'Edit Habit';

  @override
  String get habitNameHint => 'Habit Name';

  @override
  String get scheduleOnDays => 'Schedule on days:';

  @override
  String get scheduleHint => '(Leave empty for every day)';

  @override
  String get deleteThis => 'Delete this habit?';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';
}
