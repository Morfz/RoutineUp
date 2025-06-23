import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routineup/database/habit_database.dart';
// Import LocaleProvider agar kita bisa mengaksesnya
import 'package:routineup/theme/locale_provider.dart';
import 'package:routineup/util/habit_util.dart';
import 'package:table_calendar/table_calendar.dart';

class MyCalendar extends StatelessWidget {
  final DateTime firstLaunchDate;
  final DateTime selectedDate;
  final DateTime focusedDate;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const MyCalendar({
    super.key,
    required this.firstLaunchDate,
    required this.selectedDate,
    required this.focusedDate,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final habitDatabase = context.watch<HabitDatabase>();
    final heatMapDataSet = prepHeatMapDataset(habitDatabase.currentHabits);

    // --- PERBAIKAN UTAMA DI SINI ---
    // 1. Ambil locale yang sedang aktif dari LocaleProvider
    final currentLocale = Provider.of<LocaleProvider>(context).locale;

    return TableCalendar(
      // 2. Gunakan locale yang dinamis. .toString() akan menghasilkan 'en' atau 'id'
      locale: currentLocale.toString(),
      focusedDay: focusedDate,
      firstDay: firstLaunchDate,
      lastDay: DateTime.now(),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 16),
        leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.inversePrimary),
        rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.inversePrimary),
      ),
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          int completionCount = heatMapDataSet[DateTime(day.year, day.month, day.day)] ?? 0;
          return _buildHeatmapCell(context, day, completionCount);
        },
        todayBuilder: (context, day, focusedDay) {
          int completionCount = heatMapDataSet[DateTime(day.year, day.month, day.day)] ?? 0;
          return _buildHeatmapCell(context, day, completionCount, isToday: true);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildHeatmapCell(context, day, 0, isSelected: true);
        },
      ),
    );
  }

  Widget _buildHeatmapCell(BuildContext context, DateTime day, int count, {bool isToday = false, bool isSelected = false}) {
    // ... (kode di dalam method ini tidak berubah)
    Color cellColor = Colors.transparent;
    if (count == 1) {
      cellColor = Colors.green.shade200;
    } else if (count == 2) {
      cellColor = Colors.green.shade300;
    } else if (count >= 3) {
      cellColor = Colors.green.shade400;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(5.5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : cellColor,
        shape: BoxShape.circle,
        border: isToday && !isSelected ? Border.all(color: Colors.green.shade700, width: 1.5) : null,
      ),
      child: Center(
        child: Text(
          day.day.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.inversePrimary,
            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}