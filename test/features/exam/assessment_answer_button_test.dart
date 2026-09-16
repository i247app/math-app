import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_button.dart';

void main() {
  testWidgets('normalizes Unicode separators and wraps a long answer', (
    tester,
  ) async {
    const expected = 'Số sau hơn số trước 5 đơn vị và tiếp tục tăng đều';
    final source = expected
        .replaceFirst(' ', '\u2007')
        .replaceFirst(' ', '\u2060')
        .replaceFirst(' ', '\uFEFF');

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: AssessmentAnswerButton(
              answer: ExamAnswer(label: 'A', content: source),
              selected: false,
              onTap: _doNothing,
            ),
          ),
        ),
      ),
    );

    final textFinder = find.text(expected);
    final answerText = tester.widget<Text>(textFinder);
    final paragraph = tester.renderObject<RenderParagraph>(textFinder);
    expect(answerText.softWrap, isTrue);
    expect(answerText.maxLines, isNull);
    expect(answerText.overflow, TextOverflow.visible);
    expect(answerText.textWidthBasis, TextWidthBasis.parent);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.getSize(textFinder).height, greaterThan(24));
    expect(tester.takeException(), isNull);
  });
}

void _doNothing() {}
