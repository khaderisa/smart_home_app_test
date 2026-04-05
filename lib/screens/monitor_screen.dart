import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../models/device.dart';
import '../l10n/app_strings.dart';

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final s = AppStrings(provider.isArabic);
    final scheme = Theme.of(context).colorScheme;
    final isDark = provider.isDark;

    // Collect all devices
    final List<Map<String, dynamic>> allDevices = [];
    for (final home in provider.homes) {
      for (final room in home.rooms) {
        for (final device in room.devices) {
          allDevices.add({
            'home': home.name,
            'homeIcon': home.icon,
            'room': room.name,
            'device': device,
          });
        }
      }
    }

    final activeCount = allDevices.where((e) => (e['device'] as Device).isOn).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.liveMonitor,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface)),
      ),
      body: allDevices.isEmpty
          ? Center(
              child: Text(s.noDevices,
                  style: TextStyle(
                      fontSize: 18, color: scheme.onSurface.withOpacity(0.4))),
            )
          : Column(
              children: [
                // Summary bar
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                        label: s.activeStr,
                        value: '$activeCount',
                        color: const Color(0xFF4CAF82),
                        icon: Icons.power_settings_new_rounded,
                      ),
                      Container(width: 1, height: 36, color: scheme.onSurface.withOpacity(0.1)),
                      _SummaryItem(
                        label: s.offStr,
                        value: '${allDevices.length - activeCount}',
                        color: scheme.onSurface.withOpacity(0.4),
                        icon: Icons.power_off_outlined,
                      ),
                      Container(width: 1, height: 36, color: scheme.onSurface.withOpacity(0.1)),
                      _SummaryItem(
                        label: s.currentPower,
                        value: '0 W',
                        color: const Color(0xFFFFB800),
                        icon: Icons.bolt_rounded,
                      ),
                    ],
                  ),
                ),

                // Device list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: allDevices.length,
                    itemBuilder: (context, index) {
                      final item = allDevices[index];
                      final device = item['device'] as Device;
                      return _MonitorCard(
                        device: device,
                        homeName: '${item['homeIcon']} ${item['home']}',
                        roomName: item['room'],
                        isDark: isDark,
                        scheme: scheme,
                        isArabic: provider.isArabic,
                        s: s,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _SummaryItem({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      );
}

class _MonitorCard extends StatelessWidget {
  final Device device;
  final String homeName;
  final String roomName;
  final bool isDark;
  final ColorScheme scheme;
  final bool isArabic;
  final AppStrings s;

  const _MonitorCard({
    required this.device,
    required this.homeName,
    required this.roomName,
    required this.isDark,
    required this.scheme,
    required this.isArabic,
    required this.s,
  });

  IconData get _icon {
    switch (device.type) {
      case DeviceType.light: return Icons.lightbulb_outline_rounded;
      case DeviceType.plug:  return Icons.power_outlined;
      case DeviceType.fan:   return Icons.air_rounded;
      case DeviceType.ac:    return Icons.ac_unit_rounded;
    }
  }

  Color get _color {
    switch (device.type) {
      case DeviceType.light: return const Color(0xFFFFB800);
      case DeviceType.plug:  return scheme.primary;
      case DeviceType.fan:   return const Color(0xFF00BCD4);
      case DeviceType.ac:    return const Color(0xFF4CAF82);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = device.isOn ? _color : scheme.onSurface.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: device.isOn ? _color.withOpacity(0.4) : isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
          width: device.isOn ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: activeColor, size: 22),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: scheme.onSurface)),
                const SizedBox(height: 2),
                Text('$homeName · $roomName',
                    style: TextStyle(fontSize: 11, color: scheme.onSurface.withOpacity(0.4))),
              ],
            ),
          ),

          // Power
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('0 W',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: device.isOn ? const Color(0xFFFFB800) : scheme.onSurface.withOpacity(0.3))),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: device.isOn ? const Color(0xFF4CAF82).withOpacity(0.12) : scheme.onSurface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  device.isOn ? s.activeStr : s.offStr,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: device.isOn ? const Color(0xFF4CAF82) : scheme.onSurface.withOpacity(0.35)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
