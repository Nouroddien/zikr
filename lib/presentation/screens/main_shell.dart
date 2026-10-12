import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'azkar_screens.dart';
import 'home_screen.dart';
import 'prayer_screen.dart';
import 'sebha_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screens = [
      HomeScreen(onNavigate: _selectTab),
      const AzkarCategoriesScreen(),
      const PrayerScreen(),
      const SebhaScreen(),
      const SettingsScreen(),
    ];
    final labels = [
      l10n.home,
      l10n.azkar,
      l10n.prayer,
      l10n.sebha,
      l10n.settings,
    ];
    final icons = [
      Icons.home_outlined,
      Icons.menu_book_outlined,
      Icons.access_time,
      Icons.nightlight_outlined,
      Icons.settings_outlined,
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: [
          for (var index = 0; index < labels.length; index++)
            NavigationDestination(
              icon: Icon(icons[index]),
              label: labels[index],
            ),
        ],
      ),
    );
  }

  void _selectTab(int index) => setState(() => _selectedIndex = index);
}

void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle(this.title, {this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.navy,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
