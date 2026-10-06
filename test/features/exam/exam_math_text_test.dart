import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_grid.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_question_card.dart';
import 'package:numi/features/exam/widgets/exam_math_text.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_answer_list.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_card.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_result_question_card.dart';

void main() {
  for (final content in <String>[
    r'\frac{1}{3}',
    r'2\frac{1}{3}',
    r'\frac{1}{3} + \frac{2}{3} = 1',
    r'\frac{\frac{1}{2}}{3}',
    r'$\frac{1}{3}$',
    r'$$\frac{1}{3}$$',
    r'\(\frac{1}{3}\)',
    r'\[\frac{1}{3}\]',
  ]) {
    testWidgets('renders a fraction expression: $content', (tester) async {
      await _pump(
        tester,
        ExamMathText(content, style: const TextStyle(fontSize: 24)),
      );
      expect(find.byType(Math), findsOneWidget);
      expect(tester.widget<Math>(find.byType(Math)).parseError, isNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('keeps Vietnamese prose outside inline bare fractions', (
    tester,
  ) async {
    await _pump(
      tester,
      const ExamMathText(
        r'So sánh \frac{1}{3} và \frac{2}{3}',
        style: TextStyle(fontSize: 24),
      ),
    );
    expect(find.byType(Math), findsNWidgets(2));
    for (final math in tester.widgetList<Math>(find.byType(Math))) {
      expect(math.parseError, isNull);
    }
    final text = tester.widget<Text>(find.byType(Text).first);
    expect(
      text.textSpan!.toPlainText(includePlaceholders: false),
      'So sánh  và ',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps prose around delimited formulas', (tester) async {
    await _pump(
      tester,
      const ExamMathText(
        r'Tính $2\frac{1}{3}$ rồi chọn đáp án.',
        style: TextStyle(fontSize: 24),
      ),
    );
    expect(find.byType(Math), findsOneWidget);
    expect(tester.widget<Math>(find.byType(Math)).parseError, isNull);
    final text = tester.widget<Text>(find.byType(Text).first);
    expect(
      text.textSpan!.toPlainText(includePlaceholders: false),
      'Tính  rồi chọn đáp án.',
    );
    expect(tester.takeException(), isNull);
  });

  for (final content in <String>[
    r'\frac{1}{',
    r'Tính $\frac{1}{3}',
    r'Tính $\unknowncommand{1}$',
    'Plain text',
    '',
  ]) {
    testWidgets('invalid or plain content stays readable: $content', (
      tester,
    ) async {
      await _pump(
        tester,
        ExamMathText(content, style: const TextStyle(fontSize: 24)),
      );
      expect(tester.takeException(), isNull);
      if (content.contains('unknowncommand')) {
        expect(find.text(r'\unknowncommand{1}'), findsOneWidget);
      } else {
        final text = tester.widget<Text>(find.byType(Text).first);
        expect(text.textSpan!.toPlainText(), content);
      }
    });
  }

  testWidgets('long inline formula fits a narrow width at large text scale', (
    tester,
  ) async {
    await _pump(
      tester,
      const ExamMathText(
        r'Tính $\frac{123456789012345678901234567890}{3}$ rồi chọn.',
        style: TextStyle(fontSize: 30),
      ),
      width: 220,
      textScale: 1.5,
    );
    expect(find.byType(Math), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  const answers = <ExamAnswer>[
    ExamAnswer(label: 'A', content: r'\frac{1}{3}'),
    ExamAnswer(label: 'B', content: r'\frac{2}{3}'),
  ];
  const fractionQuestion = ExamQuestion(
    questionName: r'So sánh \frac{1}{3} và \frac{2}{3}',
    questionNumber: 1,
    questionType: 'FRACTION',
    answers: answers,
    rightAnswer: 'A',
  );

  testWidgets('attempt renders both question and answers for fractions', (
    tester,
  ) async {
    final selections = <String>[];
    await _pump(
      tester,
      Column(
        children: [
          AssessmentQuestionCard(
            question: fractionQuestion.questionName,
            renderLatex: true,
          ),
          AssessmentAnswerGrid(
            answers: answers,
            renderLatex: true,
            selectedAnswerLabel: null,
            onSelected: (answer) => selections.add(answer.label),
          ),
        ],
      ),
    );
    expect(find.byType(Math), findsNWidgets(4));
    for (final math in tester.widgetList<Math>(find.byType(Math))) {
      expect(math.parseError, isNull);
    }
    await tester.tap(find.text('B'));
    expect(selections, ['B']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-fraction attempt keeps the original text rendering', (
    tester,
  ) async {
    await _pump(
      tester,
      Column(
        children: [
          const AssessmentQuestionCard(question: r'\frac{1}{3}'),
          AssessmentAnswerGrid(
            answers: answers,
            selectedAnswerLabel: null,
            onSelected: (_) {},
          ),
        ],
      ),
    );
    expect(find.byType(Math), findsNothing);
    expect(find.text(r'\frac{1}{3}'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('both review modes render fraction questions and answers', (
    tester,
  ) async {
    await _pump(
      tester,
      const Column(
        children: [
          ExamReviewQuestionCard(question: fractionQuestion),
          ExamReviewAnswerList(question: fractionQuestion, selectedLabel: 'B'),
          ExamReviewResultQuestionCard(
            question: fractionQuestion,
            selectedLabel: 'B',
          ),
        ],
      ),
      width: 280,
    );
    expect(find.byType(Math), findsNWidgets(8));
    for (final math in tester.widgetList<Math>(find.byType(Math))) {
      expect(math.parseError, isNull);
    }
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 360,
  double textScale = 1,
}) async {
  final lingo = LingoProvider();
  addTearDown(lingo.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
      ),
      home: LingoScope(
        lingo: lingo,
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    ),
  );
}
