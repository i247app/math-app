import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/exam_review_entry_screen.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_mode_tab_button.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_card.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_result_question_card.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_stats_card.dart';

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
    expect(tester.takeException(), isNull);
  });

  testWidgets('journey detail shows retry and result modes', (tester) async {
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
    expect(find.byType(ExamReviewModeTabButton), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}

class _JourneyDetailService implements ExamService {
  int? requestedUserExamId;

  @override
  Future<GeneratedExam> getExamDetail(
    int detailId, {
    int? profileId,
    int? userExamId,
  }) async {
    requestedUserExamId = userExamId;
    return const GeneratedExam(
      userExamId: 912345,
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
