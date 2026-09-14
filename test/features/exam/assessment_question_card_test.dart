import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_question_card.dart';

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

  testWidgets('normalizes non-breaking spaces and wraps long questions', (
    tester,
  ) async {
    const expected =
        'Một lớp có 40 học sinh, số học sinh nữ bằng 3/5 số học sinh '
        'cả lớp. Số học sinh nam là ?';
    final source = expected.replaceAll(' ', '\u00A0');

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: AssessmentQuestionCard(question: source),
          ),
        ),
      ),
    );

    final questionText = tester.widget<Text>(find.text(expected));
    expect(questionText.softWrap, isTrue);
    expect(questionText.maxLines, isNull);
    expect(questionText.overflow, TextOverflow.visible);
    expect(questionText.data, isNot(contains('\u00A0')));
    expect(questionText.data, isNot(contains('\u202F')));
    expect(tester.getSize(find.text(expected)).height, greaterThan(100));
    expect(tester.takeException(), isNull);
  });
}
