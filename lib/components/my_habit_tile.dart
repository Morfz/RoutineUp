// lib/components/my_habit_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String text;
  final String? noteText;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  final bool isEditingEnabled;
  final int streakCount;
  final void Function(BuildContext)? onNotePressed;

  const MyHabitTile({
    super.key,
    required this.text,
    this.noteText,
    required this.isCompleted,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
    required this.streakCount,
    this.isEditingEnabled = true,
    this.onNotePressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNote = noteText != null && noteText!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.4,
          children: [
            Expanded(
              child: SlidableAction(
                onPressed: editHabit,
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Expanded(
              child: SlidableAction(
                onPressed: deleteHabit,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (isEditingEnabled) {
              onChanged?.call(!isCompleted);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isCompleted,
                      onChanged: isEditingEnabled ? onChanged : null,
                      activeColor: Colors.green,
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          color: isCompleted
                              ? Theme.of(context)
                              .colorScheme
                              .inversePrimary
                              .withOpacity(0.5)
                              : Theme.of(context).colorScheme.inversePrimary,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: streakCount > 1 ? 1.0 : 0.0,
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            streakCount.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.inversePrimary),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      IconButton(
                        icon: Icon(
                          hasNote ? Icons.description_outlined : Icons.note_add_outlined,
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.7),
                        ),
                        // --- FIX DI SINI ---
                        // Bungkus pemanggilan onNotePressed di dalam fungsi anonim
                        onPressed: () {
                          // Pengecekan null untuk keamanan
                          if (onNotePressed != null) {
                            // Panggil fungsi dengan memberikan 'context' yang tersedia dari method build
                            onNotePressed!(context);
                          }
                        },
                      ),
                  ],
                ),
                if (hasNote)
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 10.0, top: 2.0, bottom: 4.0),
                    child: Text(
                      noteText!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeIn);
  }
}