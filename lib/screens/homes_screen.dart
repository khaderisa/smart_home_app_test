import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../models/home.dart';
import '../l10n/app_strings.dart';
import 'home_screen.dart';

class HomesScreen extends StatelessWidget {
  const HomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final s = AppStrings(provider.isArabic);
    final homes = provider.homes;
    final scheme = Theme.of(context).colorScheme;
    final isDark = provider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.myHomes,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: homes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined,
                      size: 72, color: scheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(s.noHomes,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface.withOpacity(0.4))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: homes.length,
              itemBuilder: (context, index) {
                final home = homes[index];
                return _HomeCard(
                  home: home,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(homeId: home.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final Home home;
  final bool isDark;
  final VoidCallback onTap;

  const _HomeCard({
    required this.home,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(home.icon, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(home.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface)),
                    const SizedBox(height: 4),
                    Text(
                      '${home.rooms.length} rooms · ${home.activeDevices} on',
                      style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withOpacity(0.45)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: scheme.onSurface.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}