// lib/components/my_drawer.dart

import 'package:flutter/material.dart';
import 'package:routineup/l10n/app_localizations.dart';
import 'package:routineup/pages/settings_page.dart';
// Import halaman statistik yang akan kita buat
import 'package:routineup/pages/statistics_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Icon ---
            const SizedBox(height: 50),
            Center(
              child: Icon(
                Icons.checklist_rtl_rounded,
                color: Theme.of(context).colorScheme.inversePrimary,
                size: 60,
              ),
            ),
            const SizedBox(height: 50),

            // --- Menu Items ---
            _buildDrawerItem(
              context: context,
              icon: Icons.home_rounded,
              title: AppLocalizations.of(context)!.home,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),

            // --- TAMBAHKAN ITEM MENU STATISTIK DI SINI ---
            _buildDrawerItem(
              context: context,
              icon: Icons.bar_chart_rounded, // Ikon baru
              title: AppLocalizations.of(context)!.statistics, // Teks baru (dari lokalisasi)
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // Buka halaman statistik
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            // -----------------------------------------

            _buildDrawerItem(
              context: context,
              icon: Icons.settings_rounded,
              title: AppLocalizations.of(context)!.settings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}