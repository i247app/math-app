import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_button.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_grid.dart';

void main() {
  for (final icons in <List<String>>[
    <String>['🟡', '🟢', '🔴', '🔵'],
    <String>['👨‍👩‍👧', '👍🏽', '🇻🇳', '1️⃣'],
    <String>['⭐', '☀️', '❤️', '♟️'],
  ]) {
    testWidgets('icon answers form a two by two grid: ${icons.first}', (
      tester,
    ) async {
      final selected = <String>[];
      await _pumpAnswers(tester, icons, selected.add);

      final buttons = find.byType(AssessmentAnswerButton);
      expect(buttons, findsNWidgets(4));
      expect(find.byType(GridView), findsOneWidget);

      final first = tester.getTopLeft(buttons.at(0));
      final second = tester.getTopLeft(buttons.at(1));
      final third = tester.getTopLeft(buttons.at(2));
      final fourth = tester.getTopLeft(buttons.at(3));
      expect(first.dy, second.dy);
      expect(third.dy, fourth.dy);
      expect(second.dx, greaterThan(first.dx));
      expect(third.dy, greaterThan(first.dy));

      await tester.tap(buttons.at(2));
      expect(selected, <String>['C']);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('sentence answers remain in separate full width rows', (
    tester,
  ) async {
    await _pumpAnswers(tester, <String>[
      'Màu vàng',
      'Màu xanh lá',
      'Màu đỏ',
      'Màu xanh dương',
    ], (_) {});

    expect(find.byType(GridView), findsNothing);
    final buttons = find.byType(AssessmentAnswerButton);
    expect(
      tester.getTopLeft(buttons.at(1)).dx,
      tester.getTopLeft(buttons.at(0)).dx,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('icon grid fits a narrow screen with answer feedback', (
    tester,
  ) async {
    await _pumpAnswers(
      tester,
      <String>['🟡', '🟢', '🔴', '🔵'],
      (_) {},
      width: 280,
      selectedAnswerLabel: 'A',
      selectedAnswerFeedbackCorrect: true,
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpAnswers(
  WidgetTester tester,
  List<String> contents,
  ValueChanged<String> onSelected, {
  double width = 360,
  String? selectedAnswerLabel,
  bool? selectedAnswerFeedbackCorrect,
}) async {
  final answers = List<ExamAnswer>.generate(
    contents.length,
    (index) => ExamAnswer(
      label: String.fromCharCode('A'.codeUnitAt(0) + index),
      content: contents[index],
    ),
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
      ),
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: AssessmentAnswerGrid(
            answers: answers,
            selectedAnswerLabel: selectedAnswerLabel,
            selectedAnswerFeedbackCorrect: selectedAnswerFeedbackCorrect,
            onSelected: (answer) => onSelected(answer.label),
          ),
        ),
      ),
    ),
  );
}
