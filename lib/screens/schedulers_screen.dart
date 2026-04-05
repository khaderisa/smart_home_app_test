import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../models/device.dart';
import '../l10n/app_strings.dart';

class SchedulersScreen extends StatelessWidget {
  const SchedulersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final s = AppStrings(provider.isArabic);
    final scheme = Theme.of(context).colorScheme;
    final isDark = provider.isDark;

    final List<Map<String, dynamic>> scheduled = [];
    for (final home in provider.homes) {
      for (final room in home.rooms) {
        for (final device in room.devices) {
          final sch = device.schedule;
          if (sch.startTime != null || sch.endTime != null || sch.days.any((d) => d)) {
            scheduled.add({
              'homeId': home.id, 'roomId': room.id,
              'home': home.name, 'homeIcon': home.icon,
              'room': room.name, 'device': device,
            });
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.mySchedulers,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: scheme.onSurface)),
      ),
      body: scheduled.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.schedule_rounded, size: 72, color: scheme.onSurface.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(s.noSchedulers, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: scheme.onSurface.withOpacity(0.4))),
                const SizedBox(height: 8),
                Text(s.addScheduleHint, style: TextStyle(fontSize: 14, color: scheme.onSurface.withOpacity(0.3))),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: scheduled.length,
              itemBuilder: (context, index) {
                final item = scheduled[index];
                final device = item['device'] as Device;
                final sch = device.schedule;
                const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

                return Dismissible(
                  key: Key(device.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(s.cancelSchedule),
                        content: Text('${s.removeScheduleFor} "${device.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.no)),
                          TextButton(onPressed: () => Navigator.pop(ctx, true),
                              child: Text(s.yes, style: const TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => provider.clearDeviceSchedule(item['homeId'], item['roomId'], device.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B22) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(Icons.schedule_rounded, size: 18, color: scheme.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(device.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: scheme.onSurface))),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(s.cancelSchedule),
                                content: Text('${s.removeScheduleFor} "${device.name}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.no)),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(s.yes, style: const TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              provider.clearDeviceSchedule(item['homeId'], item['roomId'], device.id);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text('${item['homeIcon']} ${item['home']} · ${item['room']}',
                            style: TextStyle(fontSize: 12, color: scheme.onSurface.withOpacity(0.45))),
                        const Spacer(),
                        Icon(Icons.swipe_left_rounded, size: 12, color: scheme.onSurface.withOpacity(0.25)),
                        const SizedBox(width: 3),
                        Text(s.swipeToDelete, style: TextStyle(fontSize: 10, color: scheme.onSurface.withOpacity(0.25))),
                      ]),
                      const SizedBox(height: 14),
                      Row(children: [
                        _TimeChip(label: s.start, value: sch.startTime?.format(context) ?? '--:--', scheme: scheme),
                        const SizedBox(width: 10),
                        _TimeChip(label: s.end, value: sch.endTime?.format(context) ?? '--:--', scheme: scheme),
                      ]),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (i) {
                          final active = sch.days[i];
                          return Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: active ? scheme.primary : scheme.onSurface.withOpacity(0.07),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(dayLabels[i],
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                    color: active ? Colors.white : scheme.onSurface.withOpacity(0.35)))),
                          );
                        }),
                      ),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label, value; final ColorScheme scheme;
  const _TimeChip({required this.label, required this.value, required this.scheme});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: scheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Text('$label: ', style: TextStyle(fontSize: 12, color: scheme.onSurface.withOpacity(0.5))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: scheme.primary)),
      ]));
}
