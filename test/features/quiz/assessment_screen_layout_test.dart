import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/presentation/screens/assessment_screen.dart';

void main() {
  testWidgets('standard questions fit without vertical scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: const AiAssessmentScreen(
            initialQuiz: GeneratedQuiz(
              id: 1,
              questions: <QuizQuestion>[
                QuizQuestion(
                  questionName: '12 + 8 = ?',
                  questionNumber: 1,
                  answers: <QuizAnswer>[
                    QuizAnswer(label: 'A', content: '18'),
                    QuizAnswer(label: 'B', content: '19'),
                    QuizAnswer(label: 'C', content: '20'),
                    QuizAnswer(label: 'D', content: '21'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    final mainScrollable = find.descendant(
      of: find.byKey(const ValueKey('question-content')),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.physics is BouncingScrollPhysics,
      ),
    );
    expect(mainScrollable, findsOneWidget);
    final scrollable = tester.state<ScrollableState>(mainScrollable);
    expect(scrollable.position.maxScrollExtent, 0);
    expect(tester.takeException(), isNull);
  });
}
