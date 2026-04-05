import 'package:uuid/uuid.dart';
import 'device.dart';

class Room {
  final String id;
  String name;
  String icon;
  List<Device> devices;

  Room({
    String? id,
    required this.name,
    this.icon = '🏠',
    List<Device>? devices,
  })  : id = id ?? const Uuid().v4(),
        devices = devices ?? [];

  int get activeDevices => devices.where((d) => d.isOn).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'devices': devices.map((d) => d.toJson()).toList(),
      };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        devices: (json['devices'] as List)
            .map((d) => Device.fromJson(d))
            .toList(),
      );
}
