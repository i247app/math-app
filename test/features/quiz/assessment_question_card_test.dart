import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_question_card.dart';

void main() {
  testWidgets('uses pictorial spacing for emoji outside the fruit range', (
    tester,
  ) async {
    const questions = <String>[
      '🍓 + 🍓 = ?',
      '⭐ + ⭐ = ?',
      '❤️ + ❤️ = ?',
      '☀️ + ☀️ = ?',
      '✈️ + ✈️ = ?',
      '🇻🇳 + 🇻🇳 = ?',
      '1️⃣ + 1️⃣ = ?',
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                for (var index = 0; index < questions.length; index++)
                  AssessmentQuestionCard(
                    key: ValueKey('question-$index'),
                    question: questions[index],
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    for (var index = 0; index < questions.length; index++) {
      expect(
        tester.getSize(find.byKey(ValueKey('question-$index'))).height,
        greaterThanOrEqualTo(260),
      );
    }
    expect(tester.takeException(), isNull);
  });
}
