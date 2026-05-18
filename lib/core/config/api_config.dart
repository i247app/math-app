import 'package:flutter/services.dart';

abstract final class ApiConfig {
  static Map<String, String> _values = const {};

  static String get baseUrl => _values['API_BASE_URL'] ?? '';

  static Future<void> load() async {
    try {
      final content = await rootBundle.loadString('.env');
      _values = _parse(content);
    } catch (_) {
      _values = const {};
    }
  }

  static Map<String, String> _parse(String content) {
    final values = <String, String>{};

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }

      final separatorIndex = line.indexOf('=');
      if (separatorIndex <= 0) {
        continue;
      }

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();
      values[key] = _stripQuotes(value);
    }

    return values;
  }

  static String _stripQuotes(String value) {
    if (value.length < 2) {
      return value;
    }

    final first = value[0];
    final last = value[value.length - 1];
    if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
      return value.substring(1, value.length - 1);
    }

    return value;
  }
}
