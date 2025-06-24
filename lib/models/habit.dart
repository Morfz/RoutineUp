// lib/models/habit.dart

import 'package:isar/isar.dart';
import 'package:routineup/models/habit_completion.dart'; // <-- TAMBAHKAN IMPORT INI

// Setelah mengubah file ini, jangan lupa jalankan perintah build_runner
part 'habit.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String name;

  // --- PERUBAHAN DI SINI ---
  // Mengubah dari List<DateTime> menjadi List<HabitCompletion>
  // untuk menyimpan tanggal dan catatan.
  List<HabitCompletion> completedDays = [];

  List<int> scheduledDays = [];
}