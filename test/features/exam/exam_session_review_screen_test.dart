import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/exam_review_screen.dart';
import 'package:numi/features/exam/screens/ai_review_screen.dart';
import 'package:numi/shared/layouts/page_header.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  var nextId = 90000;

  for (final type in [examTypeAssessment, examTypeGrade, examTypePractice]) {
    for (final cached in [false, true]) {
      testWidgets('generates only on chevron ($type, cached=$cached)', (
        tester,
      ) async {
        final id = nextId++;
        final pending = Completer<ExamStats?>();
        final service = _ReviewService(detail: _detail(id), pending: pending);
        final lingo = _lingo();
        await lingo.setLanguage(AppLanguage.en);
        await tester.pumpWidget(
          _app(
            service,
            lingo,
            ExamReviewScreen(
              userExamId: id,
              profileId: 21,
              examType: type,
              initialExam: cached ? service.detail : null,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(service.requests, isEmpty);
        expect(service.detailCalls, cached ? 0 : 1);
        expect(find.text('Detail AI description.'), findsOneWidget);
        expect(find.text('Detail short review.'), findsOneWidget);
        expect(find.text('1 + 1 = ?'), findsOneWidget);

        await lingo.setLanguage(AppLanguage.vi);
        await tester.pumpAndSettle();
        expect(service.requests, isEmpty);
        await lingo.setLanguage(AppLanguage.en);
        await tester.pumpAndSettle();

        await tester.tap(_chevron);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        expect(service.requests, [(profileId: 21, sessionId: id)]);
        expect(find.byType(AiReviewScreen), findsOneWidget);
        expect(find.byType(PageHeader), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        pending.complete(_review());
        await tester.pumpAndSettle();
        expect(find.text('Generated long review.'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
        expect(service.detailCalls, cached ? 1 : 2);
        expect(find.text('Detail AI description.'), findsOneWidget);
        expect(find.text('Detail short review.'), findsOneWidget);
        expect(find.text('Generated short review.'), findsNothing);
        expect(find.text('Generated AI description.'), findsNothing);

        await tester.tap(_chevron);
        await tester.pumpAndSettle();
        expect(service.requests.length, 2);
        expect(find.text('Generated long review.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'uses existing review without generating ($type, cached=$cached)',
        (tester) async {
          final id = nextId++;
          final service = _ReviewService(
            detail: _detail(id, longReview: '  Detail long review.  '),
            fail: true,
          );
          final lingo = _lingo();
          await tester.pumpWidget(
            _app(
              service,
              lingo,
              ExamReviewScreen(
                userExamId: id,
                examType: type,
                initialExam: cached ? service.detail : null,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(service.requests, isEmpty);
          expect(service.detailCalls, cached ? 0 : 1);
          await tester.tap(_chevron);
          await tester.pumpAndSettle();
          expect(find.text('Detail long review.'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(service.requests, isEmpty);
          await tester.tap(find.byIcon(Icons.arrow_back_rounded));
          await tester.pumpAndSettle();
          expect(service.detailCalls, cached ? 1 : 2);
          await tester.tap(_chevron);
          await tester.pumpAndSettle();
          expect(service.requests, isEmpty);
          expect(find.text('Detail long review.'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final type in [examTypeAssessment, examTypeGrade, examTypePractice]) {
    for (final cached in [false, true]) {
      testWidgets(
        'back refreshes detail stats before reopening ($type, cached=$cached)',
        (tester) async {
          final id = nextId++;
          final service = _ReviewService(
            detail: _detail(id),
            result: _review(),
          );
          final lingo = _lingo();
          await tester.pumpWidget(
            _app(
              service,
              lingo,
              ExamReviewScreen(
                userExamId: id,
                examType: type,
                initialExam: cached ? service.detail : null,
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(_chevron);
          await tester.pumpAndSettle();
          expect(service.requests.length, 1);
          expect(find.text('Generated long review.'), findsOneWidget);
          service.detail = _detail(
            id,
            shortReview: 'Updated short review.',
            longReview: 'Updated long review.',
            aiShortText: 'Updated AI description.',
            aiTitle: 'Updated AI title.',
          );
          await tester.tap(find.byIcon(Icons.arrow_back_rounded));
          await tester.pumpAndSettle();
          expect(service.detailCalls, cached ? 1 : 2);
          expect(find.text('Updated short review.'), findsOneWidget);
          expect(find.text('Updated AI description.'), findsOneWidget);
          expect(find.text('Updated AI title.'), findsOneWidget);
          expect(find.text('Detail short review.'), findsNothing);
          expect(find.text('1 + 1 = ?'), findsOneWidget);
          expect(service.requests.length, 1);
          await tester.tap(_chevron);
          await tester.pumpAndSettle();
          expect(find.text('Updated long review.'), findsOneWidget);
          expect(service.requests.length, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('back refresh failure keeps visible detail and allows retry', (
    tester,
  ) async {
    final id = nextId++;
    final service = _ReviewService(
      detail: _detail(id, longReview: 'Detail long review.'),
    );
    final lingo = _lingo();
    await tester.pumpWidget(
      _app(
        service,
        lingo,
        ExamReviewScreen(userExamId: id, initialExam: service.detail),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_chevron);
    await tester.pumpAndSettle();
    service.failDetail = true;
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(service.detailCalls, 1);
    expect(find.text('Detail unavailable'), findsOneWidget);
    expect(find.text('Detail short review.'), findsOneWidget);
    expect(find.text('1 + 1 = ?'), findsOneWidget);
    expect(service.requests, isEmpty);
    service.failDetail = false;
    service.detail = _detail(id, shortReview: 'Updated short review.');
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(service.detailCalls, 2);
    expect(find.text('Updated short review.'), findsOneWidget);
    expect(find.text('Detail unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final texts in [
    (short: null, long: 'Detail long review.'),
    (short: ' \n ', long: 'Detail long review.'),
    (short: 'Detail short review.', long: ' \n '),
  ]) {
    testWidgets('generates when either review field is empty ($texts)', (
      tester,
    ) async {
      final id = nextId++;
      final service = _ReviewService(
        detail: _detail(
          id,
          shortReview: texts.short,
          longReview: texts.long,
          withTopics: true,
        ),
        result: _review(),
      );
      final lingo = _lingo();
      await tester.pumpWidget(
        _app(
          service,
          lingo,
          ExamReviewScreen(userExamId: id, initialExam: service.detail),
        ),
      );
      await tester.pumpAndSettle();
      expect(service.requests, isEmpty);
      await tester.tap(_chevron);
      await tester.pumpAndSettle();
      expect(service.requests.length, 1);
      expect(find.text('Generated long review.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'perfect-score message does not replace the existing-review check',
    (tester) async {
      final id = nextId++;
      final service = _ReviewService(
        detail: _detail(
          id,
          correct: 10,
          shortReview: null,
          longReview: 'Detail long review.',
        ),
        result: _review(),
      );
      final lingo = _lingo();
      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        _app(
          service,
          lingo,
          ExamReviewScreen(userExamId: id, initialExam: service.detail),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('You are doing good!'), findsOneWidget);
      await tester.tap(_chevron);
      await tester.pumpAndSettle();
      expect(service.requests.length, 1);
      expect(find.text('Generated long review.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('resolves IDs from loaded detail when opening generated review', (
    tester,
  ) async {
    final id = nextId++;
    final service = _ReviewService(detail: _detail(id), result: _review());
    final lingo = _lingo();
    await tester.pumpWidget(
      _app(service, lingo, ExamReviewScreen(examId: id + 1000)),
    );
    await tester.pumpAndSettle();
    expect(service.requests, isEmpty);
    await tester.tap(_chevron);
    await tester.pumpAndSettle();
    expect(service.requests, [(profileId: 42, sessionId: id)]);
    expect(find.text('Generated long review.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('generation failure keeps back navigation and allows retry', (
    tester,
  ) async {
    final id = nextId++;
    final service = _ReviewService(
      detail: _detail(id),
      fail: true,
      result: _review(),
    );
    final lingo = _lingo();
    await lingo.setLanguage(AppLanguage.en);
    await tester.pumpWidget(
      _app(
        service,
        lingo,
        ExamReviewScreen(userExamId: id, initialExam: service.detail),
      ),
    );
    await tester.pumpAndSettle();
    expect(service.requests, isEmpty);
    expect(find.text('Detail short review.'), findsOneWidget);
    await tester.tap(_chevron);
    await tester.pumpAndSettle();
    expect(find.text('Review unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    service.fail = false;
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(service.requests.length, 2);
    expect(find.text('Generated long review.'), findsOneWidget);
    expect(find.text('Review unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('can return to detail while generation is pending', (
    tester,
  ) async {
    final id = nextId++;
    final pending = Completer<ExamStats?>();
    final service = _ReviewService(detail: _detail(id), pending: pending);
    final lingo = _lingo();
    await tester.pumpWidget(
      _app(
        service,
        lingo,
        ExamReviewScreen(userExamId: id, initialExam: service.detail),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_chevron);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(AiReviewScreen), findsNothing);
    expect(service.detailCalls, 1);
    pending.complete(_review());
    await tester.pump();
    expect(find.text('Detail short review.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final missingSession in [false, true]) {
    testWidgets(
      'missing IDs skip generation on chevron (session=$missingSession)',
      (tester) async {
        final id = nextId++;
        final service = _ReviewService(
          detail: _detail(
            missingSession ? null : id,
            profileId: missingSession ? 42 : null,
          ),
        );
        final lingo = _lingo();
        await tester.pumpWidget(
          _app(service, lingo, ExamReviewScreen(examId: id + 1000)),
        );
        await tester.pumpAndSettle();
        await tester.tap(_chevron);
        await tester.pumpAndSettle();
        expect(service.requests, isEmpty);
        expect(find.text('Detail short review.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final generated in [
    (
      long: 'Generated long review.',
      short: 'Generated short review.',
      expected: 'Generated long review.',
    ),
    (
      long: ' \n ',
      short: 'Generated short review.',
      expected: 'Generated short review.',
    ),
    (long: null, short: '', expected: 'Detail short review.'),
  ]) {
    testWidgets('generated text fallback ($generated)', (tester) async {
      final id = nextId++;
      final service = _ReviewService(
        detail: _detail(id),
        result: _review(longText: generated.long, shortText: generated.short),
      );
      final lingo = _lingo();
      await tester.pumpWidget(
        _app(
          service,
          lingo,
          ExamReviewScreen(userExamId: id, initialExam: service.detail),
        ),
      );
      await tester.pumpAndSettle();
      expect(service.requests, isEmpty);
      await tester.tap(_chevron);
      await tester.pumpAndSettle();
      expect(find.text(generated.expected), findsOneWidget);
      expect(service.requests.length, 1);
      expect(tester.takeException(), isNull);
    });
  }

  for (final type in [examTypeAssessment, examTypeGrade, examTypePractice]) {
    testWidgets(
      'perfect detail shows encouragement without generating ($type)',
      (tester) async {
        final id = nextId++;
        final service = _ReviewService(
          detail: _detail(id, correct: 10),
          result: _review(),
        );
        final lingo = _lingo();
        await lingo.setLanguage(AppLanguage.en);
        await tester.pumpWidget(
          _app(
            service,
            lingo,
            ExamReviewScreen(
              userExamId: id,
              examType: type,
              initialExam: service.detail,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('You are doing good!'), findsOneWidget);
        expect(find.text('Detail short review.'), findsNothing);
        expect(service.requests, isEmpty);
        await lingo.setLanguage(AppLanguage.vi);
        await tester.pumpAndSettle();
        expect(find.text('Bạn đang làm rất tốt!'), findsOneWidget);
        expect(service.requests, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final withTopics in [false, true]) {
    for (final shortText in [null, '', ' \n ', 'Detail short review.']) {
      testWidgets('detail review fallback ($withTopics, $shortText)', (
        tester,
      ) async {
        final id = nextId++;
        final service = _ReviewService(
          detail: _detail(id, withTopics: withTopics, shortReview: shortText),
        );
        final lingo = _lingo();
        await tester.pumpWidget(
          _app(
            service,
            lingo,
            ExamReviewScreen(userExamId: id, initialExam: service.detail),
          ),
        );
        await tester.pumpAndSettle();
        final hasAi = shortText?.trim().isNotEmpty ?? false;
        expect(
          find.byKey(const ValueKey('exam-review-weak-topics-card')),
          hasAi || withTopics ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Subtraction, Counting'),
          !hasAi && withTopics ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Detail short review.'),
          hasAi ? findsOneWidget : findsNothing,
        );
        expect(service.requests, isEmpty);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final counts in [(correct: 0, total: 0), (correct: 9, total: 10)]) {
    testWidgets('non-perfect detail keeps AI review ($counts)', (tester) async {
      final id = nextId++;
      final service = _ReviewService(
        detail: _detail(id, correct: counts.correct, total: counts.total),
      );
      final lingo = _lingo();
      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        _app(
          service,
          lingo,
          ExamReviewScreen(userExamId: id, initialExam: service.detail),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Detail short review.'), findsOneWidget);
      expect(find.text('You are doing good!'), findsNothing);
      expect(service.requests, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}

final _chevron = find.byKey(const ValueKey('exam-review-open-text'));

LingoProvider _lingo() {
  final original = AppLanguageState.current;
  final lingo = LingoProvider();
  addTearDown(() {
    AppLanguageState.current = original;
    lingo.dispose();
  });
  return lingo;
}

Widget _app(ExamService service, LingoProvider lingo, Widget screen) =>
    RepositoryProvider<ExamService>.value(
      value: service,
      child: LingoScope(
        lingo: lingo,
        child: MaterialApp(theme: AppTheme.light(), home: screen),
      ),
    );

GeneratedExam _detail(
  int? sessionId, {
  int? profileId = 42,
  int correct = 5,
  int total = 10,
  String? shortReview = 'Detail short review.',
  String? longReview,
  String aiShortText = 'Detail AI description.',
  String? aiTitle,
  bool withTopics = false,
}) => GeneratedExam(
  userExamId: sessionId,
  profileId: profileId,
  grade: 1,
  level: 3,
  aiShortText: aiShortText,
  aiTitle: aiTitle,
  aiReviewShort: shortReview,
  aiReviewLong: longReview,
  grading: ExamGrading(correctNumber: correct, totalQuestions: total),
  practiceWeakTopics: withTopics
      ? const [
          ExamPracticeTopic(topic: 'Subtraction', answered: 1, wrong: 1),
          ExamPracticeTopic(topic: 'Counting', answered: 1, wrong: 1),
        ]
      : const [],
  questions: const [
    ExamQuestion(
      questionNumber: 1,
      questionName: '1 + 1 = ?',
      rightAnswer: 'A',
      answers: [ExamAnswer(label: 'A', content: '2')],
    ),
  ],
);

ExamStats _review({
  String? shortText = 'Generated short review.',
  String? longText = 'Generated long review.',
}) => ExamStats(
  correctNumber: 5,
  scorePercentage: 50,
  skippedNumber: 0,
  totalQuestions: 10,
  aiReviewShort: shortText,
  aiShortText: 'Generated AI description.',
  aiReviewLong: longText,
);

class _ReviewService implements ExamService {
  _ReviewService({
    required this.detail,
    this.fail = false,
    this.pending,
    this.result,
  });
  GeneratedExam detail;
  bool fail;
  bool failDetail = false;
  final Completer<ExamStats?>? pending;
  final ExamStats? result;
  int detailCalls = 0;
  final requests = <({int profileId, int sessionId})>[];

  @override
  Future<GeneratedExam> getExamDetail(
    int detailId, {
    int? profileId,
    int? userExamId,
    String examType = examTypeAssessment,
  }) async {
    detailCalls++;
    if (failDetail) throw const ExamException('Detail unavailable');
    return detail;
  }

  @override
  Future<ExamStats?> generateExamSessionAiReview({
    required int profileId,
    required int userExamId,
  }) async {
    requests.add((profileId: profileId, sessionId: userExamId));
    if (fail) throw const ExamException('Review unavailable');
    return pending == null ? result : await pending!.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
