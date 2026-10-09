import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/controllers/placement_result_controller.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/placement_result_config.dart';

void main() {
  setUp(() {
    SessionCacheScope.reset();
    ExamCache.clear();
  });
  tearDown(() {
    SessionCacheScope.reset();
    ExamCache.clear();
  });

  PlacementResultController createController(
    _ExamService service, {
    String examType = examTypeAssessment,
    int? profileId = 9,
    int grade = 2,
    int? level,
  }) {
    final controller = PlacementResultController(
      examService: service,
      grade: grade,
      level: level,
      correctAnswers: 4,
      totalQuestions: 5,
      examType: examType,
      profileId: profileId,
      userExamId: 101,
      previousGrade: 3,
    );
    addTearDown(controller.dispose);
    return controller;
  }

  test(
    'loads a single seven-day history request and applies the current result',
    () async {
      final service = _ExamService();
      final controller = createController(service);
      final loading = controller.initialize();
      await controller.initialize();
      expect(controller.state.progressResolved, isFalse);
      expect(service.progressCalls, 1);
      expect(service.progressProfileId, 9);
      expect(
        service.toDt!.difference(service.fromDt!),
        const Duration(days: 7),
      );
      service.progress.complete(
        ExamProgressResponse(mstatus: 200, series: [_point(101, 4)]),
      );
      await loading;
      expect(controller.state.progressResolved, isTrue);
      expect(controller.state.grade, 4);
      expect(controller.state.chart.previousGrades, isEmpty);
      expect(controller.config.generationAction, isNull);
      expect(await controller.generateNextExam(), isNull);
      expect(service.generationCalls, 0);
    },
  );

  test(
    'progress failure resolves loading and keeps local grade/history',
    () async {
      final service = _ExamService();
      final controller = createController(service);
      final loading = controller.initialize();
      service.progress.completeError(const ExamException('Unavailable'));
      await loading;
      expect(controller.state.progressResolved, isTrue);
      expect(controller.state.grade, 2);
      expect(controller.state.chart.previousGrades, [3]);
      expect(controller.state.chart.testNumbers, [1, 2]);
    },
  );

  test(
    'Grade mode skips progress, clamps generation and rejects duplicate taps',
    () async {
      final service = _ExamService();
      final controller = createController(
        service,
        examType: ' grade ',
        grade: 99,
        level: 99,
      );
      await controller.initialize();
      expect(service.progressCalls, 0);
      expect(controller.state.progressResolved, isTrue);
      expect(controller.config.ribbon, PlacementResultRibbon.gradeLevel);
      expect(
        controller.config.generationAction?.labelKey,
        AppKeys.placementResultNext,
      );
      final generating = controller.generateNextExam();
      expect(controller.state.isGenerating, isTrue);
      expect(await controller.generateNextExam(), isNull);
      expect(service.generationCalls, 1);
      expect(service.generationExamType, examTypeGrade);
      expect(service.gradeLabel, 'Lớp 5');
      expect(service.level, 10);
      expect(service.generationProfileId, 9);
      expect(service.generationUserExamId, isNull);
      service.generated.complete(
        const GeneratedExam(examId: 401, questions: []),
      );
      expect((await generating)?.examId, 401);
      expect(ExamCache.peekDetail(401)?.examId, 401);
      // The screen keeps its loader until navigation consumes the generated exam.
      expect(controller.state.isGenerating, isTrue);
    },
  );

  test('generation failure returns to the result and allows retry', () async {
    final service = _ExamService();
    final controller = createController(service, examType: examTypeGrade);
    final generating = controller.generateNextExam();
    final failure = expectLater(generating, throwsA(isA<ExamException>()));
    service.generated.completeError(const ExamException('Try later'));
    await failure;
    expect(controller.state.isGenerating, isFalse);
    service.generated = Completer<GeneratedExam>();
    final retry = controller.generateNextExam();
    expect(service.generationCalls, 2);
    service.generated.complete(const GeneratedExam(examId: 402, questions: []));
    expect((await retry)?.examId, 402);
  });

  test(
    'results without a profile resolve immediately and normalize scores',
    () async {
      final service = _ExamService();
      final controller = PlacementResultController(
        examService: service,
        grade: -1,
        correctAnswers: 10,
        totalQuestions: -1,
        previousGrade: 3,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(service.progressCalls, 0);
      expect(controller.state.progressResolved, isTrue);
      expect(controller.state.grade, 0);
      expect(controller.correctAnswers, 0);
      expect(controller.totalQuestions, 0);
      expect(controller.state.chart.previousGrades, [3]);
      final unknown = PlacementResultConfig.forExamType('PRACTICE');
      expect(unknown.showsAssessmentChart, isFalse);
      expect(unknown.generationAction, isNull);
    },
  );

  for (final endSession in [false, true]) {
    test(
      'ignores progress after ${endSession ? 'session reset' : 'disposal'}',
      () async {
        final service = _ExamService();
        final controller = PlacementResultController(
          examService: service,
          grade: 2,
          correctAnswers: 4,
          totalQuestions: 5,
          profileId: 9,
        );
        var updates = 0;
        controller.addListener(() => updates++);
        final loading = controller.initialize();
        if (endSession) {
          SessionCacheScope.reset();
          addTearDown(controller.dispose);
        } else {
          controller.dispose();
        }
        service.progress.complete(
          ExamProgressResponse(mstatus: 200, series: [_point(101, 5)]),
        );
        await loading;
        expect(updates, 0);
        expect(controller.state.grade, 2);
      },
    );

    test(
      'ignores generation after ${endSession ? 'session reset' : 'disposal'}',
      () async {
        final service = _ExamService();
        final controller = PlacementResultController(
          examService: service,
          grade: 2,
          correctAnswers: 4,
          totalQuestions: 5,
          examType: examTypeGrade,
        );
        var updates = 0;
        controller.addListener(() => updates++);
        final generating = controller.generateNextExam();
        if (endSession) {
          SessionCacheScope.reset();
          addTearDown(controller.dispose);
        } else {
          controller.dispose();
        }
        service.generated.complete(
          const GeneratedExam(examId: 401, questions: []),
        );
        expect(await generating, isNull);
        expect(ExamCache.peekDetail(401), isNull);
        expect(
          updates,
          1,
        ); // Only the initial loading notification is delivered.
      },
    );
  }
}

class _ExamService implements ExamService {
  final progress = Completer<ExamProgressResponse>();
  var generated = Completer<GeneratedExam>();
  int progressCalls = 0;
  int generationCalls = 0;
  int? progressProfileId;
  DateTime? fromDt;
  DateTime? toDt;
  String? generationExamType;
  String? gradeLabel;
  int? level;
  int? generationProfileId;
  int? generationUserExamId;

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
    String examType = examTypeAssessment,
  }) {
    progressCalls++;
    progressProfileId = profileId;
    this.fromDt = fromDt;
    this.toDt = toDt;
    return progress.future;
  }

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) {
    generationCalls++;
    generationExamType = examType;
    this.gradeLabel = gradeLabel;
    this.level = level;
    generationProfileId = profileId;
    generationUserExamId = userExamId;
    return generated.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ExamProgressPoint _point(int id, int grade) => ExamProgressPoint(
  completedDt: DateTime.utc(2026, 1, 1),
  correctNumber: 5,
  examId: id,
  score: 10,
  scorePct: 100,
  sequence: 1,
  totalQuestions: 5,
  grade: grade,
  status: 'COMPLETE',
);
