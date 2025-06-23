import 'package:routineup/models/habit.dart';

bool isHabitCompletedOnDate(List<DateTime> completedDays, DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  return completedDays.any((completedDate) {
    final normalizedCompletedDate =
    DateTime(completedDate.year, completedDate.month, completedDate.day);
    return normalizedCompletedDate.isAtSameMomentAs(normalizedDate);
  });
}

Map<DateTime, int> prepHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> dataset = {};
  for (var habit in habits) {
    for (var date in habit.completedDays) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      dataset.update(normalizedDate, (value) => value + 1, ifAbsent: () => 1);
    }
  }
  return dataset;
}

int calculateHabitStreak(Habit habit, DateTime forDate) {
  final completedDaysSet = habit.completedDays.map((d) => DateTime(d.year, d.month, d.day)).toSet();
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