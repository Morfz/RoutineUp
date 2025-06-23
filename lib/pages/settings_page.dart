import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routineup/l10n/app_localizations.dart';
import 'package:routineup/theme/locale_provider.dart';
import 'package:routineup/theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(localizations.settings), // Menggunakan judul "SETTINGS"
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // --- PERUBAHAN PADA PEMANGGILAN WIDGET ---
            // Parameter 'child' diubah menjadi 'trailing' agar sesuai dengan ListTile
            _buildSettingsTile(
              context: context,
              title: localizations.darkMode,
              trailing: CupertinoSwitch(
                activeTrackColor: Colors.green,
                value: Provider.of<ThemeProvider>(context).isDarkMode,
                onChanged: (value) =>
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme(),
              ),
            ),

            const SizedBox(height: 10),

            _buildSettingsTile(
              context: context,
              title: localizations.language,
              onTap: () => _showLanguageDialog(context),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // --- PERBAIKAN UTAMA DI SINI ---
  // Helper widget diubah untuk menggunakan ListTile
  Widget _buildSettingsTile({
    required BuildContext context,
    required String title,
    required Widget trailing, // Nama parameter diubah dari 'child'
    void Function()? onTap,
  }) {
    // Menggunakan Material untuk memberi warna latar belakang dan bentuk pada ListTile
    return Material(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        // Menempatkan Switch atau Icon di sebelah kanan
        trailing: trailing,
        onTap: onTap,
        // Menyesuaikan bentuk dan padding agar terlihat seperti desain Anda
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      ),
    );
  }

  // Dialog untuk memilih bahasa (tidak ada perubahan di sini)
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Indonesia'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('id'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}