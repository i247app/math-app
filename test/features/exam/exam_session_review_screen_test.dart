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
import 'package:numi/features/exam/screens/exam_review_entry_screen.dart';
import 'package:numi/features/exam/screens/exam_review_text_screen.dart';
import 'package:numi/shared/layouts/page_header.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final entry in [
    examTypeAssessment,
    examTypeGrade,
    examTypePractice,
  ].indexed) {
    testWidgets(
      'calls session review once for ${entry.$2}, including cached detail',
      (tester) async {
        final id = 73000 + entry.$1;
        final service = _ReviewService(
          detail: _detail(sessionId: id, profileId: 42),
        );
        final originalLanguage = AppLanguageState.current;
        final lingo = LingoProvider();
        addTearDown(() {
          AppLanguageState.current = originalLanguage;
          lingo.dispose();
        });
        Widget app() => _app(
          service,
          lingo,
          ExamReviewScreen(
            userExamId: id,
            profileId: 21,
            examType: entry.$2,
            initialExam: service.detail,
          ),
        );
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        expect(service.detailCalls, 0);
        expect(service.requests, [(profileId: 21, sessionId: id)]);
        await lingo.setLanguage(AppLanguage.en);
        await tester.pumpAndSettle();
        expect(service.requests.length, 1);
        expect(find.text('1 + 1 = ?'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        expect(service.requests.length, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('resolves session and profile from loaded detail, not exam ID', (
    tester,
  ) async {
    final service = _ReviewService(
      detail: _detail(sessionId: 74001, profileId: 42),
    );
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    await tester.pumpWidget(
      _app(service, lingo, const ExamReviewScreen(examId: 74000)),
    );
    await tester.pumpAndSettle();
    expect(service.detailCalls, 1);
    expect(service.requests, [(profileId: 42, sessionId: 74001)]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('session review failure does not block question review', (
    tester,
  ) async {
    final service = _ReviewService(
      detail: _detail(sessionId: 75001, profileId: 42),
      fail: true,
    );
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    await tester.pumpWidget(
      _app(service, lingo, const ExamReviewScreen(userExamId: 75001)),
    );
    await tester.pumpAndSettle();
    expect(service.requests.length, 1);
    expect(find.text('1 + 1 = ?'), findsOneWidget);
    expect(find.text('Review unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending response does not block question review', (
    tester,
  ) async {
    final pending = Completer<ExamStats?>();
    final service = _ReviewService(
      detail: _detail(sessionId: 76001, profileId: 42),
      pending: pending,
    );
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    await tester.pumpWidget(
      _app(service, lingo, const ExamReviewScreen(userExamId: 76001)),
    );
    await tester.pumpAndSettle();
    expect(service.requests.length, 1);
    expect(find.text('1 + 1 = ?'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(_review('Practice subtraction.'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  for (final examType in [examTypeGrade, examTypeAssessment]) {
    testWidgets('AI review replaces topics after loading ($examType)', (
      tester,
    ) async {
      final pending = Completer<ExamStats?>();
      final service = _ReviewService(
        detail: _detail(sessionId: 78001, profileId: 42, withTopics: true),
        pending: pending,
      );
      final lingo = LingoProvider();
      final originalLanguage = AppLanguageState.current;
      addTearDown(() {
        AppLanguageState.current = originalLanguage;
        lingo.dispose();
      });
      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        _app(
          service,
          lingo,
          ExamReviewScreen(
            userExamId: 78001,
            initialExam: service.detail,
            examType: examType,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Subtraction, Counting'), findsOneWidget);
      expect(find.text('AI LEARNING'), findsOneWidget);
      expect(find.text('Short AI learning description.'), findsNothing);
      const aiText = 'Bé làm tốt đếm số. Ba mẹ nên luyện thêm cộng trừ.';
      pending.complete(_review('  $aiText  '));
      await tester.pumpAndSettle();
      expect(find.text(aiText), findsOneWidget);
      expect(find.text('Short AI learning description.'), findsOneWidget);
      expect(find.text('Choose the correct answer.'), findsNothing);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
      expect(find.text('Subtraction, Counting'), findsNothing);
      expect(find.text('Review'), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories_outlined), findsNothing);
      expect(find.text('1 + 1 = ?'), findsOneWidget);
      expect(service.requests.length, 1);
      await tester.tap(find.byKey(const ValueKey('exam-review-open-text')));
      await tester.pumpAndSettle();
      expect(find.byType(ExamReviewTextScreen), findsOneWidget);
      expect(find.byType(PageHeader), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      expect(
        find.text('Long review should not be shown here.'),
        findsOneWidget,
      );
      await lingo.setLanguage(AppLanguage.vi);
      await tester.pumpAndSettle();
      expect(find.text('Nhận Xét'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(ExamReviewTextScreen), findsNothing);
      expect(find.text(aiText), findsOneWidget);
      expect(service.requests.length, 1);
      expect(tester.takeException(), isNull);
    });
  }

  for (final withTopics in [false, true]) {
    for (final shortText in [null, '', '  \n ', 'Practice subtraction.']) {
      testWidgets('review fallback ($withTopics, $shortText)', (tester) async {
        final pending = Completer<ExamStats?>();
        final service = _ReviewService(
          detail: _detail(
            sessionId: 79001,
            profileId: 42,
            withTopics: withTopics,
          ),
          pending: pending,
        );
        final lingo = LingoProvider();
        addTearDown(lingo.dispose);
        await tester.pumpWidget(
          _app(
            service,
            lingo,
            ExamReviewScreen(
              userExamId: 79001,
              initialExam: service.detail,
              examType: examTypeGrade,
            ),
          ),
        );
        await tester.pumpAndSettle();
        pending.complete(_review(shortText, longText: ' \n '));
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
          find.text('Practice subtraction.'),
          hasAi ? findsOneWidget : findsNothing,
        );
        if (hasAi || withTopics) {
          await tester.tap(find.byKey(const ValueKey('exam-review-open-text')));
          await tester.pumpAndSettle();
          expect(find.byType(ExamReviewTextScreen), findsOneWidget);
          expect(
            tester.widget<SelectableText>(find.byType(SelectableText)).data,
            hasAi ? shortText!.trim() : 'Subtraction, Counting',
          );
          await tester.tap(find.byIcon(Icons.arrow_back_rounded));
          await tester.pumpAndSettle();
          expect(find.byType(ExamReviewTextScreen), findsNothing);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final examType in [
    examTypeAssessment,
    examTypeGrade,
    examTypePractice,
  ]) {
    for (final aiText in [null, 'AI feedback to replace.']) {
      testWidgets('perfect score shows encouragement ($examType, $aiText)', (
        tester,
      ) async {
        final pending = Completer<ExamStats?>();
        final service = _ReviewService(
          detail: _detail(sessionId: 80001, profileId: 42, withTopics: true),
          pending: pending,
        );
        final lingo = LingoProvider();
        final originalLanguage = AppLanguageState.current;
        addTearDown(() {
          AppLanguageState.current = originalLanguage;
          lingo.dispose();
        });
        await lingo.setLanguage(AppLanguage.en);
        await tester.pumpWidget(
          _app(
            service,
            lingo,
            ExamReviewScreen(
              userExamId: 80001,
              examType: examType,
              initialExam: service.detail,
            ),
          ),
        );
        await tester.pumpAndSettle();
        pending.complete(_review(aiText, correctNumber: 10));
        await tester.pumpAndSettle();
        expect(find.text('You are doing good!'), findsOneWidget);
        expect(find.text('AI feedback to replace.'), findsNothing);
        expect(find.text('Subtraction, Counting'), findsNothing);
        await tester.tap(find.byKey(const ValueKey('exam-review-open-text')));
        await tester.pumpAndSettle();
        expect(
          find.text('Long review should not be shown here.'),
          findsOneWidget,
        );
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
        await lingo.setLanguage(AppLanguage.vi);
        await tester.pumpAndSettle();
        expect(find.text('Bạn đang làm rất tốt!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('perfect detail shows the box without AI text or weak topics', (
    tester,
  ) async {
    final service = _ReviewService(
      detail: _detail(
        sessionId: 80002,
        profileId: 42,
        grading: const ExamGrading(correctNumber: 10, totalQuestions: 10),
      ),
    );
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    await lingo.setLanguage(AppLanguage.en);
    await tester.pumpWidget(
      _app(
        service,
        lingo,
        ExamReviewScreen(userExamId: 80002, initialExam: service.detail),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('You are doing good!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('exam-review-open-text')));
    await tester.pumpAndSettle();
    expect(find.text('You are doing good!'), findsOneWidget);
    expect(find.byType(ExamReviewTextScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final counts in [(correct: 0, total: 0), (correct: 9, total: 10)]) {
    testWidgets('non-perfect counts keep the AI review ($counts)', (
      tester,
    ) async {
      final pending = Completer<ExamStats?>();
      final service = _ReviewService(
        detail: _detail(sessionId: 80003, profileId: 42),
        pending: pending,
      );
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        _app(
          service,
          lingo,
          ExamReviewScreen(userExamId: 80003, initialExam: service.detail),
        ),
      );
      await tester.pumpAndSettle();
      pending.complete(
        _review(
          'Keep practicing.',
          correctNumber: counts.correct,
          totalQuestions: counts.total,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Keep practicing.'), findsOneWidget);
      expect(find.text('You are doing good!'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final missingSession in [false, true]) {
    testWidgets(
      'skips review request when IDs are missing (session=$missingSession)',
      (tester) async {
        final id = missingSession ? 77001 : 77002;
        final service = _ReviewService(
          detail: _detail(
            sessionId: missingSession ? null : id,
            profileId: missingSession ? 42 : null,
          ),
        );
        final lingo = LingoProvider();
        addTearDown(lingo.dispose);
        await tester.pumpWidget(
          _app(service, lingo, ExamReviewScreen(examId: id)),
        );
        await tester.pumpAndSettle();
        expect(service.requests, isEmpty);
        expect(find.text('1 + 1 = ?'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Widget _app(ExamService service, LingoProvider lingo, Widget screen) =>
    RepositoryProvider<ExamService>.value(
      value: service,
      child: LingoScope(
        lingo: lingo,
        child: MaterialApp(theme: AppTheme.light(), home: screen),
      ),
    );

GeneratedExam _detail({
  int? sessionId,
  int? profileId,
  bool withTopics = false,
  ExamGrading? grading,
}) => GeneratedExam(
  userExamId: sessionId,
  profileId: profileId,
  grading: grading,
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

ExamStats _review(
  String? shortText, {
  String? longText = 'Long review should not be shown here.',
  int correctNumber = 5,
  int totalQuestions = 10,
}) => ExamStats(
  correctNumber: correctNumber,
  scorePercentage: totalQuestions > 0
      ? correctNumber * 100 / totalQuestions
      : 0,
  skippedNumber: 0,
  totalQuestions: totalQuestions,
  aiReviewShort: shortText,
  aiShortText: 'Short AI learning description.',
  aiReviewLong: longText,
);

class _ReviewService implements ExamService {
  _ReviewService({required this.detail, this.fail = false, this.pending});
  final GeneratedExam detail;
  final bool fail;
  final Completer<ExamStats?>? pending;
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
    return detail;
  }

  @override
  Future<ExamStats?> getExamSessionReview({
    required int profileId,
    required int userExamId,
  }) async {
    requests.add((profileId: profileId, sessionId: userExamId));
    if (fail) throw const ExamException('Review unavailable');
    return pending == null ? null : await pending!.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
