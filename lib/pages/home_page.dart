// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routineup/components/my_calendar.dart';
import 'package:routineup/components/my_drawer.dart';
import 'package:routineup/components/my_habit_tile.dart';
import 'package:routineup/database/habit_database.dart';
import 'package:routineup/l10n/app_localizations.dart';
import 'package:routineup/models/habit.dart';
import 'package:routineup/util/habit_util.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart' as intl;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<HabitDatabase>(context, listen: false).loadData();
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void _showNoteDialog(Habit habit) {
    final normalizedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    String existingNote = "";
    // Cari catatan yang sudah ada
    for (final completion in habit.completedDays) {
      if (completion.date != null && DateTime(completion.date!.year, completion.date!.month, completion.date!.day).isAtSameMomentAs(normalizedDate)) {
        existingNote = completion.note ?? "";
        break;
      }
    }

    final noteController = TextEditingController(text: existingNote);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Catatan Kebiasaan"),
          content: TextField(
            controller: noteController,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Tulis catatan Anda di sini...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                context.read<HabitDatabase>().updateHabitNote(habit.id, _selectedDate, noteController.text);
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  void _showHabitDialog({Habit? habit}) {
    List<int> scheduledDays = habit?.scheduledDays.toList() ?? [];
    if (habit != null) {
      textController.text = habit.name;
    }

    showDialog(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(habit == null ? localizations.createHabit : localizations.editHabit),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: textController,
                      autofocus: true,
                      decoration: InputDecoration(hintText: localizations.habitNameHint),
                    ),
                    const SizedBox(height: 20),
                    Text(localizations.scheduleOnDays, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildDaySelector(scheduledDays, setDialogState),
                    const SizedBox(height: 5),
                    Text(
                      localizations.scheduleHint,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: Text(localizations.cancel),
                ),
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textController.text;
                    if (newHabitName.isNotEmpty) {
                      if (habit == null) {
                        context.read<HabitDatabase>().addHabit(newHabitName, scheduledDays);
                      } else {
                        context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName, scheduledDays);
                      }
                      Navigator.pop(context);
                      textController.clear();
                    }
                  },
                  child: Text(localizations.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteHabitBox(Habit habit) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(localizations.deleteThis),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          MaterialButton(
            onPressed: () {
              context.read<HabitDatabase>().deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showHabitDialog()),
        ],
      ),
      drawer: const MyDrawer(),
      body: Consumer<HabitDatabase>(
        builder: (context, habitDatabase, child) {
          if (habitDatabase.firstLaunchDate == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                MyCalendar(
                  firstLaunchDate: habitDatabase.firstLaunchDate!,
                  selectedDate: _selectedDate,
                  focusedDate: _focusedDate,
                  onPageChanged: (focusedDay) => setState(() => _focusedDate = focusedDay),
                  onDaySelected: (selectedDay, focusedDay) => setState(() {
                    _selectedDate = selectedDay;
                    _focusedDate = focusedDay;
                  }),
                ),
                const SizedBox(height: 10),
                _buildHabitList(habitDatabase.currentHabits),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHabitList(List<Habit> currentHabits) {
    final dayOfWeek = _selectedDate.weekday;
    final habitsForSelectedDay = currentHabits.where((habit) {
      if (habit.scheduledDays.isEmpty) return true;
      return habit.scheduledDays.contains(dayOfWeek);
    }).toList();

    if (habitsForSelectedDay.isEmpty) {
      final localizations = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_task_rounded, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                localizations.noHabitsYet,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.createFirstHabit,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habitsForSelectedDay.length,
      itemBuilder: (context, index) {
        final habit = habitsForSelectedDay[index];
        bool isCompleted = isHabitCompletedOnDate(habit.completedDays, _selectedDate);
        bool canEdit = isSameDay(_selectedDate, DateTime.now());
        int streak = calculateHabitStreak(habit, _selectedDate);

        // PERUBAHAN 2: Cari catatan untuk tanggal yang dipilih
        String? note;
        if (isCompleted) {
          final normalizedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
          // Gunakan loop yang aman untuk menghindari error jika data tidak ditemukan
          for (final completion in habit.completedDays) {
            if (completion.date != null &&
                DateTime(completion.date!.year, completion.date!.month, completion.date!.day)
                    .isAtSameMomentAs(normalizedDate)) {
              note = completion.note;
              break; // Ditemukan, keluar dari loop
            }
          }
        }

        return MyHabitTile(
          text: habit.name,
          noteText: note, // <-- BARU: Kirim catatan ke tile
          isCompleted: isCompleted,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => _showHabitDialog(habit: habit),
          deleteHabit: (context) => deleteHabitBox(habit),
          onNotePressed: (context) => _showNoteDialog(habit),
          isEditingEnabled: canEdit,
          streakCount: streak,
        );
      },
    );
  }

  Widget _buildDaySelector(List<int> selectedDays, StateSetter setDialogState) {
    // 1. Ambil nama locale yang sedang aktif (contoh: 'en' atau 'id')
    final localeName = AppLocalizations.of(context)!.localeName;

    // 2. FIX: Dapatkan simbol tanggal menggunakan DateFormat.
    // Ini adalah cara yang lebih aman dan terjamin.
    // Kita buat format 'E' (nama hari pendek) untuk locale yang aktif, lalu ambil simbolnya.
    final dateSymbols = intl.DateFormat.E(localeName).dateSymbols;

    // 3. Ambil daftar nama hari pendek (dimulai dari Minggu -> Sabtu)
    final shortWeekdays = dateSymbols.SHORTWEEKDAYS;

    // 4. Atur ulang urutan agar dimulai dari Senin -> Minggu sesuai logika UI kita
    final days = shortWeekdays.sublist(1)..add(shortWeekdays[0]);

    return Wrap(
      spacing: 4.0,
      runSpacing: 0.0,
      children: List<Widget>.generate(7, (int index) {
        final dayIndex = index + 1;
        return FilterChip(
          label: Text(days[index]),
          labelStyle: TextStyle(
              fontSize: 12,
              color: selectedDays.contains(dayIndex) ? Colors.white : Theme.of(context).colorScheme.inversePrimary
          ),
          selected: selectedDays.contains(dayIndex),
          onSelected: (bool selected) {
            setDialogState(() {
              if (selected) {
                selectedDays.add(dayIndex);
              } else {
                selectedDays.removeWhere((int id) => id == dayIndex);
              }
            });
          },
          backgroundColor: Theme.of(context).colorScheme.secondary,
          selectedColor: Colors.green,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.grey.shade400,
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }
}