// lib/util/habit_util.dart

import 'package:routineup/models/habit.dart';
import 'package:routineup/models/habit_completion.dart'; // <-- TAMBAHKAN IMPORT

// --- PERUBAHAN DI SINI ---
// Sekarang menerima List<HabitCompletion>
bool isHabitCompletedOnDate(List<HabitCompletion> completedDays, DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  // Cek properti 'date' dari setiap objek HabitCompletion
  return completedDays.any((completion) {
    if (completion.date == null) return false;
    final normalizedCompletedDate =
    DateTime(completion.date!.year, completion.date!.month, completion.date!.day);
    return normalizedCompletedDate.isAtSameMomentAs(normalizedDate);
  });
}

Map<DateTime, int> prepHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> dataset = {};
  for (var habit in habits) {
    // Iterasi melalui List<HabitCompletion>
    for (var completion in habit.completedDays) {
      if (completion.date != null) {
        final normalizedDate = DateTime(completion.date!.year, completion.date!.month, completion.date!.day);
        dataset.update(normalizedDate, (value) => value + 1, ifAbsent: () => 1);
      }
    }
  }
  return dataset;
}

// --- PERUBAHAN DI SINI ---
// Logika streak tetap sama, hanya perlu menyesuaikan cara mengakses tanggal
int calculateHabitStreak(Habit habit, DateTime forDate) {
  final completedDaysSet = habit.completedDays
      .where((c) => c.date != null)
      .map((c) => DateTime(c.date!.year, c.date!.month, c.date!.day))
      .toSet();
  int streak = 0;
  DateTime currentDate = DateTime(forDate.year, forDate.month, forDate.day);

  while (true) {
    if (completedDaysSet.contains(currentDate)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}