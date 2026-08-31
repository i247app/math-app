import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/presentation/screens/assessment_screen.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_bottom_action_button.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_bottom_bar.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_progress_section.dart';

class _UnusedQuizService implements QuizService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('standard questions fit without vertical scrolling', (
    tester,
  ) async {
    await _pumpAssessment(tester);

    final mainScrollable = find.descendant(
      of: find.byKey(const ValueKey('question-content')),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            widget.axisDirection == AxisDirection.down &&
            widget.physics is BouncingScrollPhysics,
      ),
    );
    expect(mainScrollable, findsOneWidget);
    final scrollable = tester.state<ScrollableState>(mainScrollable);
    expect(scrollable.position.maxScrollExtent, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom actions stay above Android navigation bar', (
    tester,
  ) async {
    const systemBottomInset = 48.0;
    await _pumpAssessment(tester, bottomInset: systemBottomInset);

    final bottomBar = find.byType(AssessmentBottomBar);
    expect(
      tester.getSize(bottomBar).height,
      AssessmentBottomBar.contentHeight + systemBottomInset,
    );

    final actionButtons = find.descendant(
      of: bottomBar,
      matching: find.byType(AssessmentBottomActionButton),
    );
    expect(actionButtons, findsNWidgets(2));
    for (final element in actionButtons.evaluate()) {
      final button = find.byWidget(element.widget);
      expect(tester.getBottomLeft(button).dy, lessThanOrEqualTo(844 - 48));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shows submit immediately after answering the last unanswered question',
    (tester) async {
      await _pumpAssessment(
        tester,
        questions: const <QuizQuestion>[
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
          QuizQuestion(
            questionName: '20 + 10 = ?',
            questionNumber: 2,
            answers: <QuizAnswer>[
              QuizAnswer(label: 'A', content: '28'),
              QuizAnswer(label: 'B', content: '29'),
              QuizAnswer(label: 'C', content: '30'),
              QuizAnswer(label: 'D', content: '31'),
            ],
          ),
        ],
      );

      await tester.tap(
        find.descendant(
          of: find.byType(AssessmentProgressSection),
          matching: find.text('2'),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('30'));
      await tester.pump();

      await tester.tap(
        find.descendant(
          of: find.byType(AssessmentProgressSection),
          matching: find.text('1'),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      await tester.tap(find.text('20'));
      await tester.pump();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _pumpAssessment(
  WidgetTester tester, {
  double bottomInset = 0,
  List<QuizQuestion>? questions,
}) async {
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
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(430, 844),
          padding: EdgeInsets.only(bottom: bottomInset),
          viewPadding: EdgeInsets.only(bottom: bottomInset),
        ),
        child: LingoScope(
          lingo: lingo,
          child: AiAssessmentScreen(
            quizService: _UnusedQuizService(),
            initialQuiz: GeneratedQuiz(
              id: 1,
              questions:
                  questions ??
                  const <QuizQuestion>[
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
    ),
  );

  await tester.pump();
}
