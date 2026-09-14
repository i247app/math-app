import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/controllers/assessment_controller.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';

void main() {
  const answers = <ExamAnswer>[
    ExamAnswer(label: 'A', content: '18'),
    ExamAnswer(label: 'B', content: '20'),
  ];
  const exam = GeneratedExam(
    examId: 7,
    questions: <ExamQuestion>[
      ExamQuestion(
        questionName: '12 + 8 = ?',
        questionNumber: 1,
        answers: answers,
        rightAnswer: 'B',
      ),
      ExamQuestion(
        questionName: '10 + 5 = ?',
        questionNumber: 2,
        answers: answers,
        correctAnswer: '20',
      ),
    ],
  );

  test('can continue before answering the current question', () {
    final controller = AssessmentController(
      examService: _UnusedExamService(),
      initialExam: exam,
    );
    addTearDown(controller.dispose);

    expect(controller.canContinue, isFalse);
    expect(controller.goToNextQuestion(), isTrue);
    expect(controller.questionIndex, 1);
    expect(controller.canContinue, isFalse);
    expect(controller.goToNextQuestion(), isFalse);
  });

  test('jumps to any question and tracks the first unanswered question', () {
    final controller = AssessmentController(
      examService: _UnusedExamService(),
      initialExam: exam,
    );
    addTearDown(controller.dispose);

    expect(controller.firstUnansweredQuestionIndex, 0);
    expect(controller.allQuestionsAnswered, isFalse);
    expect(controller.goToQuestion(1), isTrue);

    controller.selectAnswer(answers.first);
    expect(controller.firstUnansweredQuestionIndex, 0);
    expect(controller.goToQuestion(0), isTrue);

    controller.selectAnswer(answers.last);
    expect(controller.firstUnansweredQuestionIndex, isNull);
    expect(controller.allQuestionsAnswered, isTrue);
    expect(controller.goToQuestion(-1), isFalse);
    expect(controller.goToQuestion(2), isFalse);
  });

  test('checks answers by either their label or displayed content', () {
    final controller = AssessmentController(
      examService: _UnusedExamService(),
      initialExam: exam,
    );
    addTearDown(controller.dispose);

    expect(controller.isAnswerCorrect(answers.first), isFalse);
    expect(controller.isAnswerCorrect(answers.last), isTrue);
    expect(controller.isSelectedAnswerCorrect, isNull);

    controller.selectAnswer(answers.last);
    expect(controller.isSelectedAnswerCorrect, isTrue);
    expect(controller.goToNextQuestion(), isTrue);

    expect(controller.isAnswerCorrect(answers.first), isFalse);
    expect(controller.isAnswerCorrect(answers.last), isTrue);
    expect(controller.isSelectedAnswerCorrect, isNull);
  });

  test('tapping the selected answer again unselects it', () {
    final controller = AssessmentController(
      examService: _UnusedExamService(),
      initialExam: exam,
    );
    addTearDown(controller.dispose);

    controller.selectAnswer(answers.first);
    expect(controller.selectedAnswerLabel, answers.first.label);
    expect(controller.canContinue, isTrue);

    controller.selectAnswer(answers.first);
    expect(controller.selectedAnswerLabel, isNull);
    expect(controller.canContinue, isFalse);
    expect(controller.firstUnansweredQuestionIndex, 0);

    controller.selectAnswer(answers.first);
    controller.selectAnswer(answers.last);
    expect(controller.selectedAnswerLabel, answers.last.label);
  });

  test(
    'updates the current assessment journey status by user exam id',
    () async {
      final service = _RecordingExamService();
      final controller = AssessmentController(
        examService: service,
        examType: examTypeAssessment,
        profileId: 21,
        initialExam: const GeneratedExam(
          examId: 7,
          userExamId: 501,
          profileId: 21,
          examType: examTypeAssessment,
          questions: <ExamQuestion>[],
        ),
      );
      addTearDown(controller.dispose);

      await controller.updateCurrentUserExamStatus('CANCEL');
      await controller.updateCurrentUserExamStatus('ACTIVE');

      expect(service.statusUpdates, <(int, String)>[
        (501, 'CANCEL'),
        (501, 'ACTIVE'),
      ]);
    },
  );

  test(
    'does not report incorrect when the server omits the correct answer',
    () {
      const examWithoutCorrectAnswer = GeneratedExam(
        questions: <ExamQuestion>[
          ExamQuestion(
            questionName: '12 + 8 = ?',
            questionNumber: 1,
            answers: answers,
          ),
        ],
      );
      final controller = AssessmentController(
        examService: _UnusedExamService(),
        initialExam: examWithoutCorrectAnswer,
      );
      addTearDown(controller.dispose);

      expect(controller.isAnswerCorrect(answers.first), isNull);
    },
  );

  test(
    'restores saved answers and resumes at the first unanswered question',
    () {
      final controller = AssessmentController(
        examService: _UnusedExamService(),
        examType: examTypeAssessment,
        initialExam: GeneratedExam(
          examId: 77,
          userExamId: 501,
          examType: examTypeAssessment,
          answers: const <SubmitExamAnswer>[
            SubmitExamAnswer(questionNumber: 1, label: 'B'),
            SubmitExamAnswer(questionNumber: 2, label: 'A'),
          ],
          questions: List<ExamQuestion>.generate(
            4,
            (index) => ExamQuestion(
              questionName: 'Resume question ${index + 1}',
              questionNumber: index + 1,
              answers: answers,
              rightAnswer: 'B',
            ),
          ),
        ),
      );
      addTearDown(controller.dispose);

      expect(controller.selectedAnswerLabels, <int, String>{0: 'B', 1: 'A'});
      expect(controller.questionIndex, 2);
      expect(controller.currentQuestion?.questionName, 'Resume question 3');
    },
  );

  test(
    'uses the API resume position even when an earlier answer was skipped',
    () {
      final controller = AssessmentController(
        examService: _UnusedExamService(),
        initialExam: GeneratedExam(
          examId: 301,
          examType: examTypeAssessment,
          grade: 1,
          resumeQuestionIndex: 2,
          questions: List<ExamQuestion>.generate(
            4,
            (index) => ExamQuestion(
              questionName: 'Question ${index + 1}',
              questionNumber: index + 1,
              answers: answers,
              rightAnswer: 'B',
            ),
          ),
          answers: const <SubmitExamAnswer>[
            SubmitExamAnswer(questionNumber: 2, label: 'A'),
          ],
        ),
      );
      addTearDown(controller.dispose);

      expect(controller.selectedAnswerLabels, const <int, String>{1: 'A'});
      expect(controller.questionIndex, 2);
      expect(controller.currentQuestion?.questionNumber, 3);
    },
  );

  test('starts a generated assessment at kindergarten', () async {
    final service = _RecordingExamService();
    final controller = AssessmentController(
      examService: service,
      gradeLabel: 'Lớp 4',
    );
    addTearDown(controller.dispose);

    expect(await controller.generateExam(), isTrue);
    expect(service.generatedGradeLabels, <String?>['Mẫu giáo']);
    expect(controller.currentGrade, 0);
    expect(controller.setNumber, 1);
  });

  test(
    'generates only after question six resolves grade 0 to grade 2',
    () async {
      final service = _RecordingExamService();
      final controller = AssessmentController(
        examService: service,
        initialExam: _tenQuestionExam(examId: 77, grade: 0),
      );
      addTearDown(controller.dispose);

      for (var index = 0; index < 5; index++) {
        controller.selectAnswer(answers.last);
        await controller.advanceAssessmentFlow();
        if (index < 4) {
          expect(controller.goToNextQuestion(), isTrue);
        }
      }

      expect(service.generatedGradeLabels, isEmpty);
      expect(controller.goToNextQuestion(), isTrue);
      controller.selectAnswer(answers.last);
      final action = await controller.advanceAssessmentFlow();

      expect(action, AssessmentFlowAction.generateSet);
      expect(controller.currentGrade, 2);
      expect(controller.setNumber, 2);
      expect(controller.questionIndex, 0);
      expect(controller.completedSets, hasLength(1));
      expect(controller.completedSets.single.correctAnswerCount, 6);
      expect(controller.totalCorrectAnswerCount, 6);
      expect(controller.totalAnsweredQuestionCount, 6);
      expect(service.generatedGradeLabels, <String?>['Lớp 2']);
      expect(service.submittedAnswers, hasLength(6));
      expect(service.statusUpdates, isEmpty);

      controller.selectAnswer(answers.first);
      expect(controller.totalCorrectAnswerCount, 6);
      expect(controller.totalAnsweredQuestionCount, 7);
    },
  );

  test('waits for submit to finish before generating the next set', () async {
    final service = _SequentialTransitionExamService();
    final controller = AssessmentController(
      examService: service,
      initialExam: _tenQuestionExam(examId: 92, grade: 0),
    );
    addTearDown(controller.dispose);

    for (var index = 0; index < 6; index++) {
      controller.selectAnswer(answers.last);
      if (index < 5) {
        expect(
          await controller.advanceAssessmentFlow(),
          AssessmentFlowAction.continueSet,
        );
        expect(controller.goToNextQuestion(), isTrue);
      }
    }

    final transition = controller.advanceAssessmentFlow();
    await Future<void>.delayed(Duration.zero);

    expect(service.events, <String>['submit:start']);
    expect(service.generateCalls, 0);

    service.completeSubmit();
    await Future<void>.delayed(Duration.zero);

    expect(service.events, <String>['submit:start', 'generate:start']);
    expect(service.generateCalls, 1);

    service.completeGenerate();
    expect(await transition, AssessmentFlowAction.generateSet);
    expect(controller.currentGrade, 2);
  });

  test(
    'does not generate when a missed first six continues the current set',
    () async {
      final service = _RecordingExamService();
      final controller = AssessmentController(
        examService: service,
        initialExam: _tenQuestionExam(examId: 78, grade: 2),
      );
      addTearDown(controller.dispose);

      for (var index = 0; index < 6; index++) {
        controller.selectAnswer(index == 0 ? answers.first : answers.last);
        expect(
          await controller.advanceAssessmentFlow(),
          AssessmentFlowAction.continueSet,
        );
        if (index < 5) {
          expect(controller.goToNextQuestion(), isTrue);
        }
      }

      expect(controller.goToNextQuestion(), isTrue);
      expect(controller.questionIndex, 6);
      expect(service.generatedGradeLabels, isEmpty);
      expect(controller.isGeneratingQuestion, isFalse);
      expect(controller.setNumber, 1);
    },
  );

  test('submits five answers and downgrades after five early misses', () async {
    final service = _RecordingExamService();
    final controller = AssessmentController(
      examService: service,
      initialExam: _tenQuestionExam(examId: 79, grade: 2),
    );
    addTearDown(controller.dispose);

    AssessmentFlowAction action = AssessmentFlowAction.continueSet;
    for (var index = 0; index < 5; index++) {
      controller.selectAnswer(answers.first);
      action = await controller.advanceAssessmentFlow();
      if (index < 4) {
        expect(controller.goToNextQuestion(), isTrue);
      }
    }

    expect(action, AssessmentFlowAction.generateSet);
    expect(controller.currentGrade, 1);
    expect(controller.flowMode, AssessmentFlowMode.recovery);
    expect(controller.isFailed, isTrue);
    expect(controller.setNumber, 2);
    expect(controller.completedSets, hasLength(1));
    expect(controller.completedSets.single.correctAnswerCount, 0);
    expect(controller.completedSets.single.selectedAnswerLabels, hasLength(5));
    expect(service.submittedAnswers, hasLength(5));
    expect(service.generatedGradeLabels, <String?>['Lớp 1']);
  });

  test('grade zero early fail generates recovery at the same grade', () async {
    final service = _RecordingExamService();
    final controller = AssessmentController(
      examService: service,
      initialExam: _tenQuestionExam(examId: 80, grade: 0),
    );
    addTearDown(controller.dispose);

    AssessmentFlowAction action = AssessmentFlowAction.continueSet;
    for (var index = 0; index < 5; index++) {
      controller.selectAnswer(answers.first);
      action = await controller.advanceAssessmentFlow();
      if (index < 4) {
        expect(controller.goToNextQuestion(), isTrue);
      }
    }

    expect(action, AssessmentFlowAction.generateSet);
    expect(controller.currentGrade, 0);
    expect(controller.flowMode, AssessmentFlowMode.recovery);
    expect(controller.isFailed, isTrue);
    expect(controller.setNumber, 2);
    expect(service.submittedAnswers, hasLength(5));
    expect(service.generatedGradeLabels, <String?>['Mẫu giáo']);
  });

  test('50 percent without Q3 or Q6 stops without changing grade', () async {
    final service = _RecordingExamService();
    final controller = AssessmentController(
      examService: service,
      initialExam: _tenQuestionExam(examId: 81, grade: 2),
    );
    addTearDown(controller.dispose);
    const correctIndexes = <int>{0, 1, 3, 4, 6};

    AssessmentFlowAction action = AssessmentFlowAction.continueSet;
    for (var index = 0; index < 10; index++) {
      controller.selectAnswer(
        correctIndexes.contains(index) ? answers.last : answers.first,
      );
      action = await controller.advanceAssessmentFlow();
      if (index < 9) {
        expect(controller.goToNextQuestion(), isTrue);
      }
    }

    expect(action, AssessmentFlowAction.submit);
    expect(controller.currentGrade, 2);
    expect(controller.flowMode, AssessmentFlowMode.normal);
    expect(controller.isFailed, isFalse);
    expect(service.generatedGradeLabels, isEmpty);
  });

  test('50 percent with only Q3 correct generates grade plus one', () async {
    final service = _RecordingExamService();
    final controller = AssessmentController(
      examService: service,
      initialExam: _tenQuestionExam(examId: 82, grade: 2),
    );
    addTearDown(controller.dispose);
    const correctIndexes = <int>{0, 2, 4, 7, 8};

    AssessmentFlowAction action = AssessmentFlowAction.continueSet;
    for (var index = 0; index < 10; index++) {
      controller.selectAnswer(
        correctIndexes.contains(index) ? answers.last : answers.first,
      );
      action = await controller.advanceAssessmentFlow();
      if (index < 9) {
        expect(controller.goToNextQuestion(), isTrue);
      }
    }

    expect(action, AssessmentFlowAction.generateSet);
    expect(controller.currentGrade, 3);
    expect(controller.flowMode, AssessmentFlowMode.normal);
    expect(controller.isFailed, isFalse);
    expect(service.generatedGradeLabels, <String?>['Lớp 3']);
  });

  test('grade 5 submits only the first six correct answers', () async {
    final service = _RecordingExamService();
    final controller = AssessmentController(
      examService: service,
      initialExam: _tenQuestionExam(examId: 88, grade: 5),
    );
    addTearDown(controller.dispose);

    AssessmentFlowAction action = AssessmentFlowAction.continueSet;
    for (var index = 0; index < assessmentCorrectAnswerTarget; index++) {
      controller.selectAnswer(answers.last);
      action = await controller.advanceAssessmentFlow();
      if (index < assessmentCorrectAnswerTarget - 1) {
        controller.goToNextQuestion();
      }
    }

    expect(action, AssessmentFlowAction.submit);
    expect(controller.shouldAutoSubmitAssessment, isTrue);
    expect(
      (await controller.submitCurrentExam()).status,
      AssessmentSubmitStatus.submitted,
    );
    expect(service.generatedGradeLabels, isEmpty);
    expect(service.submittedAnswers, hasLength(6));
    expect(service.statusUpdates, isEmpty);
  });

  test('practice exams still require every question to be answered', () async {
    final service = _RecordingExamService();
    final controller = AssessmentController(
      examService: service,
      examType: examTypePractice,
      initialExam: GeneratedExam(
        examId: 88,
        examType: examTypePractice,
        questions: List<ExamQuestion>.generate(
          10,
          (index) => ExamQuestion(
            questionName: 'Question ${index + 1}',
            questionNumber: index + 1,
            answers: answers,
            rightAnswer: 'B',
          ),
        ),
      ),
    );
    addTearDown(controller.dispose);

    for (var index = 0; index < assessmentCorrectAnswerTarget; index++) {
      controller.selectAnswer(answers.last);
      if (index < assessmentCorrectAnswerTarget - 1) {
        controller.goToNextQuestion();
      }
    }

    expect(controller.shouldAutoSubmitAssessment, isFalse);
    expect(
      (await controller.submitCurrentExam()).status,
      AssessmentSubmitStatus.unanswered,
    );
    expect(service.submittedAnswers, isNull);
  });

  test('practice keeps the first answer while allowing retries', () {
    final controller = AssessmentController(
      examService: _UnusedExamService(),
      examType: examTypePractice,
      initialExam: _tenQuestionExam(
        examId: 89,
        grade: 2,
        examType: examTypePractice,
      ),
    );
    addTearDown(controller.dispose);

    controller.selectAnswer(answers.first);
    expect(controller.selectedAnswerLabels[0], 'A');
    expect(controller.selectedAnswerFeedbackCorrect, isFalse);
    expect(controller.canContinue, isTrue);

    controller.clearPracticeFeedback();
    expect(controller.selectedAnswerLabel, 'A');
    expect(controller.selectedAnswerFeedbackCorrect, isNull);
    expect(controller.selectedAnswerLabels[0], 'A');

    controller.selectAnswer(answers.last);
    expect(controller.selectedAnswerLabels[0], 'A');
    expect(controller.selectedAnswerLabel, 'B');
    expect(controller.selectedAnswerFeedbackCorrect, isTrue);
    expect(controller.canContinue, isTrue);

    controller.clearPracticeFeedback();
    expect(controller.selectedAnswerLabel, 'B');
    expect(controller.selectedAnswerFeedbackCorrect, isNull);

    controller.selectAnswer(answers.first);
    expect(controller.selectedAnswerLabels[0], 'A');
    expect(controller.selectedAnswerLabel, 'A');
    expect(controller.selectedAnswerFeedbackCorrect, isFalse);
    expect(controller.canContinue, isTrue);
  });

  test('practice submits the first six perfect first attempts', () async {
    final service = _RecordingExamService();
    final controller = AssessmentController(
      examService: service,
      examType: examTypePractice,
      initialExam: _tenQuestionExam(
        examId: 90,
        grade: 3,
        examType: examTypePractice,
      ),
    );
    addTearDown(controller.dispose);

    AssessmentFlowAction action = AssessmentFlowAction.continueSet;
    for (var index = 0; index < 6; index++) {
      controller.selectAnswer(answers.last);
      action = controller.preparePracticeFlow();
      if (index < 5) {
        expect(action, AssessmentFlowAction.continueSet);
        expect(controller.goToNextQuestion(), isTrue);
      }
    }

    expect(action, AssessmentFlowAction.submit);
    final result = await controller.submitCurrentExam();
    expect(result.status, AssessmentSubmitStatus.submitted);
    expect(service.submittedAnswers, hasLength(6));
    expect(
      service.submittedAnswers!.every((answer) => answer.label == 'B'),
      isTrue,
    );
    expect(service.statusUpdates, isEmpty);
    expect(result.exam?.examType, examTypePractice);
    expect(result.exam?.questions, hasLength(10));
    expect(result.exam?.answers, hasLength(6));
    expect(result.exam?.grading?.correctNumber, 6);
    expect(result.exam?.grading?.totalQuestions, 6);
  });

  test(
    'practice submits after first-attempt mistakes exceed fifty percent',
    () async {
      final service = _RecordingExamService();
      final controller = AssessmentController(
        examService: service,
        examType: examTypePractice,
        initialExam: _tenQuestionExam(
          examId: 91,
          grade: 4,
          examType: examTypePractice,
        ),
      );
      addTearDown(controller.dispose);

      AssessmentFlowAction action = AssessmentFlowAction.continueSet;
      for (var index = 0; index < 6; index++) {
        controller.selectAnswer(answers.first);
        expect(controller.canContinue, isTrue);
        controller.clearPracticeFeedback();
        controller.selectAnswer(answers.last);
        expect(controller.canContinue, isTrue);
        action = controller.preparePracticeFlow();
        if (index < 5) {
          expect(action, AssessmentFlowAction.continueSet);
          expect(controller.goToNextQuestion(), isTrue);
        }
      }

      expect(action, AssessmentFlowAction.submit);
      final result = await controller.submitCurrentExam();
      expect(result.status, AssessmentSubmitStatus.submitted);
      expect(service.submittedAnswers, hasLength(6));
      expect(
        service.submittedAnswers!.every((answer) => answer.label == 'A'),
        isTrue,
      );
      expect(result.exam?.grading?.correctNumber, 0);
      expect(result.exam?.grading?.totalQuestions, 6);
    },
  );
}

class _UnusedExamService implements ExamService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingExamService implements ExamService {
  List<SubmitExamAnswer>? submittedAnswers;
  final List<String?> generatedGradeLabels = <String?>[];
  final List<(int, String)> statusUpdates = <(int, String)>[];

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? profileId,
    int? userExamId,
  }) async {
    generatedGradeLabels.add(gradeLabel);
    final grade =
        int.tryParse(
          RegExp(r'\d+').firstMatch(gradeLabel ?? '')?.group(0) ?? '',
        ) ??
        0;
    return _tenQuestionExam(
      examId: 100 + generatedGradeLabels.length,
      grade: grade,
    );
  }

  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) async {
    submittedAnswers = List<SubmitExamAnswer>.from(answers);
    return GeneratedExam(
      examId: examId,
      userExamId: 9000 + examId,
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
  }) async {
    statusUpdates.add((userExamId, status));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SequentialTransitionExamService implements ExamService {
  final Completer<GeneratedExam> _submitCompleter = Completer<GeneratedExam>();
  final Completer<GeneratedExam> _generateCompleter =
      Completer<GeneratedExam>();
  final List<String> events = <String>[];
  int generateCalls = 0;

  void completeSubmit() {
    _submitCompleter.complete(
      const GeneratedExam(
        examId: 92,
        userExamId: 9092,
        examType: examTypeAssessment,
        examStatus: 'SUBMITTED',
        questions: <ExamQuestion>[],
      ),
    );
  }

  void completeGenerate() {
    _generateCompleter.complete(_tenQuestionExam(examId: 93, grade: 2));
  }

  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) {
    events.add('submit:start');
    return _submitCompleter.future;
  }

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? profileId,
    int? userExamId,
  }) {
    generateCalls++;
    events.add('generate:start');
    return _generateCompleter.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

GeneratedExam _tenQuestionExam({
  required int examId,
  required int grade,
  String examType = examTypeAssessment,
}) {
  return GeneratedExam(
    examId: examId,
    aiExamId: 7000 + examId,
    examType: examType,
    grade: grade,
    questions: List<ExamQuestion>.generate(
      10,
      (index) => ExamQuestion(
        questionName: 'Question ${index + 1}',
        questionNumber: index + 1,
        answers: const <ExamAnswer>[
          ExamAnswer(label: 'A', content: '18'),
          ExamAnswer(label: 'B', content: '20'),
        ],
        rightAnswer: 'B',
      ),
    ),
  );
}
