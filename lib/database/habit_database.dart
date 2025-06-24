// lib/database/habit_database.dart

import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routineup/models/app_settings.dart';
import 'package:routineup/models/habit.dart';
import 'package:routineup/models/habit_completion.dart';

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
      ..scheduledDays = scheduledDays;

    await isar.writeTxn(() => isar.habits.put(newHabit));
    await readHabits();
  }

  Future<void> readHabits() async {
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    notifyListeners();
  }

  // --- PERBAIKAN UTAMA DI FUNGSI INI ---
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

        // FIX: Buat salinan list yang bisa diubah (growable) dari list database.
        final modifiableCompletedDays = List<HabitCompletion>.from(habit.completedDays);

        if (isCompleted) {
          // Lakukan operasi pada salinan list
          final isAlreadyCompleted = modifiableCompletedDays.any((record) =>
          record.date?.year == today.year &&
              record.date?.month == today.month &&
              record.date?.day == today.day);

          if (!isAlreadyCompleted) {
            final newCompletion = HabitCompletion()..date = today;
            modifiableCompletedDays.add(newCompletion);
          }
        } else {
          // Lakukan operasi hapus pada salinan list
          modifiableCompletedDays.removeWhere((record) =>
          record.date?.year == today.year &&
              record.date?.month == today.month &&
              record.date?.day == today.day);
        }

        // Setelah diubah, kembalikan salinan list tersebut ke objek habit
        habit.completedDays = modifiableCompletedDays;

        // Simpan kembali objek habit yang sudah diperbarui
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
        habit.scheduledDays = scheduledDays;
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

  Future<void> updateHabitNote(int id, DateTime date, String note) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        final normalizedDate = DateTime(date.year, date.month, date.day);

        // Operasi ini hanya mengubah properti objek di dalam list,
        // tidak mengubah panjang list, jadi tidak perlu membuat salinan.
        // Namun, untuk keamanan, bisa juga diterapkan pola yang sama.
        final completionIndex = habit.completedDays.indexWhere((record) =>
        record.date?.year == normalizedDate.year &&
            record.date?.month == normalizedDate.month &&
            record.date?.day == normalizedDate.day);

        if (completionIndex != -1) {
          habit.completedDays[completionIndex].note = note;
          await isar.habits.put(habit);
        }
      });
    }
    await readHabits();
  }
}