import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/network/quiz_models.dart';
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

  Widget testApp(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
      ),
      home: Scaffold(
        body: SingleChildScrollView(child: SizedBox(width: 360, child: child)),
      ),
    );
  }

  testWidgets('retry question card expands and shows the complete question', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(const QuizReviewQuestionCard(question: question)),
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
    await tester.pumpWidget(
      testApp(
        const QuizReviewResultQuestionCard(
          question: question,
          selectedLabel: 'B',
        ),
      ),
    );

    final questionText = tester.widget<Text>(find.text(longQuestion));

    expect(questionText.maxLines, isNull);
    expect(questionText.overflow, isNull);
    expect(tester.takeException(), isNull);
  });
}
