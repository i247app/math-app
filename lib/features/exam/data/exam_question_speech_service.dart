import 'package:flutter_tts/flutter_tts.dart';

enum QuestionSpeechResult { started, unavailable, cancelled }

/// Uses the API's wording without inferring objects, answers or missing numbers.
String? questionSpeechText(String text) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (!RegExp(r'\p{L}{2,}', unicode: true).hasMatch(normalized) ||
      RegExp(
        <String>[
          r'[\\$]',
          r'\p{Extended_Pictographic}',
          r'\p{Regional_Indicator}',
          r'\u20E3',
        ].join('|'),
        unicode: true,
      ).hasMatch(normalized)) {
    return null;
  }
  return normalized;
}

int? questionSpeechGrade({
  required int? questionGrade,
  required int? examGrade,
}) => questionGrade ?? examGrade;

class ExamQuestionSpeechService {
  FlutterTts? _tts;
  Future<void> _pending = Future<void>.value();
  int _revision = 0;
  bool _disposed = false;

  /// Serialize native commands and discard obsolete work after every await.
  /// Speaking returns when playback starts, so stopping never waits for narration.
  Future<QuestionSpeechResult> read(String text, {required String language}) {
    if (_disposed) return Future.value(QuestionSpeechResult.cancelled);
    final revision = ++_revision;
    final spokenText = questionSpeechText(text);
    final result = _pending.then((_) async {
      bool isCurrent() => !_disposed && revision == _revision;
      if (!isCurrent()) return QuestionSpeechResult.cancelled;
      try {
        final tts = _tts ??= FlutterTts();
        await tts.stop();
        if (!isCurrent()) return QuestionSpeechResult.cancelled;
        if (spokenText == null) return QuestionSpeechResult.unavailable;
        final locale =
            RegExp(
              r'[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ]',
              caseSensitive: false,
            ).hasMatch(spokenText)
            ? 'vi-VN'
            : language;
        final available = await tts.isLanguageAvailable(locale);
        if (!isCurrent()) return QuestionSpeechResult.cancelled;
        if (available != true && available != 1) {
          return QuestionSpeechResult.unavailable;
        }
        final languageResult = await tts.setLanguage(locale);
        if (!isCurrent()) return QuestionSpeechResult.cancelled;
        if (languageResult == 0) return QuestionSpeechResult.unavailable;
        await tts.setSpeechRate(0.4);
        if (!isCurrent()) return QuestionSpeechResult.cancelled;
        await tts.awaitSpeakCompletion(false);
        if (!isCurrent()) return QuestionSpeechResult.cancelled;
        final started = await tts.speak(spokenText, focus: true);
        if (!isCurrent()) return QuestionSpeechResult.cancelled;
        return started == 1
            ? QuestionSpeechResult.started
            : QuestionSpeechResult.unavailable;
      } catch (_) {
        // Missing voices or a platform engine must not block the exam.
        return isCurrent()
            ? QuestionSpeechResult.unavailable
            : QuestionSpeechResult.cancelled;
      }
    });
    _pending = result.then((_) {});
    return result;
  }

  Future<void> stop() {
    ++_revision;
    return _pending = _pending.then((_) async {
      try {
        await _tts?.stop();
      } catch (_) {
        // Stopping is best effort if the platform engine has disappeared.
      }
    });
  }

  void dispose() {
    _disposed = true;
    stop();
  }
}
