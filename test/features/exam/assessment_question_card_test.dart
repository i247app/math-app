import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

    final textFinder = find.textContaining('Một lớp có 40');
    final questionText = tester.widget<Text>(textFinder);
    expect(questionText.data, expected);
    expect(questionText.softWrap, isTrue);
    expect(questionText.maxLines, isNull);
    expect(questionText.overflow, TextOverflow.visible);
    expect(questionText.data, isNot(contains('\u00A0')));
    expect(questionText.data, isNot(contains('\u202F')));
    expect(tester.getSize(textFinder).height, greaterThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps prose containing mixed Unicode no-break separators', (
    tester,
  ) async {
    const expected =
        'Một sợi dây dài 1 m. Người ta cắt đi 25 xăng-ti-mét. '
        'Hỏi sợi dây còn lại bao nhiêu xăng-ti-mét?';
    final separators = <String>[
      '\u00A0',
      '\u2007',
      '\u2009',
      '\u202F',
      '\u2060',
      '\uFEFF',
    ];
    var separatorIndex = 0;
    final source = expected.replaceAllMapped(RegExp(r'\s+'), (_) {
      final separator = separators[separatorIndex % separators.length];
      separatorIndex++;
      return separator;
    });

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

    final textFinder = find.textContaining('Một sợi dây dài');
    final questionText = tester.widget<Text>(textFinder);
    final paragraph = tester.renderObject<RenderParagraph>(textFinder);
    expect(questionText.data, expected);
    expect(questionText.textWidthBasis, TextWidthBasis.parent);
    expect(tester.getSize(textFinder).height, greaterThan(100));
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the full sequence question visible on narrow screens', (
    tester,
  ) async {
    const question =
        'Dãy số sau được viết theo quy luật nào: 5, 10, 15, 20, ...?';

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: const Scaffold(
          body: SizedBox(
            width: 320,
            child: AssessmentQuestionCard(question: question),
          ),
        ),
      ),
    );

    final textFinder = find.descendant(
      of: find.byType(AssessmentQuestionCard),
      matching: find.byType(Text),
    );
    expect(textFinder, findsOneWidget);
    final questionText = tester.widget<Text>(textFinder);
    final paragraph = tester.renderObject<RenderParagraph>(textFinder);
    expect(questionText.data, question);
    expect(tester.getSize(textFinder).height, greaterThan(70));
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves joined emoji sequences', (tester) async {
    const question = '👨‍👩‍👧‍👦 + ⭐ = ?';

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: const Scaffold(
          body: SizedBox(
            width: 320,
            child: AssessmentQuestionCard(question: question),
          ),
        ),
      ),
    );

    final questionText = tester.widget<Text>(find.text(question));
    expect(questionText.data, question);
    expect(questionText.data, contains('\u200D'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('scales a long indivisible math segment inside the card', (
    tester,
  ) async {
    const longNumber = '123456789012345678901234567890';
    const question = '$longNumber + 1 = ?';

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: const Scaffold(
          body: SizedBox(
            width: 320,
            child: AssessmentQuestionCard(question: question),
          ),
        ),
      ),
    );

    final segment = find.text(longNumber);
    final fittedSegment = find.ancestor(
      of: segment,
      matching: find.byType(FittedBox),
    );
    expect(segment, findsOneWidget);
    expect(fittedSegment, findsOneWidget);
    expect(tester.getSize(fittedSegment).width, lessThanOrEqualTo(272));
    expect(tester.takeException(), isNull);
  });
}
