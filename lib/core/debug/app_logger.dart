import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Centralizes development diagnostics so console output remains searchable and
/// consistent across the app.
///
/// Regular diagnostic entries are emitted in debug and profile builds. Request
/// and response bodies are emitted only for `flutter run --debug`, where full
/// payload inspection is intentional.
class AppLogger {
  AppLogger._();

  static bool get isDiagnosticBuild => kDebugMode || kProfileMode;

  static void debug(String category, String message) {
    if (!kDebugMode) {
      return;
    }
    _write('DEBUG', category, message);
  }

  static void info(String category, String message) {
    if (!isDiagnosticBuild) {
      return;
    }
    _write('INFO', category, message);
  }

  static void warning(String category, String message) {
    if (!isDiagnosticBuild) {
      return;
    }
    _write('WARN', category, message);
  }

  static void error(
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!isDiagnosticBuild) {
      return;
    }

    final errorSuffix = error == null ? '' : ' error=$error';
    final stackSuffix = stackTrace == null ? '' : '\n$stackTrace';
    _write('ERROR', category, '$message$errorSuffix$stackSuffix');
  }

  /// Emits a complete, pretty-printed JSON payload in debug builds only.
  ///
  /// The payload deliberately remains a single log invocation: no artificial
  /// chunk markers or byte-based splitting are added.
  static void payload(String category, String label, Object? value) {
    if (!kDebugMode) {
      return;
    }
    _write('DEBUG', category, '$label\n${_prettyJson(value)}');
  }

  static String _prettyJson(Object? value) {
    final normalized = _decodeJsonString(value);
    try {
      return const JsonEncoder.withIndent('  ').convert(normalized);
    } catch (_) {
      return value.toString();
    }
  }

  static Object? _decodeJsonString(Object? value) {
    if (value is! String) {
      return value;
    }

    try {
      return jsonDecode(value);
    } on FormatException {
      return value;
    }
  }

  static void _write(String level, String category, String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('$timestamp [$level][$category] $message');
  }
}
