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
      expect(service.generatedGradeLabels, <String?>['Lớp 2']);
      expect(service.submittedAnswers, hasLength(6));
      expect(service.statusUpdates, isEmpty);
    },
  );

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
    expect(service.statusUpdates, <(int, String)>[(88, 'COMPLETE')]);
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

GeneratedExam _tenQuestionExam({required int examId, required int grade}) {
  return GeneratedExam(
    examId: examId,
    examType: examTypeAssessment,
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
