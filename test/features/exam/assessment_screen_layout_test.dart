import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/controllers/assessment_controller.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/screens/assessment_screen.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_button.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_bottom_action_button.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_bottom_bar.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_progress_section.dart';

class _UnusedExamService implements ExamService {
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
    final previousButton = tester.widget<AssessmentBottomActionButton>(
      actionButtons.first,
    );
    expect(previousButton.onTap, isNull);
    expect(
      previousButton.disabledBackground,
      AppThemeColors.light.disabledBackground,
    );
    expect(
      previousButton.disabledForeground,
      AppThemeColors.light.disabledForeground,
    );
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
        questions: const <ExamQuestion>[
          ExamQuestion(
            questionName: '12 + 8 = ?',
            questionNumber: 1,
            answers: <ExamAnswer>[
              ExamAnswer(label: 'A', content: '18'),
              ExamAnswer(label: 'B', content: '19'),
              ExamAnswer(label: 'C', content: '20'),
              ExamAnswer(label: 'D', content: '21'),
            ],
          ),
          ExamQuestion(
            questionName: '20 + 10 = ?',
            questionNumber: 2,
            answers: <ExamAnswer>[
              ExamAnswer(label: 'A', content: '28'),
              ExamAnswer(label: 'B', content: '29'),
              ExamAnswer(label: 'C', content: '30'),
              ExamAnswer(label: 'D', content: '31'),
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

  testWidgets('keeps question navigation scroll offset after switching', (
    tester,
  ) async {
    final questions = List<ExamQuestion>.generate(
      10,
      (index) => ExamQuestion(
        questionName: '${index + 1} + 1 = ?',
        questionNumber: index + 1,
        answers: const <ExamAnswer>[
          ExamAnswer(label: 'A', content: '1'),
          ExamAnswer(label: 'B', content: '2'),
          ExamAnswer(label: 'C', content: '3'),
          ExamAnswer(label: 'D', content: '4'),
        ],
      ),
    );
    await _pumpAssessment(tester, questions: questions);

    final navigation = find.byKey(
      const PageStorageKey<String>('assessment-question-navigation'),
    );
    await tester.drag(navigation, const Offset(-220, 0));
    await tester.pumpAndSettle();

    ScrollableState navigationState() => tester.state<ScrollableState>(
      find.descendant(
        of: navigation,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.right,
        ),
      ),
    );

    final offsetBeforeSwitch = navigationState().position.pixels;
    expect(offsetBeforeSwitch, greaterThan(0));

    await tester.tap(
      find.descendant(
        of: find.byType(AssessmentProgressSection),
        matching: find.text('7'),
      ),
    );
    await tester.pumpAndSettle();

    expect(navigationState().position.pixels, closeTo(offsetBeforeSwitch, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('can disable switching questions from the progress circles', (
    tester,
  ) async {
    await _pumpAssessment(
      tester,
      allowQuestionNavigation: false,
      questions: const <ExamQuestion>[
        ExamQuestion(
          questionName: 'First question',
          questionNumber: 1,
          answers: <ExamAnswer>[
            ExamAnswer(label: 'A', content: '1'),
            ExamAnswer(label: 'B', content: '2'),
          ],
        ),
        ExamQuestion(
          questionName: 'Second question',
          questionNumber: 2,
          answers: <ExamAnswer>[
            ExamAnswer(label: 'A', content: '3'),
            ExamAnswer(label: 'B', content: '4'),
          ],
        ),
      ],
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AssessmentProgressSection),
        matching: find.text('2'),
      ),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(find.text('First question'), findsOneWidget);
    expect(find.text('Second question'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'grade 5 assessment submits immediately after the sixth correct answer',
    (tester) async {
      final service = _PendingSubmitExamService();
      final questions = List<ExamQuestion>.generate(
        10,
        (index) => ExamQuestion(
          questionName: 'Question ${index + 1}',
          questionNumber: index + 1,
          rightAnswer: 'A',
          answers: const <ExamAnswer>[
            ExamAnswer(label: 'A', content: 'Correct'),
            ExamAnswer(label: 'B', content: 'Incorrect'),
          ],
        ),
      );
      await _pumpAssessment(
        tester,
        questions: questions,
        examService: service,
        initialGrade: 5,
        examType: examTypeAssessment,
      );

      for (var index = 0; index < assessmentCorrectAnswerTarget; index++) {
        await tester.tap(find.byType(AssessmentAnswerButton).first);
        await tester.pump();
        if (index < assessmentCorrectAnswerTarget - 1) {
          await tester.tap(find.byType(AssessmentBottomActionButton).last);
          await tester.pump();
        }
      }

      expect(service.submitCalls, 1);
      expect(
        service.submittedAnswers,
        hasLength(assessmentCorrectAnswerTarget),
      );
      expect(
        service.submittedAnswers!.map((answer) => answer.questionNumber),
        orderedEquals(<int>[1, 2, 3, 4, 5, 6]),
      );
      expect(find.byKey(const ValueKey('submit-loader')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'completed assessment review loads the entire journey by user exam id',
    (tester) async {
      final service = _CompletedJourneyReviewExamService();
      await _pumpAssessment(
        tester,
        questions: _setQuestions('Completed set'),
        examService: service,
        initialGrade: 5,
        examType: examTypeAssessment,
      );

      for (var index = 0; index < assessmentCorrectAnswerTarget; index++) {
        await tester.tap(find.byType(AssessmentAnswerButton).first);
        await tester.pump();
        if (index < assessmentCorrectAnswerTarget - 1) {
          await tester.tap(find.byType(AssessmentBottomActionButton).last);
          await tester.pump();
        }
      }
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('placement-view-details')));
      await tester.pumpAndSettle();

      expect(service.requestedDetailId, 91001);
      expect(service.requestedUserExamId, 91001);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'shows question seven skeleton while generating the resolved next set',
    (tester) async {
      final service = _PendingGenerateExamService();
      await _pumpAssessment(
        tester,
        questions: _setQuestions('Set 1'),
        examService: service,
        examType: examTypeAssessment,
      );

      for (var index = 0; index < 5; index++) {
        await tester.tap(find.byType(AssessmentAnswerButton).first);
        await tester.pump();
        if (index < 4) {
          await tester.tap(find.byType(AssessmentBottomActionButton).last);
          await tester.pump();
        }
      }

      expect(service.generateCalls, 0);
      expect(service.requestedGradeLabels, isEmpty);
      expect(find.text('Set 1 - Question 5'), findsOneWidget);
      expect(find.byKey(const ValueKey('question-loader')), findsNothing);

      await tester.tap(find.byType(AssessmentBottomActionButton).last);
      await tester.pump();
      expect(find.text('Set 1 - Question 6'), findsOneWidget);

      await tester.tap(find.byType(AssessmentAnswerButton).first);
      await tester.pump();

      expect(find.text('Set 1 - Question 6'), findsOneWidget);
      expect(find.byKey(const ValueKey('question-loader')), findsNothing);

      await tester.tap(find.byType(AssessmentBottomActionButton).last);
      await tester.pump();

      expect(service.generateCalls, 1);
      expect(service.requestedGradeLabels, <String?>['Lớp 2']);
      expect(service.submitCalls, 1);
      expect(service.submittedAnswers, hasLength(6));
      expect(
        find.byKey(const ValueKey('assessment-question-skeleton')),
        findsOneWidget,
      );
      expect(find.text('Set 1 - Question 6'), findsNothing);
      expect(find.byKey(const ValueKey('question-loader')), findsNothing);
      final loadingQuestionLabel = tester.widget<Text>(
        find.byKey(const ValueKey('assessment-question-label')),
      );
      expect(loadingQuestionLabel.data, contains('7'));

      service.completeNextSet();
      await tester.pumpAndSettle();

      expect(find.text('Set 2 - Question 1'), findsOneWidget);
      final questionLabel = tester.widget<Text>(
        find.byKey(const ValueKey('assessment-question-label')),
      );
      expect(questionLabel.data, contains('7'));
      expect(find.byKey(const ValueKey('question-loader')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

List<ExamQuestion> _setQuestions(String setName) {
  return List<ExamQuestion>.generate(
    10,
    (index) => ExamQuestion(
      questionName: '$setName - Question ${index + 1}',
      questionNumber: index + 1,
      rightAnswer: 'A',
      answers: const <ExamAnswer>[
        ExamAnswer(label: 'A', content: 'Correct'),
        ExamAnswer(label: 'B', content: 'Incorrect'),
      ],
    ),
  );
}

Future<void> _pumpAssessment(
  WidgetTester tester, {
  double bottomInset = 0,
  List<ExamQuestion>? questions,
  bool allowQuestionNavigation = true,
  ExamService? examService,
  int initialGrade = 0,
  String examType = examTypePractice,
}) async {
  tester.view.physicalSize = const Size(430, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final lingo = LingoProvider();
  addTearDown(lingo.dispose);

  await tester.pumpWidget(
    LingoScope(
      lingo: lingo,
      child: MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(430, 844),
            padding: EdgeInsets.only(bottom: bottomInset),
            viewPadding: EdgeInsets.only(bottom: bottomInset),
          ),
          child: AiAssessmentScreen(
            examService: examService ?? _UnusedExamService(),
            examType: examType,
            allowQuestionNavigation: allowQuestionNavigation,
            initialExam: GeneratedExam(
              id: 1,
              examId: 1,
              aiExamId: 7,
              examType: examType,
              grade: initialGrade,
              questions:
                  questions ??
                  const <ExamQuestion>[
                    ExamQuestion(
                      questionName: '12 + 8 = ?',
                      questionNumber: 1,
                      answers: <ExamAnswer>[
                        ExamAnswer(label: 'A', content: '18'),
                        ExamAnswer(label: 'B', content: '19'),
                        ExamAnswer(label: 'C', content: '20'),
                        ExamAnswer(label: 'D', content: '21'),
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

class _PendingSubmitExamService implements ExamService {
  final Completer<GeneratedExam> _submitCompleter = Completer<GeneratedExam>();
  int submitCalls = 0;
  List<SubmitExamAnswer>? submittedAnswers;

  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) {
    submitCalls++;
    submittedAnswers = List<SubmitExamAnswer>.from(answers);
    return _submitCompleter.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CompletedJourneyReviewExamService implements ExamService {
  int? requestedDetailId;
  int? requestedUserExamId;

  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) async {
    return GeneratedExam(
      examId: examId,
      userAiExamId: examId,
      userExamId: 91001,
      profileId: profileId,
      examType: examTypeAssessment,
      examStatus: 'SUBMITTED',
      questions: const <ExamQuestion>[],
    );
  }

  @override
  Future<void> updateUserExamStatus({
    required int userExamId,
    required String status,
    int? profileId,
  }) async {}

  @override
  Future<GeneratedExam> getExamDetail(
    int detailId, {
    int? profileId,
    int? userExamId,
  }) async {
    requestedDetailId = detailId;
    requestedUserExamId = userExamId;
    return GeneratedExam(
      userExamId: userExamId,
      grade: 5,
      grading: const ExamGrading(correctNumber: 6, totalQuestions: 6),
      answers: List<SubmitExamAnswer>.generate(
        6,
        (index) => SubmitExamAnswer(questionNumber: index + 1, label: 'A'),
      ),
      questions: _setQuestions('Journey').take(6).toList(growable: false),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PendingGenerateExamService implements ExamService {
  final Completer<GeneratedExam> _nextSetCompleter = Completer<GeneratedExam>();
  int generateCalls = 0;
  int submitCalls = 0;
  List<SubmitExamAnswer>? submittedAnswers;
  final List<String?> requestedGradeLabels = <String?>[];

  void completeNextSet() {
    _nextSetCompleter.complete(
      GeneratedExam(
        examId: 2,
        examType: examTypeAssessment,
        grade: 2,
        questions: _setQuestions('Set 2'),
      ),
    );
  }

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? profileId,
  }) {
    generateCalls++;
    requestedGradeLabels.add(gradeLabel);
    return _nextSetCompleter.future;
  }

  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) async {
    submitCalls++;
    submittedAnswers = List<SubmitExamAnswer>.from(answers);
    return GeneratedExam(
      examId: examId,
      examType: examTypeAssessment,
      examStatus: 'SUBMITTED',
      questions: const <ExamQuestion>[],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
