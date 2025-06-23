import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routineup/models/app_settings.dart';
import 'package:routineup/models/habit.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  DateTime? firstLaunchDate;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  Future<void> loadData() async {
    await _loadFirstLaunchDate();
    await readHabits();
  }

  Future<void> _loadFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    firstLaunchDate = settings?.firstLaunchDate;
  }

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
      firstLaunchDate = settings.firstLaunchDate;
    }
  }

  final List<Habit> currentHabits = [];

  Future<void> addHabit(String habitName, List<int> scheduledDays) async {
    final newHabit = Habit()
      ..name = habitName
      ..scheduledDays = scheduledDays; // Simpan jadwal

    await isar.writeTxn(() => isar.habits.put(newHabit));
    await readHabits();
  }

  Future<void> readHabits() async {
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    notifyListeners();
  }

  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

        final isAlreadyCompleted = habit.completedDays.any((date) =>
        date.year == today.year &&
            date.month == today.month &&
            date.day == today.day);

        if (isCompleted && !isAlreadyCompleted) {
          habit.completedDays.add(today);
        } else {
          habit.completedDays.removeWhere((date) =>
          date.year == today.year &&
              date.month == today.month &&
              date.day == today.day);
        }
        await isar.habits.put(habit);
      });
    }
    await readHabits();
  }

  Future<void> updateHabitName(int id, String newName, List<int> scheduledDays) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        habit.scheduledDays = scheduledDays; // Simpan jadwal yang diperbarui
        await isar.habits.put(habit);
      });
    }
    await readHabits();
  }


  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    await readHabits();
  }
}