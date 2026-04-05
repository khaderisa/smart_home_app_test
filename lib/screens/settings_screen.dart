import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../l10n/app_strings.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final s = AppStrings(provider.isArabic);
    final scheme = Theme.of(context).colorScheme;
    final isDark = provider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: scheme.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance
          _SectionTitle(s.appearance, scheme),
          const SizedBox(height: 10),
          _SettingCard(
            isDark: isDark,
            child: Row(
              children: [
                Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: scheme.primary),
                const SizedBox(width: 14),
                Expanded(child: Text(s.darkMode,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: scheme.onSurface))),
                Switch(value: isDark, onChanged: (_) => provider.toggleTheme(), activeColor: scheme.primary),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Language
          _SectionTitle(s.language, scheme),
          const SizedBox(height: 10),
          _SettingCard(
            isDark: isDark,
            child: Row(
              children: [
                Icon(Icons.language_rounded, color: scheme.primary),
                const SizedBox(width: 14),
                Expanded(child: Text(provider.isArabic ? 'العربية' : 'English',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: scheme.onSurface))),
                GestureDetector(
                  onTap: provider.toggleLanguage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      provider.isArabic ? 'English' : 'العربية',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Logout
          _SettingCard(
            isDark: isDark,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              ),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: Colors.red),
                  const SizedBox(width: 14),
                  Text(s.logOut,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),
          _SectionTitle(s.homesRoomsDevices, scheme),
          const SizedBox(height: 10),

          ...provider.homes.map((home) {
            return _SettingCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(home.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(home.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: scheme.onSurface))),
                      _EditIconButton(onTap: () => _showEditDialog(
                        context: context, s: s,
                        title: s.editHomeName, currentName: home.name,
                        onSave: (name) => provider.editHomeName(home.id, name),
                      )),
                    ],
                  ),
                  ...home.rooms.map((room) => Column(
                    children: [
                      const Divider(height: 20, indent: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(room.icon, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(room.name,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface))),
                                _EditIconButton(onTap: () => _showEditDialog(
                                  context: context, s: s,
                                  title: s.editRoomName, currentName: room.name,
                                  onSave: (name) => provider.editRoomName(home.id, room.id, name),
                                )),
                              ],
                            ),
                            ...room.devices.map((device) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.circle, size: 6, color: scheme.onSurface.withOpacity(0.3)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(device.name,
                                      style: TextStyle(fontSize: 13, color: scheme.onSurface.withOpacity(0.7)))),
                                  _EditIconButton(onTap: () => _showEditDialog(
                                    context: context, s: s,
                                    title: s.editDeviceName, currentName: device.name,
                                    onSave: (name) => provider.editDeviceName(home.id, room.id, device.id, name),
                                  )),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required AppStrings s,
    required String title,
    required String currentName,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: s.nameLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel, style: TextStyle(color: scheme.onSurface.withOpacity(0.5))),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSave(controller.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: Text(s.save),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ColorScheme scheme;
  const _SectionTitle(this.title, this.scheme);

  @override
  Widget build(BuildContext context) => Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: scheme.onSurface.withOpacity(0.4), letterSpacing: 1),
      );
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SettingCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
          ),
        ),
        child: child,
      );
}

class _EditIconButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Icon(Icons.edit_outlined, size: 18,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
      );
}
