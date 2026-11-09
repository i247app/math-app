import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_question_card.dart';

void main() {
  Future<void> pumpQuestion(
    WidgetTester tester,
    String question, {
    double width = 320,
    double textScale = 1,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
      ),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: width,
              child: AssessmentQuestionCard(question: question),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('ordering numbers retain their order and wrap within the card', (
    tester,
  ) async {
    const question =
        'Sắp xếp các số theo thứ tự tăng dần: 18, 5, 12, 9, 18, 3.';
    await pumpQuestion(tester, question);

    expect(find.text('Sắp xếp các số theo thứ tự tăng dần:'), findsOneWidget);
    expect(find.text('.'), findsNothing);
    final numbers = find.byWidgetPredicate(
      (widget) =>
          widget is Text && RegExp(r'^\d+$').hasMatch(widget.data ?? ''),
    );
    expect(tester.widgetList<Text>(numbers).map((text) => text.data), [
      '18',
      '5',
      '12',
      '9',
      '18',
      '3',
    ]);
    expect(
      tester.getTopLeft(numbers.last).dy,
      greaterThan(tester.getTopLeft(numbers.first).dy),
    );
    final cardBounds = tester.getRect(find.byType(AssessmentQuestionCard));
    for (final number in numbers.evaluate()) {
      final bounds = tester.getRect(
        find.byElementPredicate((e) => e == number),
      );
      expect(bounds.left, greaterThanOrEqualTo(cardBounds.left + 24));
      expect(bounds.right, lessThanOrEqualTo(cardBounds.right - 24));
    }
    expect(find.bySemanticsLabel(question), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'ordering preserves decimal commas, signs and trailing instruction',
    (tester) async {
      await pumpQuestion(
        tester,
        'Sắp xếp các số -2,5; 0; −1,25 từ bé đến lớn.',
        width: 280,
        textScale: 2,
      );
      expect(find.text('-2,5'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('−1,25'), findsOneWidget);
      expect(find.text('từ bé đến lớn.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final question in [
    'Sắp xếp các số: 1/2, 3/4, 2/3.',
    'Sắp xếp các số: 1,2,3.',
    'Sắp xếp các số: 2 cm, 3 cm, 1 cm.',
  ]) {
    testWidgets('preserves ambiguous or nonnumeric lists as prose: $question', (
      tester,
    ) async {
      await pumpQuestion(tester, question);
      expect(find.text(question), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('separates a calculation instruction and spaces its operators', (
    tester,
  ) async {
    await pumpQuestion(
      tester,
      'Tính giá trị biểu thức: 125+36:4=?',
      width: 600,
    );
    final prompt = find.text('Tính giá trị biểu thức:');
    final expression = find.text('125 + 36 : 4 = ?');
    expect(prompt, findsOneWidget);
    expect(expression, findsOneWidget);
    expect(
      tester.getBottomLeft(prompt).dy,
      lessThan(tester.getTopLeft(expression).dy),
    );
    expect(
      tester.widget<Text>(prompt).style!.fontSize,
      lessThan(tester.widget<Text>(expression).style!.fontSize!),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long calculations wrap outside parentheses at large text sizes',
    (tester) async {
      await pumpQuestion(
        tester,
        'Tính: (125+375)×(20-8)+240:6=?',
        width: 280,
        textScale: 2,
      );
      expect(find.text('(125 + 375)'), findsOneWidget);
      expect(find.text('× (20 - 8)'), findsOneWidget);
      expect(find.text('+ 240'), findsOneWidget);
      expect(find.text(': 6'), findsOneWidget);
      expect(find.text('= ?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keeps unary minus attached to its number', (tester) async {
    await pumpQuestion(tester, 'Tính: -5+-3=?', width: 600);
    expect(find.text('-5 + -3 = ?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kindergarten speaker stays at top left above visual content', (
    tester,
  ) async {
    const prompt = '😺😺😺😺😺 = ?';
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: const Scaffold(
          body: SizedBox(
            width: 320,
            child: AssessmentQuestionCard(question: prompt, grade: 0),
          ),
        ),
      ),
    );
    final card = find.byType(AssessmentQuestionCard);
    final speaker = find.byKey(const ValueKey('read-question'));
    final content = find.text(prompt);
    // The card's 1px border is included in its effective padding.
    expect(tester.getTopLeft(speaker).dx, tester.getTopLeft(card).dx + 17);
    expect(tester.getTopLeft(speaker).dy, tester.getTopLeft(card).dy + 17);
    expect(
      tester.getBottomLeft(speaker).dy,
      lessThan(tester.getTopLeft(content).dy),
    );
    expect(tester.getSize(content).width, 286);
    expect(tester.widget<IconButton>(speaker).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

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
