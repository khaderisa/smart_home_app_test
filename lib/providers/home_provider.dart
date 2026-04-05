import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/home.dart';
import '../models/room.dart';
import '../models/device.dart';
import '../services/db_service.dart';

class HomeProvider extends ChangeNotifier {
  List<Home> _homes = [];
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  List<Home> get homes => _homes;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  HomeProvider() {
    _loadData();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveState();
    notifyListeners();
  }

  // ── Homes ──
  void addHome(String name, String icon) {
    _homes.add(Home(name: name, icon: icon));
    _saveState();
    notifyListeners();
  }

  void deleteHome(String homeId) {
    _homes.removeWhere((h) => h.id == homeId);
    _saveState();
    notifyListeners();
  }

  Home getHome(String homeId) => _homes.firstWhere((h) => h.id == homeId);

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    _saveState();
    notifyListeners();
  }

  // ── Name edits ──
  void editHomeName(String homeId, String name) {
    getHome(homeId).name = name;
    DbService.send('edit_home', {'homeId': homeId, 'newName': name});
    _saveState();
    notifyListeners();
  }

  void editRoomName(String homeId, String roomId, String name) {
    getHome(homeId).rooms.firstWhere((r) => r.id == roomId).name = name;
    DbService.send('edit_room', {'homeId': homeId, 'roomId': roomId, 'newName': name});
    _saveState();
    notifyListeners();
  }

  void editDeviceName(String homeId, String roomId, String deviceId, String name) {
    final room = getHome(homeId).rooms.firstWhere((r) => r.id == roomId);
    room.devices.firstWhere((d) => d.id == deviceId).name = name;
    DbService.send('edit_device', {'homeId': homeId, 'roomId': roomId, 'deviceId': deviceId, 'newName': name});
    _saveState();
    notifyListeners();
  }

  // ── Rooms ──
  void addRoom(String homeId, String name, String icon) {
    getHome(homeId).rooms.add(Room(name: name, icon: icon));
    _saveState();
    notifyListeners();
  }

  void editRoom(String homeId, String roomId, String name, String icon) {
    final room = getHome(homeId).rooms.firstWhere((r) => r.id == roomId);
    room.name = name;
    room.icon = icon;
    _saveState();
    notifyListeners();
  }

  void deleteRoom(String homeId, String roomId) {
    getHome(homeId).rooms.removeWhere((r) => r.id == roomId);
    _saveState();
    notifyListeners();
  }

  // ── Devices ──
  void addDevice(String homeId, String roomId, String name, DeviceType type) {
    final room = getHome(homeId).rooms.firstWhere((r) => r.id == roomId);
    room.devices.add(Device(name: name, type: type));
    _saveState();
    notifyListeners();
  }

  void editDevice(String homeId, String roomId, String deviceId, String name, DeviceType type) {
    final room = getHome(homeId).rooms.firstWhere((r) => r.id == roomId);
    final device = room.devices.firstWhere((d) => d.id == deviceId);
    device.name = name;
    device.type = type;
    _saveState();
    notifyListeners();
  }

  void deleteDevice(String homeId, String roomId, String deviceId) {
    final room = getHome(homeId).rooms.firstWhere((r) => r.id == roomId);
    room.devices.removeWhere((d) => d.id == deviceId);
    _saveState();
    notifyListeners();
  }

  void toggleDevice(String homeId, String roomId, String deviceId) {
    final room = getHome(homeId).rooms.firstWhere((r) => r.id == roomId);
    final device = room.devices.firstWhere((d) => d.id == deviceId);
    device.isOn = !device.isOn;
    device.usageLog.add(UsageEvent(
      timestamp: DateTime.now(),
      turnedOn: device.isOn,
    ));
    DbService.send('toggle', {
      'homeId': homeId,
      'roomId': roomId,
      'deviceId': deviceId,
      'deviceName': device.name,
      'isOn': device.isOn,
    });
    _saveState();
    notifyListeners();
  }

  void clearDeviceSchedule(String homeId, String roomId, String deviceId) {
    final room = getHome(homeId).rooms.firstWhere((r) => r.id == roomId);
    final device = room.devices.firstWhere((d) => d.id == deviceId);
    device.schedule = DeviceSchedule();
    DbService.send('clear_schedule', {'homeId': homeId, 'roomId': roomId, 'deviceId': deviceId, 'deviceName': device.name});
    _saveState();
    notifyListeners();
  }

  void updateDeviceSchedule(String homeId, String roomId, String deviceId, DeviceSchedule schedule) {
    final room = getHome(homeId).rooms.firstWhere((r) => r.id == roomId);
    final device = room.devices.firstWhere((d) => d.id == deviceId);
    device.schedule = schedule;
    DbService.send('schedule', {
      'homeId': homeId,
      'roomId': roomId,
      'deviceId': deviceId,
      'deviceName': device.name,
      'schedule': schedule.toJson(),
    });
    _saveState();
    notifyListeners();
  }

  // ── Load ──
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('theme');
    final savedState = prefs.getString('homes_state');

    // Load from JSON asset
    final jsonStr = await rootBundle.loadString('assets/data.json');
    final jsonData = jsonDecode(jsonStr);
    _homes = (jsonData['homes'] as List).map((h) => Home.fromJson(h)).toList();

    // Apply saved state on top
    if (savedState != null) {
      final List stateList = jsonDecode(savedState);
      final Map<String, dynamic> savedMap = {
        for (var h in stateList) h['id']: h
      };

      for (final home in _homes) {
        if (savedMap.containsKey(home.id)) {
          final savedHome = savedMap[home.id];
          home.name = savedHome['name'] ?? home.name;
          home.icon = savedHome['icon'] ?? home.icon;

          final Map<String, dynamic> roomMap = {
            for (var r in (savedHome['rooms'] as List)) r['id']: r
          };
          for (final room in home.rooms) {
            if (roomMap.containsKey(room.id)) {
              final savedRoom = roomMap[room.id];
              room.name = savedRoom['name'] ?? room.name;
              room.icon = savedRoom['icon'] ?? room.icon;
              final Map<String, dynamic> devMap = {
                for (var d in (savedRoom['devices'] as List)) d['id']: d
              };
              for (final device in room.devices) {
                if (devMap.containsKey(device.id)) {
                  device.isOn = devMap[device.id]['isOn'] ?? false;
                  if (devMap[device.id]['schedule'] != null) {
                    device.schedule = DeviceSchedule.fromJson(devMap[device.id]['schedule']);
                  }
                }
              }
            }
          }
        }
      }

      // Add user-created homes not in JSON
      final jsonIds = _homes.map((h) => h.id).toSet();
      for (final savedHome in stateList) {
        if (!jsonIds.contains(savedHome['id'])) {
          _homes.add(Home.fromJson(savedHome));
        }
      }
    }

    // Load initial schedules from JSON asset
    final schedJson = await rootBundle.loadString('assets/schedules.json');
    final schedData = jsonDecode(schedJson);
    for (final s in schedData['schedules'] as List) {
      try {
        final home = _homes.firstWhere((h) => h.id == s['homeId']);
        final room = home.rooms.firstWhere((r) => r.id == s['roomId']);
        final device = room.devices.firstWhere((d) => d.id == s['deviceId']);
        // Only apply if no saved state already has a schedule
        if (device.schedule.startTime == null && device.schedule.endTime == null) {
          device.schedule = DeviceSchedule(
            startTime: TimeOfDay(hour: s['startHour'], minute: s['startMinute']),
            endTime: TimeOfDay(hour: s['endHour'], minute: s['endMinute']),
            days: List<bool>.from(s['days']),
          );
        }
      } catch (_) {}
    }

    if (themeStr != null) {
      _themeMode = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
    final localeStr = prefs.getString('locale');
    if (localeStr != null) {
      _locale = Locale(localeStr);
    }

    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('homes_state', jsonEncode(_homes.map((h) => h.toJson()).toList()));
    await prefs.setString('theme', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    await prefs.setString('locale', _locale.languageCode);
  }
}
