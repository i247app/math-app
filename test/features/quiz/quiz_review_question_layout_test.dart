import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_question_card.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_result_question_card.dart';

void main() {
  const longQuestion =
      'Một đoạn dây dài 45 cm, đoạn dây khác dài hơn 18 cm. '
      'Hỏi đoạn dây thứ hai dài bao nhiêu xăng-ti-mét?';
  const question = QuizQuestion(
    questionName: longQuestion,
    questionNumber: 5,
    answers: <QuizAnswer>[
      QuizAnswer(label: 'A', content: '63'),
      QuizAnswer(label: 'B', content: '57'),
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
      testApp(const QuizReviewQuestionCard(question: question), lingo),
    );

    final questionText = tester.widget<Text>(find.text(longQuestion));

    expect(questionText.maxLines, isNull);
    expect(questionText.overflow, isNull);
    expect(
      tester.getSize(find.byType(QuizReviewQuestionCard)).height,
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
        const QuizReviewResultQuestionCard(
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
}
