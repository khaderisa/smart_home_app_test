import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../l10n/app_strings.dart';
import 'homes_screen.dart';
import 'schedulers_screen.dart';
import 'reports_screen.dart';
import 'monitor_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomesScreen(),
    MonitorScreen(),
    SchedulersScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final s = AppStrings(provider.isArabic);
    final scheme = Theme.of(context).colorScheme;
    final isDark = provider.isDark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          indicatorColor: scheme.primary.withOpacity(0.12),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: s.myHomes,
            ),
            NavigationDestination(
              icon: const Icon(Icons.monitor_heart_outlined),
              selectedIcon: const Icon(Icons.monitor_heart_rounded),
              label: s.monitor,
            ),
            NavigationDestination(
              icon: const Icon(Icons.schedule_outlined),
              selectedIcon: const Icon(Icons.schedule_rounded),
              label: s.schedulers,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart_rounded),
              label: s.reports,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: s.settings,
            ),
          ],
        ),
      ),
    );
  }
}
