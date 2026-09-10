import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/controllers/assessment_controller.dart';
import 'package:numi/features/exam/data/exam_service.dart';

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

  test(
    'submits only six answered questions after six correct assessments',
    () async {
      final service = _RecordingExamService();
      final controller = AssessmentController(
        examService: service,
        initialExam: GeneratedExam(
          examId: 77,
          examType: examTypeAssessment,
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
          expect(controller.goToNextQuestion(), isTrue);
        }
      }

      expect(controller.correctAnswerCount, assessmentCorrectAnswerTarget);
      expect(controller.shouldAutoSubmitAssessment, isTrue);

      final result = await controller.submitCurrentExam();

      expect(result.status, AssessmentSubmitStatus.submitted);
      expect(
        service.submittedAnswers,
        hasLength(assessmentCorrectAnswerTarget),
      );
      expect(
        service.submittedAnswers!.map((answer) => answer.questionNumber),
        orderedEquals(<int>[1, 2, 3, 4, 5, 6]),
      );
    },
  );

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
