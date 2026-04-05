import 'dart:convert';
import 'package:http/http.dart' as http;

class DbService {
  static const String _url = 'http://localhost:8080';

  static Future<void> send(String type, Map<String, dynamic> data) async {
    try {
      await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': type,
          'timestamp': DateTime.now().toIso8601String(),
          ...data,
        }),
      );
    } catch (_) {
      // Server not running — fail silently
    }
  }
}
