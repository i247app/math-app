import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/features/exam/controllers/exam_attempt_controller.dart';
import 'package:numi/features/exam/data/exam_attempt_requests.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';

const _correct = ExamAnswer(label: 'A', content: '2');
final _source = GeneratedExam(
  examId: 301,
  profileId: 7,
  examType: examTypeAssessment,
  grade: 0,
  questions: List.generate(
    10,
    (index) => ExamQuestion(
      questionNumber: index + 1,
      questionName: 'Q',
      answers: const [
        _correct,
        ExamAnswer(label: 'B', content: '3'),
      ],
      rightAnswer: 'A',
    ),
  ),
);
const _submitted = GeneratedExam(
  examId: 301,
  userExamId: 900,
  examType: examTypeAssessment,
  questions: [],
);
const _next = GeneratedExam(examId: 302, grade: 2, questions: []);

void main() {
  setUp(ExamCache.clear);
  tearDown(ExamCache.clear);

  ExamAttemptController attempt(_Service service) {
    final controller = ExamAttemptController(
      examService: service,
      initialExam: _source,
    );
    addTearDown(controller.dispose);
    _answerSix(controller);
    return controller;
  }

  test(
    'failed submission blocks generation and retry submits before generating',
    () async {
      final service = _Service();
      final controller = attempt(service);
      final first = controller.advanceAssessmentFlow();
      service.submissions[0].completeError(
        const ExamException('submit failed'),
      );
      expect(await first, AssessmentFlowAction.continueSet);
      expect(service.generations, isEmpty);
      expect(controller.errorMessage, 'submit failed');
      expect(controller.errorRetryAction, ExamAttemptRetryAction.generate);
      expect(controller.completedSets, isEmpty);
      final retry = controller.retryGeneration();
      service.submissions[1].complete(_submitted);
      await Future<void>.delayed(Duration.zero);
      expect(service.events, ['submit', 'submit', 'generate']);
      expect(service.gradeLabels, ['Lớp 2']);
      service.generations[0].complete(_next);
      expect(await retry, isTrue);
      expect(controller.completedSets, hasLength(1));
      expect(controller.questionNumberOffset, 6);
      expect(controller.userExamId, 900);
      expect(controller.errorMessage, isNull);
    },
  );

  test(
    'generation retry reuses a successful submission without recording the set twice',
    () async {
      final service = _Service();
      final controller = attempt(service);
      final first = controller.advanceAssessmentFlow();
      service.submissions[0].complete(_submitted);
      await Future<void>.delayed(Duration.zero);
      service.generations[0].completeError(StateError('network failed'));
      await first;
      expect(controller.completedSets, isEmpty);
      expect(controller.questionNumberOffset, 0);
      expect(controller.selectedAnswerLabels, hasLength(6));
      expect(controller.errorRetryAction, ExamAttemptRetryAction.generate);
      final retry = controller.retryGeneration();
      final duplicate = controller.retryGeneration();
      expect(await duplicate, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(service.events, ['submit', 'generate', 'generate']);
      service.generations[1].complete(_next);
      expect(await retry, isTrue);
      expect(controller.completedSets, hasLength(1));
      expect(controller.totalAnsweredQuestionCount, 6);
      expect(controller.selectedAnswerLabels, isEmpty);
      expect(controller.questionNumberOffset, 6);
      expect(controller.setNumber, 2);
    },
  );

  test(
    'final submit failure retries submit and ignores duplicate taps',
    () async {
      final service = _Service();
      final controller = ExamAttemptController(
        examService: service,
        examType: examTypeGrade,
        initialExam: _source,
      );
      addTearDown(controller.dispose);
      for (var index = 0; index < 10; index++) {
        controller.selectAnswer(_correct);
        if (index < 9) controller.goToNextQuestion();
      }
      final first = controller.submitCurrentExam();
      expect(
        (await controller.submitCurrentExam()).status,
        ExamAttemptSubmitStatus.ignored,
      );
      service.submissions[0].completeError(StateError('offline'));
      expect((await first).status, ExamAttemptSubmitStatus.failed);
      expect(controller.errorRetryAction, ExamAttemptRetryAction.submit);
      expect(controller.isSubmittingExam, isFalse);
      final retry = controller.submitCurrentExam();
      service.submissions[1].complete(_submitted);
      expect((await retry).status, ExamAttemptSubmitStatus.submitted);
      expect(controller.errorMessage, isNull);
      expect(service.generations, isEmpty);
    },
  );

  test(
    'request layer shares concurrent submissions and reuses the successful result',
    () async {
      final service = _Service();
      final requests = ExamAttemptRequests(
        service: service,
        examType: examTypeAssessment,
      );
      addTearDown(requests.dispose);
      final a = requests.submit(
        _source,
        const [],
        kind: ExamAttemptKind.assessment,
      );
      final b = requests.submit(
        _source,
        const [],
        kind: ExamAttemptKind.assessment,
      );
      expect(service.submissions, hasLength(1));
      service.submissions[0].complete(_submitted);
      expect((await a).exam, same(_submitted));
      expect((await b).exam, same(_submitted));
      expect(
        (await requests.submit(
          _source,
          const [],
          kind: ExamAttemptKind.assessment,
        )).exam,
        same(_submitted),
      );
      expect(service.submissions, hasLength(1));
    },
  );

  for (final fail in [false, true]) {
    test(
      'disposed generation ignores late ${fail ? 'error' : 'success'} without notifying or caching',
      () async {
        final service = _Service();
        final controller = ExamAttemptController(examService: service);
        int notifications = 0;
        controller.addListener(() => notifications++);
        final generation = controller.generateExam();
        final before = notifications;
        controller.dispose();
        if (fail) {
          service.generations[0].completeError(StateError('offline'));
        } else {
          service.generations[0].complete(_next);
        }
        expect(await generation, isFalse);
        expect(notifications, before);
        expect(ExamCache.peekDetail(302), isNull);
      },
    );

    test(
      'disposed transition ignores late generation ${fail ? 'error' : 'success'}',
      () async {
        final service = _Service();
        final controller = ExamAttemptController(
          examService: service,
          initialExam: _source,
        );
        _answerSix(controller);
        final transition = controller.advanceAssessmentFlow();
        service.submissions[0].complete(_submitted);
        await Future<void>.delayed(Duration.zero);
        controller.dispose();
        if (fail) {
          service.generations[0].completeError(StateError('offline'));
        } else {
          service.generations[0].complete(_next);
        }
        expect(await transition, AssessmentFlowAction.continueSet);
        expect(controller.completedSets, isEmpty);
        expect(ExamCache.peekDetail(302), isNull);
      },
    );

    test(
      'disposed final submit ignores late ${fail ? 'error' : 'success'}',
      () async {
        final service = _Service();
        final controller = ExamAttemptController(
          examService: service,
          initialExam: const GeneratedExam(
            examId: 301,
            questions: [
              ExamQuestion(
                questionNumber: 1,
                questionName: 'Q',
                answers: [_correct],
                rightAnswer: 'A',
              ),
            ],
          ),
        );
        controller.selectAnswer(_correct);
        final submit = controller.submitCurrentExam();
        controller.dispose();
        if (fail) {
          service.submissions[0].completeError(StateError('offline'));
        } else {
          service.submissions[0].complete(_submitted);
        }
        expect((await submit).status, ExamAttemptSubmitStatus.ignored);
        expect(ExamCache.peekDetail(301), isNull);
      },
    );
  }

  test(
    'ending a session during a transition prevents next-set generation',
    () async {
      final service = _Service();
      final controller = attempt(service);
      final transition = controller.advanceAssessmentFlow();
      SessionCacheScope.reset();
      service.submissions[0].complete(_submitted);
      expect(await transition, AssessmentFlowAction.continueSet);
      expect(service.generations, isEmpty);
      expect(ExamCache.peekDetail(301), isNull);
      expect(controller.completedSets, isEmpty);
    },
  );

  test(
    'starting a new attempt detaches a pending submit and its cache update',
    () async {
      final service = _Service();
      final controller = ExamAttemptController(
        examService: service,
        initialExam: const GeneratedExam(
          examId: 301,
          questions: [
            ExamQuestion(
              questionNumber: 1,
              questionName: 'Q',
              answers: [_correct],
              rightAnswer: 'A',
            ),
          ],
        ),
      );
      addTearDown(controller.dispose);
      controller.selectAnswer(_correct);
      final oldSubmit = controller.submitCurrentExam();
      final fresh = controller.generateExam();
      service.generations[0].complete(_next);
      expect(await fresh, isTrue);
      service.submissions[0].complete(_submitted);
      expect((await oldSubmit).status, ExamAttemptSubmitStatus.ignored);
      expect(controller.exam, same(_next));
      expect(controller.errorMessage, isNull);
      expect(ExamCache.peekDetail(301), isNull);
      expect(ExamCache.peekDetail(302), same(_next));
    },
  );
}

void _answerSix(ExamAttemptController controller) {
  for (var index = 0; index < 6; index++) {
    controller.selectAnswer(_correct);
    if (index < 5) controller.goToNextQuestion();
  }
}

class _Service implements ExamService {
  final submissions = <Completer<GeneratedExam>>[];
  final generations = <Completer<GeneratedExam>>[];
  final events = <String>[];
  final gradeLabels = <String?>[];
  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) {
    events.add('submit');
    final result = Completer<GeneratedExam>();
    submissions.add(result);
    return result.future;
  }

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) {
    events.add('generate');
    gradeLabels.add(gradeLabel);
    final result = Completer<GeneratedExam>();
    generations.add(result);
    return result.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
