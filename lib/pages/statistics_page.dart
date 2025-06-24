// lib/pages/statistics_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routineup/database/habit_database.dart';
import 'package:routineup/l10n/app_localizations.dart';
import 'package:routineup/util/stats_util.dart';
import 'package:intl/intl.dart' as intl;

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final habitDatabase = context.watch<HabitDatabase>();
    final allHabits = habitDatabase.currentHabits;
    final localeName = localizations.localeName;

    // --- Persiapan Data ---
    final monthlyCompletions = calculateMonthlyCompletions(allHabits);
    final productivityData = calculateProductivity(allHabits);
    final dateSymbols = intl.DateFormat.E(localeName).dateSymbols;

    // Siapkan nama bulan pendek untuk label grafik (Jan, Feb, dst.)
    final shortMonthNames = dateSymbols.SHORTMONTHS;

    // Siapkan nama hari pendek
    final shortWeekdayNames = dateSymbols.SHORTWEEKDAYS;
    final dayNames = shortWeekdayNames.sublist(1)..add(shortWeekdayNames[0]);

    int mostProductiveDayIndex = 0;
    int maxProductiveCompletions = 0;
    if (productivityData.isNotEmpty) {
      final sortedEntries = productivityData.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      maxProductiveCompletions = sortedEntries.first.value;
      mostProductiveDayIndex = sortedEntries.first.key;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(localizations.statistics),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- GANTI HEATMAP DENGAN GRAFIK BATANG BULANAN ---
          _buildStatCard(
            context,
            title: localizations.yearlySummary,
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              shortMonthNames[value.toInt() - 1], // Label Jan, Feb, dst.
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  barGroups: List.generate(12, (index) {
                    final monthIndex = index + 1;
                    return BarChartGroupData(
                      x: monthIndex,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyCompletions[monthIndex] ?? 0,
                          color: Colors.green,
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Grafik Hari Produktif (tidak berubah) ---
          _buildStatCard(
            context,
            title: localizations.mostProductiveDay,
            child: SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  maxY: (maxProductiveCompletions == 0 ? 5 : maxProductiveCompletions).toDouble() * 1.2,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(dayNames[value.toInt() - 1], style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.inversePrimary)),
                        ),
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    final dayIndex = index + 1;
                    return BarChartGroupData(x: dayIndex, barRods: [
                      BarChartRodData(
                        toY: productivityData[dayIndex]?.toDouble() ?? 0,
                        color: dayIndex == mostProductiveDayIndex ? Colors.green : Colors.grey.shade600,
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ]);
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Daftar Runtutan Terpanjang (tidak berubah) ---
          if (allHabits.isNotEmpty)
            Text(
              localizations.longestStreak,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 10),
          ...allHabits.map((habit) {
            final longestStreak = calculateLongestStreak(habit);
            return Card(
              color: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: ListTile(
                title: Text(habit.name),
                trailing: Text("$longestStreak ${localizations.days} 🔥", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            );
          }).expand((widget) => [widget, const SizedBox(height: 8)]),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}