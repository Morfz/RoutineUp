// lib/util/stats_util.dart

import 'package:routineup/models/habit.dart';

// Menghitung runtutan (streak) terpanjang sepanjang masa untuk sebuah habit
int calculateLongestStreak(Habit habit) {
  if (habit.completedDays.isEmpty) {
    return 0;
  }

  // Ambil tanggal, urutkan, dan hapus duplikat jika ada
  final sortedDays = habit.completedDays.map((c) => c.date).where((d) => d != null).toSet().toList();
  sortedDays.sort();

  if (sortedDays.isEmpty) {
    return 0;
  }

  int longestStreak = 0;
  int currentStreak = 1;

  for (int i = 1; i < sortedDays.length; i++) {
    final day1 = DateTime(sortedDays[i-1]!.year, sortedDays[i-1]!.month, sortedDays[i-1]!.day);
    final day2 = DateTime(sortedDays[i]!.year, sortedDays[i]!.month, sortedDays[i]!.day);

    if (day2.difference(day1).inDays == 1) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  if (longestStreak == 0 && sortedDays.isNotEmpty) {
    longestStreak = 1;
  }

  return longestStreak;
}

// Menghitung total penyelesaian untuk setiap hari dalam seminggu
Map<int, int> calculateProductivity(List<Habit> habits) {
  Map<int, int> productivity = {};

  for (final habit in habits) {
    for (final completion in habit.completedDays) {
      if (completion.date != null) {
        final dayOfWeek = completion.date!.weekday; // 1=Senin, 7=Minggu
        productivity.update(dayOfWeek, (value) => value + 1, ifAbsent: () => 1);
      }
    }
  }
  return productivity;
}

// FUNGSI BARU: Menghitung total penyelesaian untuk setiap bulan dalam setahun
Map<int, double> calculateMonthlyCompletions(List<Habit> habits) {
  final now = DateTime.now();
  // Peta: 1 (Jan) -> 50.0, 2 (Feb) -> 30.0, dst.
  final Map<int, double> monthlyTotals = {};

  // Inisialisasi semua bulan dengan nilai 0
  for (int i = 1; i <= 12; i++) {
    monthlyTotals[i] = 0;
  }

  for (var habit in habits) {
    for (var completion in habit.completedDays) {
      // Hanya hitung penyelesaian dari tahun ini
      if (completion.date != null && completion.date!.year == now.year) {
        int month = completion.date!.month;
        monthlyTotals.update(month, (value) => value + 1);
      }
    }
  }
  return monthlyTotals;
}
