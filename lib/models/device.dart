import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum DeviceType { light, plug, fan, ac }

class DeviceSchedule {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  List<bool> days;

  DeviceSchedule({
    this.startTime,
    this.endTime,
    List<bool>? days,
  }) : days = days ?? List.filled(7, false);

  Map<String, dynamic> toJson() => {
        'startHour': startTime?.hour,
        'startMinute': startTime?.minute,
        'endHour': endTime?.hour,
        'endMinute': endTime?.minute,
        'days': days,
      };

  factory DeviceSchedule.fromJson(Map<String, dynamic> json) => DeviceSchedule(
        startTime: json['startHour'] != null
            ? TimeOfDay(hour: json['startHour'], minute: json['startMinute'])
            : null,
        endTime: json['endHour'] != null
            ? TimeOfDay(hour: json['endHour'], minute: json['endMinute'])
            : null,
        days: List<bool>.from(json['days'] ?? List.filled(7, false)),
      );
}

class UsageEvent {
  final DateTime timestamp;
  final bool turnedOn; // true = turned on, false = turned off

  UsageEvent({required this.timestamp, required this.turnedOn});

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'turnedOn': turnedOn,
      };

  factory UsageEvent.fromJson(Map<String, dynamic> json) => UsageEvent(
        timestamp: DateTime.parse(json['timestamp']),
        turnedOn: json['turnedOn'],
      );
}

class Device {
  final String id;
  String name;
  DeviceType type;
  bool isOn;
  DeviceSchedule schedule;
  List<UsageEvent> usageLog;

  Device({
    String? id,
    required this.name,
    required this.type,
    this.isOn = false,
    DeviceSchedule? schedule,
    List<UsageEvent>? usageLog,
  })  : id = id ?? const Uuid().v4(),
        schedule = schedule ?? DeviceSchedule(),
        usageLog = usageLog ?? [];

  // Total ON hours within a date range
  double hoursOnInRange(DateTime from, DateTime to) {
    double total = 0;
    DateTime? lastOn;
    final events = usageLog
        .where((e) => e.timestamp.isAfter(from) && e.timestamp.isBefore(to))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // If device was already on before range start
    if (isOn && events.isEmpty) {
      // Currently on, no events in range — count full range
      // Actually we don't know when it was turned on, skip
    }

    for (final event in events) {
      if (event.turnedOn) {
        lastOn = event.timestamp;
      } else if (lastOn != null) {
        total += event.timestamp.difference(lastOn!).inMinutes / 60.0;
        lastOn = null;
      }
    }

    // If still on at end of range
    if (lastOn != null) {
      final end = to.isBefore(DateTime.now()) ? to : DateTime.now();
      total += end.difference(lastOn!).inMinutes / 60.0;
    }

    return total;
  }

  // Toggle count within range
  int toggleCountInRange(DateTime from, DateTime to) {
    return usageLog
        .where((e) => e.timestamp.isAfter(from) && e.timestamp.isBefore(to))
        .length;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.index,
        'isOn': isOn,
        'schedule': schedule.toJson(),
        'usageLog': usageLog.map((e) => e.toJson()).toList(),
      };

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'],
        name: json['name'],
        type: DeviceType.values[json['type']],
        isOn: json['isOn'],
        schedule: json['schedule'] != null
            ? DeviceSchedule.fromJson(json['schedule'])
            : null,
        usageLog: json['usageLog'] != null
            ? (json['usageLog'] as List)
                .map((e) => UsageEvent.fromJson(e))
                .toList()
            : [],
      );
}
