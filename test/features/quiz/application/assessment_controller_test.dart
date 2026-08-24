import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/application/assessment_controller.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';

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

  test('cannot continue before answering the current question', () {
    final controller = AssessmentController(
      quizService: _UnusedQuizService(),
      initialQuiz: quiz,
    );
    addTearDown(controller.dispose);

    expect(controller.canContinue, isFalse);
    expect(controller.goToNextQuestion(), isFalse);
    expect(controller.questionIndex, 0);

    controller.selectAnswer(answers.first);

    expect(controller.canContinue, isTrue);
    expect(controller.goToNextQuestion(), isTrue);
    expect(controller.questionIndex, 1);
    expect(controller.canContinue, isFalse);
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
