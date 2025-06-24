// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'RoutineUp';

  @override
  String get home => 'B E R A N D A';

  @override
  String get settings => 'P E N G A T U R A N';

  @override
  String get logout => 'K E L U A R';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get language => 'Bahasa';

  @override
  String get noHabitsYet => 'Belum ada kebiasaan';

  @override
  String get createFirstHabit =>
      'Yuk, buat kebiasaan pertamamu dengan menekan tombol \'+\' di atas!';

  @override
  String get createHabit => 'Buat Kebiasaan Baru';

  @override
  String get editHabit => 'Edit Kebiasaan';

  @override
  String get habitNameHint => 'Nama Kebiasaan';

  @override
  String get scheduleOnDays => 'Jadwalkan di hari:';

  @override
  String get scheduleHint => '(Kosongkan untuk setiap hari)';

  @override
  String get deleteThis => 'Hapus kebiasaan ini?';

  @override
  String get delete => 'Hapus';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get statistics => 'S T A T I S T I K';

  @override
  String get yearlySummary => 'Ringkasan Tahunan';

  @override
  String get longestStreak => 'Runtutan Terpanjang';

  @override
  String get days => 'hari';

  @override
  String get mostProductiveDay => 'Hari Paling Produktif';
}
