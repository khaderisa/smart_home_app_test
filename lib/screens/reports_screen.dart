import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../models/device.dart';
import '../models/home.dart';
import '../l10n/app_strings.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedDeviceId;
  int _selectedPeriodIndex = 0;
  bool _showReport = false;

  DateTime _fromDate(AppStrings s) {
    final now = DateTime.now();
    switch (_selectedPeriodIndex) {
      case 0: return DateTime(now.year, now.month, now.day);
      case 1: return now.subtract(const Duration(days: 7));
      case 2: return now.subtract(const Duration(days: 30));
      case 3: return DateTime(2000);
      default: return DateTime(now.year, now.month, now.day);
    }
  }

  List<Map<String, dynamic>> _allDevices(List<Home> homes) {
    final List<Map<String, dynamic>> result = [];
    for (final home in homes) {
      for (final room in home.rooms) {
        for (final device in room.devices) {
          result.add({
            'homeId': home.id,
            'homeName': home.name,
            'homeIcon': home.icon,
            'roomName': room.name,
            'device': device,
          });
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final s = AppStrings(provider.isArabic);
    final scheme = Theme.of(context).colorScheme;
    final isDark = provider.isDark;
    final allDevices = _allDevices(provider.homes);
    final periods = [s.today, s.last7Days, s.last30Days, s.allTime];

    Map<String, dynamic>? selectedEntry;
    if (_selectedDeviceId != null) {
      try {
        selectedEntry = allDevices.firstWhere(
            (e) => (e['device'] as Device).id == _selectedDeviceId);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.myReports,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: scheme.onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device dropdown
            _SectionLabel(label: s.allDevices, scheme: scheme),
            const SizedBox(height: 8),
            _DropdownCard(
              isDark: isDark, scheme: scheme,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedDeviceId,
                  hint: Text(s.selectDevice,
                      style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
                  dropdownColor: isDark ? const Color(0xFF1C2128) : Colors.white,
                  items: allDevices.map((entry) {
                    final device = entry['device'] as Device;
                    return DropdownMenuItem<String>(
                      value: device.id,
                      child: Text(
                        '${entry['homeIcon']} ${entry['homeName']} · ${entry['roomName']} · ${device.name}',
                        style: TextStyle(fontSize: 14, color: scheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() { _selectedDeviceId = val; _showReport = false; }),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Time period dropdown
            _SectionLabel(label: s.timePeriod, scheme: scheme),
            const SizedBox(height: 8),
            _DropdownCard(
              isDark: isDark, scheme: scheme,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedPeriodIndex,
                  dropdownColor: isDark ? const Color(0xFF1C2128) : Colors.white,
                  items: List.generate(periods.length, (i) => DropdownMenuItem(
                    value: i,
                    child: Text(periods[i], style: TextStyle(fontSize: 14, color: scheme.onSurface)),
                  )),
                  onChanged: (val) => setState(() { _selectedPeriodIndex = val!; _showReport = false; }),
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _selectedDeviceId == null ? null : () => setState(() => _showReport = true),
                icon: const Icon(Icons.bar_chart_rounded),
                label: Text(s.generateReport,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),

            if (_showReport && selectedEntry != null) ...[
              const SizedBox(height: 28),
              _buildReport(context, selectedEntry, scheme, isDark, s, periods),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReport(BuildContext context, Map<String, dynamic> entry,
      ColorScheme scheme, bool isDark, AppStrings s, List<String> periods) {
    final device = entry['device'] as Device;
    final from = _fromDate(s);
    final to = DateTime.now();
    final hours = device.hoursOnInRange(from, to);
    final toggles = device.toggleCountInRange(from, to);
    final onCount = device.usageLog.where((e) => e.timestamp.isAfter(from) && e.timestamp.isBefore(to) && e.turnedOn).length;
    final offCount = toggles - onCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${s.report} · ${periods[_selectedPeriodIndex]}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: scheme.onSurface)),
        const SizedBox(height: 4),
        Text('${entry['homeIcon']} ${entry['homeName']} · ${entry['roomName']} · ${device.name}',
            style: TextStyle(fontSize: 13, color: scheme.onSurface.withOpacity(0.45))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.timer_outlined, label: s.hoursOn, value: hours.toStringAsFixed(1), unit: s.hrs, color: scheme.primary, isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.swap_vert_rounded, label: s.totalToggles, value: '$toggles', unit: s.times, color: const Color(0xFF4CAF82), isDark: isDark)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.power_settings_new_rounded, label: s.turnedOn, value: '$onCount', unit: s.times, color: const Color(0xFFFFB800), isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.power_off_outlined, label: s.turnedOff, value: '$offCount', unit: s.times, color: Colors.red.shade400, isDark: isDark)),
          ],
        ),
        if (toggles == 0) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: scheme.onSurface.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: scheme.onSurface.withOpacity(0.4), size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(s.noUsageData, style: TextStyle(fontSize: 13, color: scheme.onSurface.withOpacity(0.5)))),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label; final ColorScheme scheme;
  const _SectionLabel({required this.label, required this.scheme});
  @override
  Widget build(BuildContext context) => Text(label,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurface.withOpacity(0.5), letterSpacing: 0.5));
}

class _DropdownCard extends StatelessWidget {
  final Widget child; final bool isDark; final ColorScheme scheme;
  const _DropdownCard({required this.child, required this.isDark, required this.scheme});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
      ),
      child: child);
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label, value, unit; final Color color; final bool isDark;
  const _StatCard({required this.icon, required this.label, required this.value, required this.unit, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        Text(unit, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
      ]));
}
