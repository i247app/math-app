import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/application/quiz_review_controller.dart';
import 'package:numi/features/quiz/data/cache/quiz_cache.dart';

void main() {
  test('fresh cached detail replaces a question-less list summary', () async {
    const quizId = 981234001;
    const detail = GeneratedQuiz(
      id: quizId,
      answers: <SubmitQuizAnswer>[
        SubmitQuizAnswer(questionNumber: 1, label: 'B'),
      ],
      questions: <QuizQuestion>[
        QuizQuestion(
          questionName: '1 + 1 = ?',
          questionNumber: 1,
          answers: <QuizAnswer>[
            QuizAnswer(label: 'A', content: '1'),
            QuizAnswer(label: 'B', content: '2'),
          ],
          correctAnswer: 'B',
        ),
      ],
    );
    const summary = GeneratedQuiz(id: quizId, questions: <QuizQuestion>[]);
    QuizCache.seedDetail(detail);
    var loaderCalls = 0;
    final controller = QuizReviewController(
      quizId: quizId,
      initialQuiz: summary,
      loadDetail: (_) async {
        loaderCalls++;
        return detail;
      },
    );
    addTearDown(controller.dispose);

    await controller.loadQuizDetail();

    expect(controller.quiz, same(detail));
    expect(controller.quiz?.questions, isNotEmpty);
    expect(controller.submittedAnswers, <int, String>{1: 'B'});
    expect(controller.isLoading, isFalse);
    expect(loaderCalls, 0);
  });

  test('homework detail cache is isolated by profile and exercise', () async {
    const exerciseId = 981234002;
    const summary = GeneratedQuiz(questions: <QuizQuestion>[]);
    const firstDetail = GeneratedQuiz(
      questions: <QuizQuestion>[
        QuizQuestion(
          questionName: 'Profile one question',
          questionNumber: 1,
          answers: <QuizAnswer>[],
        ),
      ],
    );
    const secondDetail = GeneratedQuiz(
      questions: <QuizQuestion>[
        QuizQuestion(
          questionName: 'Profile two question',
          questionNumber: 1,
          answers: <QuizAnswer>[],
        ),
      ],
    );
    const firstCacheKey = (profileId: 981234011, exerciseId: exerciseId);
    const secondCacheKey = (profileId: 981234012, exerciseId: exerciseId);
    var firstLoaderCalls = 0;
    var secondLoaderCalls = 0;
    final firstController = QuizReviewController(
      quizId: exerciseId,
      cacheKey: firstCacheKey,
      initialQuiz: summary,
      loadDetail: (_) async {
        firstLoaderCalls++;
        return firstDetail;
      },
    );
    addTearDown(firstController.dispose);

    await firstController.loadQuizDetail();

    final secondController = QuizReviewController(
      quizId: exerciseId,
      cacheKey: secondCacheKey,
      initialQuiz: summary,
      loadDetail: (_) async {
        secondLoaderCalls++;
        return secondDetail;
      },
    );
    addTearDown(secondController.dispose);

    await secondController.loadQuizDetail();

    expect(firstController.quiz, same(firstDetail));
    expect(secondController.quiz, same(secondDetail));
    expect(firstLoaderCalls, 1);
    expect(secondLoaderCalls, 1);
  });
}
