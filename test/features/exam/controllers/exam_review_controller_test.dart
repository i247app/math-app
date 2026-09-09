import 'package:flutter_test/flutter_test.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/controllers/exam_review_controller.dart';
import 'package:numi/features/exam/data/exam_cache.dart';

void main() {
  test('fresh cached detail replaces a question-less list summary', () async {
    const examId = 981234001;
    const detail = GeneratedExam(
      id: examId,
      answers: <SubmitExamAnswer>[
        SubmitExamAnswer(questionNumber: 1, label: 'B'),
      ],
      questions: <ExamQuestion>[
        ExamQuestion(
          questionName: '1 + 1 = ?',
          questionNumber: 1,
          answers: <ExamAnswer>[
            ExamAnswer(label: 'A', content: '1'),
            ExamAnswer(label: 'B', content: '2'),
          ],
          correctAnswer: 'B',
        ),
      ],
    );
    const summary = GeneratedExam(id: examId, questions: <ExamQuestion>[]);
    ExamCache.seedDetail(detail);
    var loaderCalls = 0;
    final controller = ExamReviewController(
      examId: examId,
      initialExam: summary,
      loadDetail: (_) async {
        loaderCalls++;
        return detail;
      },
    );
    addTearDown(controller.dispose);

    await controller.loadExamDetail();

    expect(controller.exam, same(detail));
    expect(controller.exam?.questions, isNotEmpty);
    expect(controller.submittedAnswers, <int, String>{1: 'B'});
    expect(controller.isLoading, isFalse);
    expect(loaderCalls, 0);
  });

  test('homework detail cache is isolated by profile and exercise', () async {
    const exerciseId = 981234002;
    const summary = GeneratedExam(questions: <ExamQuestion>[]);
    const firstDetail = GeneratedExam(
      questions: <ExamQuestion>[
        ExamQuestion(
          questionName: 'Profile one question',
          questionNumber: 1,
          answers: <ExamAnswer>[],
        ),
      ],
    );
    const secondDetail = GeneratedExam(
      questions: <ExamQuestion>[
        ExamQuestion(
          questionName: 'Profile two question',
          questionNumber: 1,
          answers: <ExamAnswer>[],
        ),
      ],
    );
    const firstCacheKey = (profileId: 981234011, exerciseId: exerciseId);
    const secondCacheKey = (profileId: 981234012, exerciseId: exerciseId);
    var firstLoaderCalls = 0;
    var secondLoaderCalls = 0;
    final firstController = ExamReviewController(
      examId: exerciseId,
      cacheKey: firstCacheKey,
      initialExam: summary,
      loadDetail: (_) async {
        firstLoaderCalls++;
        return firstDetail;
      },
    );
    addTearDown(firstController.dispose);

    await firstController.loadExamDetail();

    final secondController = ExamReviewController(
      examId: exerciseId,
      cacheKey: secondCacheKey,
      initialExam: summary,
      loadDetail: (_) async {
        secondLoaderCalls++;
        return secondDetail;
      },
    );
    addTearDown(secondController.dispose);

    await secondController.loadExamDetail();

    expect(firstController.exam, same(firstDetail));
    expect(secondController.exam, same(secondDetail));
    expect(firstLoaderCalls, 1);
    expect(secondLoaderCalls, 1);
  });
}
