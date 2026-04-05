import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../models/room.dart';
import '../models/device.dart';

class RoomScreen extends StatelessWidget {
  final Room room;
  final String homeId;
  const RoomScreen({super.key, required this.room, required this.homeId});

  IconData _deviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.light: return Icons.lightbulb_outline_rounded;
      case DeviceType.plug:  return Icons.power_outlined;
      case DeviceType.fan:   return Icons.air_rounded;
      case DeviceType.ac:    return Icons.ac_unit_rounded;
    }
  }

  Color _deviceColor(DeviceType type, ColorScheme scheme) {
    switch (type) {
      case DeviceType.light: return const Color(0xFFFFB800);
      case DeviceType.plug:  return scheme.primary;
      case DeviceType.fan:   return const Color(0xFF00BCD4);
      case DeviceType.ac:    return const Color(0xFF4CAF82);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<HomeProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(room.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(room.name,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: room.activeDevices > 0
                    ? scheme.primary.withOpacity(0.12)
                    : scheme.onSurface.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${room.activeDevices} on',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: room.activeDevices > 0
                        ? scheme.primary
                        : scheme.onSurface.withOpacity(0.4)),
              ),
            ),
          ),
        ],
      ),
      body: room.devices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_other_rounded,
                      size: 72, color: scheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('No devices',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface.withOpacity(0.4))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: room.devices.length,
              itemBuilder: (context, index) {
                final device = room.devices[index];
                return _DeviceCard(
                  device: device,
                  room: room,
                  homeId: homeId,
                  deviceIcon: _deviceIcon(device.type),
                  deviceColor: _deviceColor(device.type, scheme),
                );
              },
            ),
    );
  }
}

// ── Scheduler Dialog ──────────────────────────────────────────────────────────

void _showSchedulerDialog(BuildContext context, Device device, Room room, String homeId) {
  final provider = context.read<HomeProvider>();
  final schedule = DeviceSchedule(
    startTime: device.schedule.startTime,
    endTime: device.schedule.endTime,
    days: List<bool>.from(device.schedule.days),
  );
  const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) {
        final scheme = Theme.of(ctx).colorScheme;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        String fmt(TimeOfDay? t) => t == null ? '--:--' : t.format(ctx);

        Future<void> pickTime(bool isStart) async {
          final picked = await showTimePicker(
            context: ctx,
            initialTime: (isStart ? schedule.startTime : schedule.endTime) ?? TimeOfDay.now(),
            initialEntryMode: TimePickerEntryMode.input,
          );
          if (picked != null) {
            setModalState(() {
              if (isStart) schedule.startTime = picked;
              else schedule.endTime = picked;
            });
          }
        }

        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24, left: 24, right: 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Schedule — ${device.name}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: scheme.onSurface)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _TimePicker(label: 'Start', time: fmt(schedule.startTime), onTap: () => pickTime(true), scheme: scheme)),
                  const SizedBox(width: 12),
                  Expanded(child: _TimePicker(label: 'End', time: fmt(schedule.endTime), onTap: () => pickTime(false), scheme: scheme)),
                ],
              ),
              const SizedBox(height: 20),
              Text('Repeat',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurface.withOpacity(0.5), letterSpacing: 0.5)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final active = schedule.days[i];
                  return GestureDetector(
                    onTap: () => setModalState(() => schedule.days[i] = !schedule.days[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: active ? scheme.primary : scheme.onSurface.withOpacity(0.07),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(dayLabels[i],
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: active ? Colors.white : scheme.onSurface.withOpacity(0.4))),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.clearDeviceSchedule(homeId, room.id, device.id);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                      label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(0, 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.updateDeviceSchedule(homeId, room.id, device.id, schedule);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
                      child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _TimePicker extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _TimePicker({required this.label, required this.time, required this.onTap, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.onSurface.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: scheme.onSurface.withOpacity(0.45), fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(time, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: scheme.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Device Card ───────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final Device device;
  final Room room;
  final String homeId;
  final IconData deviceIcon;
  final Color deviceColor;

  const _DeviceCard({
    required this.device,
    required this.room,
    required this.homeId,
    required this.deviceIcon,
    required this.deviceColor,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasSchedule = device.schedule.startTime != null ||
        device.schedule.endTime != null ||
        device.schedule.days.any((d) => d);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: device.isOn ? deviceColor.withOpacity(0.4) : isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
            width: device.isOn ? 1.5 : 1,
          ),
          boxShadow: device.isOn
              ? [BoxShadow(color: deviceColor.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: device.isOn ? deviceColor.withOpacity(0.15) : scheme.onSurface.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(deviceIcon,
                  color: device.isOn ? deviceColor : scheme.onSurface.withOpacity(0.3), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: scheme.onSurface)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(device.type.name.toUpperCase(),
                          style: TextStyle(fontSize: 11, color: scheme.onSurface.withOpacity(0.35), letterSpacing: 0.8, fontWeight: FontWeight.w500)),
                      if (hasSchedule) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.schedule_rounded, size: 12, color: scheme.primary),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert_rounded, color: scheme.onSurface.withOpacity(0.4), size: 20),
              onPressed: () => _showSchedulerDialog(context, device, room, homeId),
              splashRadius: 20,
            ),
            GestureDetector(
              onTap: () => provider.toggleDevice(homeId, room.id, device.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 56, height: 30,
                decoration: BoxDecoration(
                  color: device.isOn ? deviceColor : scheme.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: device.isOn ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 24, height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
