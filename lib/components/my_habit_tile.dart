import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String text;
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
    // Perkiraan tinggi ListTile untuk membuat tombol aksi menjadi persegi.
    // Padding vertikal (5*2) + Padding dalam Container (12*2) + tinggi Checkbox (sekitar 24-30)
    // Total tinggi sekitar 54-64. Kita bisa gunakan nilai ini untuk lebar.
    const double actionWidth = 60.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          // Atur extentRatio untuk mengontrol lebar total dari action pane.
          // Jika lebar layar adalah 400, dan kita mau 2 tombol selebar 60,
          // maka total lebar adalah 120. extentRatio = 120 / 400 = 0.3
          // Nilai 0.4 ini bisa Anda sesuaikan agar terlihat pas di perangkat Anda.
          extentRatio: 0.4, // Sesuaikan nilai ini
          children: [
            // Gunakan Expanded agar kedua tombol memiliki lebar yang sama
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
            child: Row(
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
                      color: isCompleted
                          ? Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(0.5)
                          : Theme.of(context).colorScheme.inversePrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
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
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeIn);
  }
}