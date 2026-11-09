import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared by assessment and roadmap entry points; manual replay stays available.
class ExamQuestionAudioSettings {
  const ExamQuestionAudioSettings({
    this._storage = const FlutterSecureStorage(),
  });

  static const storageKey = 'kindergarten_question_autoplay_enabled';
  final FlutterSecureStorage _storage;

  Future<bool> readEnabled() async {
    try {
      return await _storage.read(key: storageKey) != 'false';
    } catch (_) {
      return true;
    }
  }

  Future<void> saveEnabled(bool enabled) =>
      _storage.write(key: storageKey, value: '$enabled');
}
