import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../models/room.dart';
import '../l10n/app_strings.dart';
import 'room_screen.dart';

class HomeScreen extends StatelessWidget {
  final String homeId;
  const HomeScreen({super.key, required this.homeId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final s = AppStrings(provider.isArabic);
    final home = provider.getHome(homeId);
    final scheme = Theme.of(context).colorScheme;

    final totalDevices = home.rooms.fold<int>(0, (sum, r) => sum + r.devices.length);
    final activeDevices = home.rooms.fold<int>(0, (sum, r) => sum + r.activeDevices);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${home.icon} ${home.name}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface),
            ),
            Text(
              '$activeDevices of $totalDevices devices active',
              style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withOpacity(0.45),
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: home.rooms.isEmpty
          ? _buildEmpty(context, scheme, s)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: home.rooms.length,
              itemBuilder: (context, index) {
                final room = home.rooms[index];
                return _RoomCard(room: room, homeId: homeId);
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, ColorScheme scheme, AppStrings s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined,
              size: 72, color: scheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(s.noRooms,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 8),
          Text(s.addRoomHint,
              style: TextStyle(
                  fontSize: 14, color: scheme.onSurface.withOpacity(0.3))),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final String homeId;
  const _RoomCard({required this.room, required this.homeId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActive = room.activeDevices > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) =>
                  RoomScreen(room: room, homeId: homeId),
              transitionsBuilder: (_, animation, __, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasActive
                    ? scheme.primary.withOpacity(0.4)
                    : isDark
                        ? const Color(0xFF30363D)
                        : const Color(0xFFE2E8F0),
                width: hasActive ? 1.5 : 1,
              ),
              boxShadow: hasActive
                  ? [
                      BoxShadow(
                        color: scheme.primary.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: hasActive
                        ? scheme.primary.withOpacity(0.12)
                        : scheme.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(room.icon,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.name,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(
                        '${room.devices.length} devices · ${room.activeDevices} on',
                        style: TextStyle(
                          fontSize: 13,
                          color: hasActive
                              ? scheme.primary.withOpacity(0.8)
                              : scheme.onSurface.withOpacity(0.4),
                        ),
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
