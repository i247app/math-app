import 'package:flutter_tts/flutter_tts.dart';
import 'package:numi/core/localization/app_language.dart';

enum QuestionSpeechResult { started, unavailable, cancelled }

String? questionSpeechLanguage({String? questionLang, String? examLang}) {
  for (final code in [questionLang, examLang]) {
    final parsed = AppLanguageCode.tryParse(code);
    if (parsed != null) return parsed.ttsCode;
  }
  return null;
}

/// The API supplies narration separately from the displayed question.
String? questionSpeechText(String text) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return normalized.isEmpty ? null : normalized;
}

class ExamQuestionSpeechService {
  FlutterTts? _tts;
  Future<void> _pending = Future<void>.value();
  int _revision = 0;
  bool _disposed = false;

  /// Serialize native commands and discard obsolete work after every await.
  /// Speaking returns when playback starts, so stopping never waits for narration.
  Future<QuestionSpeechResult> read(
    String text, {
    required String language,
    String? contentLanguage,
  }) {
    if (_disposed) return Future.value(QuestionSpeechResult.cancelled);
    final revision = ++_revision;
    final contentCode = AppLanguageCode.tryParse(contentLanguage)?.ttsCode;
    final appCode =
        (AppLanguageCode.tryParse(language) ?? AppLanguage.vi.localeCode)
            .ttsCode;
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
            contentCode ??
            (RegExp(
                  r'[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ]',
                  caseSensitive: false,
                ).hasMatch(spokenText)
                ? AppLanguage.vi.localeCode.ttsCode
                : appCode);
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
