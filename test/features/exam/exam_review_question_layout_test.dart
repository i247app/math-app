import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/exam_review_entry_screen.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/assessment_result/test_again_loader.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_answer_list.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_answer_tile.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_mode_tab_button.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_card.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_result_question_card.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_stats_card.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_weak_topics_card.dart';

void main() {
  const longQuestion =
      'Một đoạn dây dài 45 cm, đoạn dây khác dài hơn 18 cm. '
      'Hỏi đoạn dây thứ hai dài bao nhiêu xăng-ti-mét?';
  const question = ExamQuestion(
    questionName: longQuestion,
    questionNumber: 5,
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '63'),
      ExamAnswer(label: 'B', content: '57'),
    ],
    correctAnswer: 'A',
  );

  Widget testApp(Widget child, LingoProvider lingo) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
      ),
      home: LingoScope(
        lingo: lingo,
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 360, child: child),
          ),
        ),
      ),
    );
  }

  testWidgets('retry question card expands and shows the complete question', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      testApp(const ExamReviewQuestionCard(question: question), lingo),
    );

    final questionText = tester.widget<Text>(find.text(longQuestion));

    expect(questionText.maxLines, isNull);
    expect(questionText.overflow, isNull);
    expect(
      tester.getSize(find.byType(ExamReviewQuestionCard)).height,
      greaterThan(146),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('result question card shows the complete question', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      testApp(
        const ExamReviewResultQuestionCard(
          question: question,
          selectedLabel: 'B',
        ),
        lingo,
      ),
    );

    final questionText = tester.widget<Text>(find.text(longQuestion));

    expect(questionText.maxLines, isNull);
    expect(questionText.overflow, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('review answers keep a neutral border in both modes', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    const reviewQuestion = ExamQuestion(
      questionName: '1 + 1 = ?',
      questionNumber: 1,
      answers: <ExamAnswer>[
        ExamAnswer(label: 'A', content: '2'),
        ExamAnswer(label: 'B', content: '3'),
        ExamAnswer(label: 'C', content: '4'),
      ],
      correctAnswer: 'A',
    );

    Future<void> showAnswers({
      required bool showCorrectAnswer,
      String selectedLabel = 'B',
    }) async {
      await tester.pumpWidget(
        testApp(
          ExamReviewAnswerList(
            question: reviewQuestion,
            selectedLabel: selectedLabel,
            showCorrectAnswer: showCorrectAnswer,
          ),
          lingo,
        ),
      );
      await tester.pumpAndSettle();
    }

    BoxDecoration decorationAt(int index) {
      final tile = find.byType(ExamReviewAnswerTile).at(index);
      final container = tester.widget<AnimatedContainer>(
        find.descendant(of: tile, matching: find.byType(AnimatedContainer)),
      );
      return container.decoration! as BoxDecoration;
    }

    Color? labelCircleColorAt(int index) {
      final label = reviewQuestion.answers[index].label;
      final circle = tester.widget<Container>(
        find.byKey(ValueKey('exam-review-answer-circle-$label')),
      );
      return (circle.decoration! as BoxDecoration).color;
    }

    void expectNeutralBorders() {
      for (var index = 0; index < 3; index++) {
        expect(
          decorationAt(index).border,
          Border.all(color: AppColors.borderSoft),
        );
      }
    }

    await showAnswers(showCorrectAnswer: false);
    expectNeutralBorders();
    expect(decorationAt(1).color, AppColors.redSoft);
    expect(decorationAt(2).color, Colors.white);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    await showAnswers(showCorrectAnswer: true);
    expectNeutralBorders();
    expect(decorationAt(0).color, Colors.white);
    expect(labelCircleColorAt(0), Colors.white);
    expect(decorationAt(1).color, AppColors.redSoft);
    expect(labelCircleColorAt(1), AppColors.red);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await showAnswers(showCorrectAnswer: true, selectedLabel: 'A');
    expectNeutralBorders();
    expect(decorationAt(0).color, AppColors.tealLightSurface);
    expect(labelCircleColorAt(0), AppColors.tealAccent);
    expect(decorationAt(1).color, Colors.white);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stats ignore skipped questions outside the journey detail', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      testApp(
        const ExamReviewStatsCard(
          exam: GeneratedExam(
            grading: ExamGrading(
              correctNumber: 1,
              totalQuestions: 5,
              skippedNumber: 5,
            ),
            questions: <ExamQuestion>[],
          ),
        ),
        lingo,
      ),
    );

    expect(find.text('5'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('assessment journey uses the shared AI learning review UI', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    final lingo = LingoProvider();
    final service = _JourneyDetailService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: RepositoryProvider<ExamService>.value(
          value: service,
          child: LingoScope(
            lingo: lingo,
            child: const ExamReviewScreen(userExamId: 912345),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(service.requestedUserExamId, 912345);
    expect(
      find.byKey(const ValueKey('exam-review-grade-level-badge')),
      findsOneWidget,
    );
    expect(find.byType(ExamReviewWeakTopicsCard), findsOneWidget);
    expect(find.text('AI LEARING'), findsOneWidget);
    expect(find.text('Đề - 912345'), findsOneWidget);
    expect(find.byType(ExamReviewModeTabButton), findsNWidgets(2));
    final tabs = find.byType(ExamReviewModeTabButton);
    expect(tester.widget<ExamReviewModeTabButton>(tabs.at(0)).label, 'Ôn Lại');
    expect(tester.widget<ExamReviewModeTabButton>(tabs.at(1)).label, 'Kết Quả');
    expect(
      tester.getCenter(tabs.at(0)).dx,
      lessThan(tester.getCenter(tabs.at(1)).dx),
    );
    expect(find.byType(ExamReviewQuestionCard), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsNothing);
    await tester.tap(tabs.at(1));
    await tester.pumpAndSettle();
    expect(find.byType(ExamReviewResultQuestionCard), findsOneWidget);
    await tester.tap(tabs.at(0));
    await tester.pumpAndSettle();
    expect(find.byType(ExamReviewQuestionCard), findsOneWidget);

    await lingo.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('Test - 912345'), findsOneWidget);
    expect(tester.widget<ExamReviewModeTabButton>(tabs.at(0)).label, 'Revise');
    expect(tester.widget<ExamReviewModeTabButton>(tabs.at(1)).label, 'Results');
    expect(
      find.byKey(const ValueKey('exam-review-practice-banner')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'grade journey localizes the session header and retains practice',
    (tester) async {
      final lingo = LingoProvider();
      final service = _JourneyDetailService();
      addTearDown(lingo.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: RepositoryProvider<ExamService>.value(
            value: service,
            child: LingoScope(
              lingo: lingo,
              child: const ExamReviewScreen(
                examId: 123,
                userExamId: 912347,
                examType: examTypeGrade,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Đề - 912347'), findsOneWidget);
      expect(find.text('Đề - 123'), findsNothing);
      expect(find.text('Lớp 2 - Level 4'), findsOneWidget);
      expect(find.text('AI LEARING'), findsOneWidget);
      expect(find.text('Chọn đáp án đúng.'), findsNothing);
      expect(
        tester
            .getBottomLeft(
              find.byKey(const ValueKey('exam-review-grade-level-badge')),
            )
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const ValueKey('exam-review-practice-banner')),
              )
              .dy,
        ),
      );
      expect(find.text('Nhận Xét'), findsOneWidget);
      expect(find.text('3/3 câu trả lời sai'), findsNothing);
      expect(
        find.text('Phép đếm, Trừ không nhớ, Trừ trong phạm vi 5'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ExamReviewWeakTopicsCard),
          matching: find.byType(Divider),
        ),
        findsNothing,
      );
      expect(
        tester
            .getTopLeft(
              find.byKey(const ValueKey('exam-review-weak-topics-card')),
            )
            .dy,
        greaterThan(
          tester
              .getBottomLeft(
                find.byKey(const ValueKey('exam-review-practice-banner')),
              )
              .dy,
        ),
      );
      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpAndSettle();
      expect(find.text('Test - 912347'), findsOneWidget);
      expect(find.text('Test - 123'), findsNothing);
      expect(find.text('Grade 2 - Level 4'), findsOneWidget);
      expect(find.text('AI LEARING'), findsOneWidget);
      expect(find.text('Choose the correct answer.'), findsNothing);
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('3/3 incorrect answers'), findsNothing);
      expect(
        find.byKey(const ValueKey('exam-review-practice-banner')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final examType in [examTypeGrade, examTypeAssessment]) {
    testWidgets('practice banner opens the full generate loader ($examType)', (
      tester,
    ) async {
      final lingo = LingoProvider();
      final service = _PendingPracticeService();
      addTearDown(lingo.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: RepositoryProvider<ExamService>.value(
            value: service,
            child: LingoScope(
              lingo: lingo,
              child: ExamReviewScreen(userExamId: 912347, examType: examType),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('LUYỆN TẬP'), findsOneWidget);

      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpAndSettle();
      expect(find.text('PRACTICE'), findsOneWidget);
      expect(
        tester
            .widget<ExamReviewModeTabButton>(
              find.byType(ExamReviewModeTabButton).first,
            )
            .label,
        'Revise',
      );

      await tester.tap(
        find.byKey(const ValueKey('exam-review-practice-banner')),
      );
      await tester.pump();
      expect(service.requestedPracticeType, examTypePractice);
      expect(service.requestedPracticeUserExamId, 912345);
      expect(find.byType(AssessmentTestAgainLoader), findsOneWidget);
      expect(find.byType(ExamReviewModeTabButton), findsNothing);

      service.pendingPractice.completeError(StateError('generation failed'));
      await tester.pumpAndSettle();
      expect(find.byType(AssessmentTestAgainLoader), findsNothing);
    });
  }

  testWidgets('guest assessment review omits the practice banner', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final service = _JourneyDetailService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: RepositoryProvider<ExamService>.value(
          value: service,
          child: LingoScope(
            lingo: lingo,
            child: const ExamReviewScreen(
              userExamId: 912346,
              allowPractice: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(service.requestedUserExamId, 912346);
    expect(find.text('Đề - 912346'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('exam-review-practice-banner')),
      findsNothing,
    );
    expect(find.byType(ExamReviewModeTabButton), findsNWidgets(2));
    expect(find.byType(ExamReviewStatsCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single assessment and grade use the same localized ID header', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final service = _JourneyDetailService();
    addTearDown(lingo.dispose);

    Future<void> showReview(String examType) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: RepositoryProvider<ExamService>.value(
            value: service,
            child: LingoScope(
              lingo: lingo,
              child: ExamReviewScreen(examId: 123, examType: examType),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await showReview(examTypeAssessment);
    expect(find.text('Đề - 123'), findsOneWidget);

    await showReview(examTypeGrade);
    expect(find.text('Đề - 123'), findsOneWidget);
    expect(find.text('Chi Tiết'), findsNothing);
    await lingo.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('Test - 123'), findsOneWidget);
  });
}

class _JourneyDetailService implements ExamService {
  int? requestedUserExamId;

  @override
  Future<ExamStats?> getExamSessionReview({
    required int profileId,
    required int userExamId,
  }) async => null;

  @override
  Future<GeneratedExam> getExamDetail(
    int detailId, {
    int? profileId,
    int? userExamId,
    String examType = examTypeAssessment,
  }) async {
    requestedUserExamId = userExamId;
    return const GeneratedExam(
      userExamId: 912345,
      profileId: 42,
      grade: 2,
      lastSetGrade: 4,
      level: 4,
      lastSetShortText: 'Phép cộng trong phạm vi 100',
      practiceWeakTopics: <ExamPracticeTopic>[
        ExamPracticeTopic(topic: 'Phép đếm', answered: 3, wrong: 3),
        ExamPracticeTopic(topic: 'Trừ không nhớ', answered: 1, wrong: 1),
        ExamPracticeTopic(topic: 'Trừ trong phạm vi 5', answered: 1, wrong: 1),
      ],
      grading: ExamGrading(correctNumber: 1, totalQuestions: 1),
      answers: <SubmitExamAnswer>[
        SubmitExamAnswer(questionNumber: 1, label: 'A'),
      ],
      questions: <ExamQuestion>[
        ExamQuestion(
          questionName: '1 + 1 = ?',
          questionNumber: 1,
          answers: <ExamAnswer>[
            ExamAnswer(label: 'A', content: '2'),
            ExamAnswer(label: 'B', content: '1'),
            ExamAnswer(label: 'C', content: '3'),
            ExamAnswer(label: 'D', content: '4'),
          ],
          rightAnswer: 'A',
          correctAnswer: '2',
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PendingPracticeService extends _JourneyDetailService {
  final Completer<GeneratedExam> pendingPractice = Completer<GeneratedExam>();
  String? requestedPracticeType;
  int? requestedPracticeUserExamId;

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) {
    requestedPracticeType = examType;
    requestedPracticeUserExamId = userExamId;
    return pendingPractice.future;
  }
}
