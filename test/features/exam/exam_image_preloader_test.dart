import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_image_preloader.dart';
import 'package:numi/features/exam/models/exam.dart';

void main() {
  testWidgets('prepares all fifty images of ten questions before opening', (
    tester,
  ) async {
    final pending = <String, Completer<void>>{};
    var active = 0;
    var peak = 0;
    final preloader = ExamImagePreloader(
      load: (url) {
        active++;
        if (active > peak) peak = active;
        final done = pending[url] = Completer<void>();
        return done.future.whenComplete(() => active--);
      },
    );
    final exam = GeneratedExam(
      examId: 1,
      questions: [
        for (var i = 0; i < 10; i++)
          ExamQuestion(
            questionText: 'Question $i',
            questionNumber: i + 1,
            questionImageUrl: 'stem-$i',
            options: [
              for (var j = 0; j < 4; j++)
                ExamAnswer(id: '$j', text: '', imageUrl: 'option-$i-$j'),
            ],
          ),
      ],
    );
    preloader.update(exam, 0);
    expect(pending.keys, ['stem-0', 'option-0-0', 'option-0-1']);
    expect(preloader.isPreparingSet, isTrue);
    for (var completed = 0; completed < 49; completed++) {
      pending.values.firstWhere((value) => !value.isCompleted).complete();
      await tester.pump();
    }
    expect(pending, hasLength(50));
    expect(preloader.isPreparingSet, isTrue);
    pending.values.last.complete();
    await tester.pump();
    expect(preloader.isPreparingSet, isFalse);
    expect(peak, 3);
    final count = pending.length;
    preloader.update(exam, 9);
    expect(pending.length, count);
    preloader.dispose();
  });

  testWidgets(
    'resume prioritizes the saved question but prepares the entire set',
    (tester) async {
      final started = <String>[];
      final preloader = ExamImagePreloader(
        load: (url) async => started.add(url),
      );
      preloader.update(
        GeneratedExam(
          examId: 1,
          questions: [
            for (var i = 0; i < 10; i++) _question('image-$i', i + 1),
          ],
        ),
        7,
      );
      await tester.pump();
      expect(started.first, 'image-7');
      expect(started.toSet(), {for (var i = 0; i < 10; i++) 'image-$i'});
      expect(preloader.isPreparingSet, isFalse);
      preloader.dispose();
    },
  );

  testWidgets(
    'acquires shared assets before releasing old set and clears on exit',
    (tester) async {
      final events = <String>[];
      final loaded = <String>[];
      final preloader = ExamImagePreloader(
        load: (url) async => loaded.add(url),
        retain: (url, dimension) => events.add('retain:$url'),
        release: (url) async => events.add('release:$url'),
      );
      preloader.update(
        GeneratedExam(
          examId: 1,
          questions: [_question('old', 1), _question('shared', 2)],
        ),
        0,
      );
      await tester.pump();
      preloader.update(
        GeneratedExam(
          examId: 2,
          questions: [_question('shared', 1), _question('new', 2)],
        ),
        0,
      );
      await tester.pump();
      expect(events, [
        'retain:old',
        'retain:shared',
        'retain:new',
        'release:old',
      ]);
      expect(loaded.where((url) => url == 'shared'), hasLength(1));
      preloader.dispose();
      await tester.pump();
      expect(events.skip(4), ['release:shared', 'release:new']);
    },
  );

  testWidgets('a new set drops queued old URLs and ignores late completions', (
    tester,
  ) async {
    final pending = <String, Completer<void>>{};
    final preloader = ExamImagePreloader(
      load: (url) => (pending[url] = Completer<void>()).future,
    );
    preloader.update(
      GeneratedExam(
        examId: 1,
        questions: [for (var i = 0; i < 4; i++) _question('old-$i', i + 1)],
      ),
      0,
    );
    preloader.update(
      GeneratedExam(examId: 2, questions: [_question('new', 1)]),
      0,
    );
    pending['old-0']!.complete();
    await tester.pump();
    expect(pending, contains('new'));
    expect(pending, isNot(contains('old-3')));
    pending['new']!.complete();
    await tester.pump();
    expect(preloader.isPreparingSet, isFalse);
    preloader.dispose();
    pending['old-1']!.complete();
    pending['old-2']!.complete();
    await tester.pump();
  });

  testWidgets(
    'loading has a fifteen-second ceiling and queued images continue',
    (tester) async {
      final pending = <String, Completer<void>>{};
      final preloader = ExamImagePreloader(
        load: (url) => (pending[url] = Completer<void>()).future,
      );
      preloader.update(
        GeneratedExam(
          examId: 1,
          questions: [for (var i = 0; i < 4; i++) _question('image-$i', i + 1)],
        ),
        0,
      );
      await tester.pump(const Duration(milliseconds: 14999));
      expect(preloader.isPreparingSet, isTrue);
      await tester.pump(const Duration(milliseconds: 1));
      expect(preloader.isPreparingSet, isFalse);
      pending['image-0']!.complete();
      await tester.pump();
      expect(pending, contains('image-3'));
      preloader.dispose();
      for (final value in pending.values.where((value) => !value.isCompleted)) {
        value.complete();
      }
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed images do not block the set or retry on each selection', (
    tester,
  ) async {
    final started = <String>[];
    final preloader = ExamImagePreloader(
      load: (url) async {
        started.add(url);
        throw StateError('image unavailable');
      },
    );
    final exam = GeneratedExam(
      examId: 1,
      questions: [for (var i = 0; i < 10; i++) _question('image-$i', i + 1)],
    );
    preloader.update(exam, 0);
    await tester.pump();
    expect(started, hasLength(10));
    expect(preloader.isPreparingSet, isFalse);
    preloader.update(exam, 1);
    expect(started, hasLength(10));
    preloader.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('text-only sets open without waiting', (tester) async {
    final preloader = ExamImagePreloader(
      load: (_) async => fail('unexpected image'),
    );
    preloader.update(
      const GeneratedExam(
        examId: 1,
        questions: [
          ExamQuestion(questionText: '1 + 1', questionNumber: 1, options: []),
        ],
      ),
      0,
    );
    expect(preloader.isPreparingSet, isFalse);
    preloader.dispose();
  });

  test(
    'decode dimensions keep fifty large assets within a bounded pixel budget',
    () {
      final dimension = ExamImagePreloader.dimensionForCount(50);
      expect(
        50 * dimension * dimension * 4,
        lessThanOrEqualTo(ExamImagePreloader.decodedMemoryBudget),
      );
      expect(dimension, lessThan(ExamImagePreloader.dimensionForCount(5)));
    },
  );
}

ExamQuestion _question(String url, int number) => ExamQuestion(
  questionText: 'Question $number',
  questionNumber: number,
  questionImageUrl: url,
  options: const [],
);
