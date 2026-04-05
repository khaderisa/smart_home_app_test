import 'package:uuid/uuid.dart';
import 'room.dart';

class Home {
  final String id;
  String name;
  String icon;
  List<Room> rooms;

  Home({
    String? id,
    required this.name,
    required this.icon,
    List<Room>? rooms,
  })  : id = id ?? const Uuid().v4(),
        rooms = rooms ?? [];

  int get activeDevices =>
      rooms.fold(0, (sum, r) => sum + r.activeDevices);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'rooms': rooms.map((r) => r.toJson()).toList(),
      };

  factory Home.fromJson(Map<String, dynamic> json) => Home(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        rooms: (json['rooms'] as List).map((r) => Room.fromJson(r)).toList(),
      );
}
