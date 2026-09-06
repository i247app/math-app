import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/quiz/models/quiz.dart';
import 'package:numi/features/quiz/controllers/assessment_controller.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';

void main() {
  const answers = <QuizAnswer>[
    QuizAnswer(label: 'A', content: '18'),
    QuizAnswer(label: 'B', content: '20'),
  ];
  const quiz = GeneratedQuiz(
    quizId: 7,
    questions: <QuizQuestion>[
      QuizQuestion(
        questionName: '12 + 8 = ?',
        questionNumber: 1,
        answers: answers,
        rightAnswer: 'B',
      ),
      QuizQuestion(
        questionName: '10 + 5 = ?',
        questionNumber: 2,
        answers: answers,
        correctAnswer: '20',
      ),
    ],
  );

  test('can continue before answering the current question', () {
    final controller = AssessmentController(
      quizService: _UnusedQuizService(),
      initialQuiz: quiz,
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
      quizService: _UnusedQuizService(),
      initialQuiz: quiz,
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
      quizService: _UnusedQuizService(),
      initialQuiz: quiz,
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
      quizService: _UnusedQuizService(),
      initialQuiz: quiz,
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
      const quizWithoutCorrectAnswer = GeneratedQuiz(
        questions: <QuizQuestion>[
          QuizQuestion(
            questionName: '12 + 8 = ?',
            questionNumber: 1,
            answers: answers,
          ),
        ],
      );
      final controller = AssessmentController(
        quizService: _UnusedQuizService(),
        initialQuiz: quizWithoutCorrectAnswer,
      );
      addTearDown(controller.dispose);

      expect(controller.isAnswerCorrect(answers.first), isNull);
    },
  );
}

class _UnusedQuizService implements QuizService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
