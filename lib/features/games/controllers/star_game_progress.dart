import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:numi/features/games/models/star_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StarGameProgress extends ChangeNotifier {
  StarGameProgress(this.storageKey) : loading = storageKey != null {
    if (loading) unawaited(_load());
  }

  final String? storageKey;
  final _records = <StarGameLevel, StarGameRecord>{};
  SharedPreferences? _preferences;
  Future<void> _pendingWrite = Future.value();
  bool _disposed = false;
  bool loading;
  bool saveFailed = false;

  StarGameRecord? best(StarGameLevel level) => _records[level];

  bool isUnlocked(StarGameLevel level) => StarGameLevel.values
      .take(level.index)
      .every((prior) => (_records[prior]?.stars ?? 0) > 0);

  bool record(StarGameLevel level, StarGameRecord result) {
    final previous = best(level);
    if (previous != null && !result.beats(previous)) return false;
    _records[level] = result;
    retrySave();
    notifyListeners();
    return true;
  }

  void retrySave() {
    if (storageKey == null) return;
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        final preferences = _preferences ?? await _readPreferences();
        final snapshot = {
          for (final entry in _records.entries)
            entry.key.name: entry.value.toJson(),
        };
        saveFailed = !await preferences.setString(
          storageKey!,
          jsonEncode(snapshot),
        );
      } catch (_) {
        saveFailed = true;
      }
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> _load() async {
    try {
      await _readPreferences();
    } catch (_) {
      saveFailed = true;
    }
    loading = false;
    if (!_disposed) notifyListeners();
  }

  Future<SharedPreferences> _readPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.get(storageKey!);
    if (stored is String) {
      try {
        final decoded = jsonDecode(stored);
        if (decoded is Map) {
          for (final level in StarGameLevel.values) {
            final record = StarGameRecord.fromJson(decoded[level.name]);
            final current = best(level);
            if (record != null && (current == null || record.beats(current))) {
              _records[level] = record;
            }
          }
        }
      } on FormatException {
        // A malformed saved round must not prevent new rounds.
      }
    }
    _preferences = preferences;
    return preferences;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
