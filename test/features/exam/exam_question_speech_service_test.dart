import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_question_speech_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  final calls = <MethodCall>[];
  late ExamQuestionSpeechService speech;
  Future<Object?> Function(MethodCall)? handler;

  setUp(() {
    calls.clear();
    handler = null;
    speech = ExamQuestionSpeechService();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (handler != null) return handler!(call);
          return call.method == 'isLanguageAvailable' ? true : 1;
        });
  });

  tearDown(() async {
    speech.dispose();
    await speech.stop();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('keeps natural wording and blocks emoji, LaTeX and math-only text', () {
    expect(
      questionSpeechText('  Con hãy\nđếm số quả táo.  '),
      'Con hãy đếm số quả táo.',
    );
    for (final text in [
      '',
      '🍎🍎',
      '4 ? 6',
      '2 + 3 = ?',
      r'Tính $\frac{1}{2}$',
      'Con đếm 🍎 nhé',
      '1️⃣2️⃣',
    ]) {
      expect(questionSpeechText(text), isNull, reason: text);
    }
    expect(questionSpeechText(' \n '), isNull);
  });

  test(
    'uses question grade before paper grade and preserves unknown grades',
    () {
      expect(questionSpeechGrade(questionGrade: 0, examGrade: 2), 0);
      expect(questionSpeechGrade(questionGrade: 2, examGrade: 0), 2);
      expect(questionSpeechGrade(questionGrade: null, examGrade: 0), 0);
      expect(questionSpeechGrade(questionGrade: null, examGrade: null), isNull);
    },
  );

  test('reads Vietnamese wording with a slower Vietnamese voice', () async {
    expect(
      await speech.read('Con hãy đếm số quả táo.', language: 'en-US'),
      QuestionSpeechResult.started,
    );
    expect(calls.first.method, 'stop');
    expect(
      calls.firstWhere((c) => c.method == 'setLanguage').arguments,
      'vi-VN',
    );
    expect(calls.firstWhere((c) => c.method == 'setSpeechRate').arguments, 0.4);
    expect(calls.last.method, 'speak');
    expect(calls.last.arguments, 'Con hãy đếm số quả táo.');
  });

  test('uses API language for text without Vietnamese diacritics', () async {
    await speech.read('Count the apples.', language: 'en-US');
    expect(
      calls.firstWhere((c) => c.method == 'setLanguage').arguments,
      'en-US',
    );
  });

  test('does not speak using a wrong or missing language', () async {
    handler = (call) async => call.method == 'isLanguageAvailable' ? false : 1;
    expect(
      await speech.read('Count the apples.', language: 'en-US'),
      QuestionSpeechResult.unavailable,
    );
    expect(calls.where((c) => c.method == 'speak'), isEmpty);
  });

  test('platform failures do not escape into exam flow', () async {
    handler = (_) async => throw PlatformException(code: 'engine_unavailable');
    expect(
      await speech.read('Count the apples.', language: 'en-US'),
      QuestionSpeechResult.unavailable,
    );
    await speech.stop();
  });

  test('stop cancels a prompt that is still preparing its voice', () async {
    final voiceCheck = Completer<Object?>();
    final checking = Completer<void>();
    handler = (call) async {
      if (call.method == 'isLanguageAvailable') {
        checking.complete();
        return voiceCheck.future;
      }
      return 1;
    };
    final reading = speech.read('Count the apples.', language: 'en-US');
    await checking.future;
    final stopped = speech.stop();
    voiceCheck.complete(true);
    expect(await reading, QuestionSpeechResult.cancelled);
    await stopped;
    expect(calls.where((c) => c.method == 'speak'), isEmpty);
    expect(calls.last.method, 'stop');
  });

  test(
    'a new question replaces pending narration instead of queueing it',
    () async {
      final voiceCheck = Completer<Object?>();
      final checking = Completer<void>();
      handler = (call) async {
        if (call.method == 'isLanguageAvailable' && !checking.isCompleted) {
          checking.complete();
          return voiceCheck.future;
        }
        return call.method == 'isLanguageAvailable' ? true : 1;
      };
      final first = speech.read('Count the apples.', language: 'en-US');
      await checking.future;
      final second = speech.read('Select the circle.', language: 'en-US');
      voiceCheck.complete(true);
      expect(await first, QuestionSpeechResult.cancelled);
      expect(await second, QuestionSpeechResult.started);
      expect(calls.where((c) => c.method == 'speak').map((c) => c.arguments), [
        'Select the circle.',
      ]);
    },
  );

  test('disposal cancels setup and rejects later reads', () async {
    speech.dispose();
    expect(
      await speech.read('Count the apples.', language: 'en-US'),
      QuestionSpeechResult.cancelled,
    );
    expect(calls, isEmpty);
  });
}
