import 'package:isar/isar.dart';

// Setelah mengubah file ini, jangan lupa jalankan perintah build_runner
part 'habit.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String name;

  List<DateTime> completedDays = [];

  List<int> scheduledDays = [];
}