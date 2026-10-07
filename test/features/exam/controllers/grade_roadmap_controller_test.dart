import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/controllers/grade_roadmap_controller.dart';
import 'package:numi/features/exam/controllers/grade_roadmap_state.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/helpers/grade_exam_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/grade_exam_completion.dart';
import 'package:numi/features/exam/models/grade_levels.dart';

void main() {
  GradeRoadmapController build({
    _Exams? service,
    _Progress? progress,
    int initialGrade = 2,
    GradeExamCompletion? completion,
    List<GeneratedExam> initialExams = const [],
  }) {
    final controller = GradeRoadmapController(
      profileId: 11,
      examService: service ?? _Exams(),
      progressStore: progress ?? _Progress(),
      initialGrade: initialGrade,
      initialCompletion: completion,
      initialExams: initialExams,
    );
    addTearDown(controller.dispose);
    return controller;
  }

  test(
    'restores selected grade and exposes immutable state snapshots',
    () async {
      final service = _Exams()
        ..levels[4] = const GradeLevels(latestLevel: 1, maxLevel: 3);
      final controller = build(
        service: service,
        progress: _Progress(
          Future.value(const ProfileGradeProgress(grade: 4, level: 2)),
        ),
      );
      final initial = controller.state;
      await controller.initialize();
      expect(service.levelRequests, [(11, 4)]);
      expect(service.roadmapRequests, [(11, 4)]);
      expect(controller.state.selectedGrade, 4);
      expect(controller.state.currentLevel, 3);
      expect(controller.state.levels, hasLength(10));
      expect(controller.state.level(1).isCompleted, isTrue);
      expect(controller.state.level(4).isUnlocked, isFalse);
      expect(() => controller.state.levels.clear(), throwsUnsupportedError);
      expect(initial.selectedGrade, 2);
      expect(initial.isLoading, isTrue);
      expect(initial.level(1).isCompleted, isFalse);
    },
  );

  test('initial completion takes precedence over saved progress', () async {
    final controller = build(
      progress: _Progress(
        Future.value(const ProfileGradeProgress(grade: 4, level: 8)),
      ),
      completion: _completion(grade: 3, level: 2),
    );
    await controller.initialize();
    expect(controller.state.selectedGrade, 3);
    expect(controller.state.currentLevel, 3);
    expect(controller.state.level(2).completedExam?.userExamId, 8011);
  });

  test('storage failure falls back to the initial grade', () async {
    final controller = build(
      progress: _Progress(Future.error(StateError('storage'))),
    );
    await controller.initialize();
    expect(controller.state.selectedGrade, 2);
    expect(controller.state.errorKey, isNull);
    expect(controller.state.isLoading, isFalse);
  });

  test(
    'levels and history start together and loading waits for both',
    () async {
      final levels = Completer<GradeLevels>();
      final history = Completer<List<ExamStats>>();
      final service = _Exams()
        ..pendingLevels[2] = levels.future
        ..pendingRoadmaps[2] = history.future;
      final controller = build(service: service);
      final pending = controller.reload();
      expect(service.levelRequests, [(11, 2)]);
      expect(service.roadmapRequests, [(11, 2)]);
      levels.complete(const GradeLevels(latestLevel: 1, maxLevel: 3));
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.isLoading, isTrue);
      expect(controller.state.gradeLevels, isNull);
      history.complete([]);
      await pending;
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.currentLevel, 3);
    },
  );

  test(
    'a failed endpoint leaves the roadmap unavailable until retry',
    () async {
      final service = _Exams()..failRoadmap = true;
      final controller = build(service: service);
      await controller.initialize();
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.gradeLevels, isNull);
      expect(controller.state.errorKey, AppKeys.gradeRoadmapLoadFailed);
      service.failRoadmap = false;
      await controller.reload();
      expect(controller.state.gradeLevels, isNotNull);
      expect(controller.state.errorKey, isNull);
    },
  );

  for (final fails in [false, true]) {
    test(
      'late grade response cannot replace a newer selection (failure: $fails)',
      () async {
        final levels = Completer<GradeLevels>();
        final history = Completer<List<ExamStats>>();
        final service = _Exams()
          ..pendingLevels[2] = levels.future
          ..pendingRoadmaps[2] = history.future
          ..levels[4] = const GradeLevels(latestLevel: 1, maxLevel: 5);
        final controller = build(service: service);
        final pending = controller.reload();
        await controller.selectGrade(4);
        final current = controller.state;
        if (fails) {
          levels.completeError(StateError('old request'));
        } else {
          levels.complete(const GradeLevels(latestLevel: 10, maxLevel: 10));
        }
        history.complete([_session(id: 8000, level: 10)]);
        await pending;
        expect(controller.state, same(current));
        expect(controller.state.selectedGrade, 4);
        expect(controller.state.currentLevel, 5);
        expect(controller.state.errorKey, isNull);
      },
    );
  }

  test(
    'late saved progress does not undo an explicit grade selection',
    () async {
      final saved = Completer<ProfileGradeProgress>();
      final service = _Exams();
      final controller = build(
        service: service,
        progress: _Progress(saved.future),
      );
      final pending = controller.initialize();
      await controller.selectGrade(4);
      saved.complete(const ProfileGradeProgress(grade: 2, level: 8));
      await pending;
      expect(controller.state.selectedGrade, 4);
      expect(service.levelRequests, [(11, 4)]);
    },
  );

  test(
    'dispose during progress restore prevents further API requests',
    () async {
      final saved = Completer<ProfileGradeProgress>();
      final service = _Exams();
      final controller = GradeRoadmapController(
        profileId: 11,
        examService: service,
        progressStore: _Progress(saved.future),
      );
      final pending = controller.initialize();
      final initial = controller.state;
      controller.dispose();
      saved.complete(const ProfileGradeProgress(grade: 4, level: 8));
      await pending;
      expect(controller.state, same(initial));
      expect(service.levelRequests, isEmpty);
      expect(service.roadmapRequests, isEmpty);
    },
  );

  test(
    'dispose during load ignores late results and subsequent actions',
    () async {
      final levels = Completer<GradeLevels>();
      final service = _Exams()..pendingLevels[2] = levels.future;
      final controller = GradeRoadmapController(
        profileId: 11,
        initialGrade: 2,
        examService: service,
        progressStore: _Progress(),
      );
      final pending = controller.reload();
      final loading = controller.state;
      controller.dispose();
      levels.complete(const GradeLevels(latestLevel: 1, maxLevel: 10));
      await pending;
      await controller.selectGrade(4);
      await controller.reload();
      controller.recordCompletion(_completion());
      controller.finishOpeningExam();
      expect(controller.beginOpeningLevel(1), isNull);
      expect(controller.state, same(loading));
      expect(service.levelRequests, [(11, 2)]);
    },
  );

  test(
    'local pass unlocks exactly one level while server catches up',
    () async {
      final service = _Exams();
      final controller = build(service: service);
      await controller.initialize();
      final before = controller.state;
      controller.recordCompletion(_completion());
      service.levels[2] = const GradeLevels(latestLevel: 1, maxLevel: 10);
      await controller.reload();
      expect(controller.state.currentLevel, 2);
      expect(controller.state.level(1).isCompleted, isTrue);
      expect(controller.state.level(3).isUnlocked, isFalse);
      expect(before.currentLevel, 1);
      expect(before.level(1).isCompleted, isFalse);
    },
  );

  test(
    'failed retry keeps a previous unlock and a level 10 pass stays capped',
    () async {
      final controller = build(completion: _completion(level: 10));
      await controller.initialize();
      expect(controller.state.currentLevel, 10);
      controller.recordCompletion(_completion(level: 10, passed: false));
      await controller.reload();
      expect(controller.state.currentLevel, 10);
      expect(controller.state.level(10).isCompleted, isFalse);
    },
  );

  for (final matches in [false, true]) {
    test(
      'pending review survives old history until server catches up (matching ID: $matches)',
      () async {
        final service = _Exams();
        final controller = build(service: service);
        await controller.initialize();
        controller.recordCompletion(
          _completion(submittedDt: '2026-10-01T00:00:00Z'),
        );
        service.sessions = [_session(id: 9000, passed: false)];
        await controller.reload();
        expect(controller.state.level(1).completedExam?.userExamId, 8011);
        if (matches) {
          service.sessions = [_session(id: 8011)];
          await controller.reload();
          // Matching ID acknowledges the local outcome even without a timestamp.
          service.sessions = [_session(id: 9001, passed: false)];
        } else {
          service.sessions = [
            _session(
              id: 9001,
              passed: false,
              submittedAt: DateTime.utc(2026, 10, 2),
            ),
          ];
        }
        await controller.reload();
        expect(controller.state.level(1).completedExam, isNull);
        expect(controller.state.currentLevel, 2);
      },
    );
  }

  test(
    'history filters invalid entries and preserves a pass across retries',
    () async {
      final service = _Exams()
        ..sessions = [
          _session(id: 100, level: 4),
          _session(id: 101, level: 4, passed: false),
          _session(id: 102, grade: 3, level: 9),
          _session(id: 103, level: 9, status: 'ACTIVE'),
          _session(id: 104, level: 9, examType: examTypePractice),
          _session(id: 105, level: 0),
          _session(id: 106, level: 11),
          _session(id: 0, level: 10),
        ];
      final controller = build(service: service);
      await controller.initialize();
      expect(controller.state.currentLevel, 5);
      expect(controller.state.level(4).completedExam, isNull);
      expect(controller.state.level(9).completedExam, isNull);
    },
  );

  test(
    'opening resolves review, resume or new attempt and blocks double taps',
    () async {
      const active = GeneratedExam(
        userExamId: 101,
        examStatus: 'ACTIVE',
        examType: examTypeGrade,
        grade: 2,
        level: 2,
        questions: [],
      );
      final exams = [active];
      final service = _Exams()
        ..levels[2] = const GradeLevels(latestLevel: 1, maxLevel: 3)
        ..sessions = [_session(id: 100, level: 1)];
      final controller = build(service: service, initialExams: exams);
      exams.clear();
      await controller.initialize();
      final review = controller.beginOpeningLevel(1)!;
      expect(review.destination, GradeRoadmapExamDestination.review);
      expect(review.exam?.userExamId, 100);
      expect(controller.state.openingLevel, isNull);
      expect(controller.beginOpeningLevel(2), isNull);
      controller.finishOpeningExam();
      final resume = controller.beginOpeningLevel(2)!;
      expect(resume.destination, GradeRoadmapExamDestination.attempt);
      expect(resume.exam, same(active));
      expect(controller.state.openingLevel, 2);
      controller.finishOpeningExam();
      controller.discardActiveExam(active);
      expect(controller.state.level(2).activeExam, isNull);
      final fresh = controller.beginOpeningLevel(3)!;
      expect(fresh.exam, isNull);
      await controller.selectGrade(4);
      expect(fresh.grade, 2);
      expect(fresh.level, 3);
      controller.finishOpeningExam();
      expect(controller.state.isOpeningExam, isFalse);
      expect(controller.state.openingLevel, isNull);
      expect(controller.beginOpeningLevel(0), isNull);
      expect(controller.beginOpeningLevel(11), isNull);
      expect(controller.beginOpeningLevel(10), isNull);
    },
  );
}

GradeExamCompletion _completion({
  int grade = 2,
  int level = 1,
  bool passed = true,
  String? submittedDt,
}) => GradeExamCompletion(
  grade: grade,
  level: level,
  exam: GeneratedExam(
    userExamId: 8011,
    submittedDt: submittedDt,
    grading: ExamGrading(scorePercentage: passed ? 90 : 10),
    questions: [],
  ),
  outcome: GradeExamOutcome(
    progress: ProfileGradeProgress(
      grade: grade,
      level: (level + (passed ? 1 : 0)).clamp(1, 10),
    ),
    passed: passed,
    levelIncrease: passed ? 1 : 0,
  ),
);

ExamStats _session({
  required int id,
  int grade = 2,
  int level = 1,
  bool passed = true,
  String status = 'COMPLETE',
  String examType = examTypeGrade,
  DateTime? submittedAt,
}) => ExamStats(
  userExamId: id,
  grade: grade,
  level: level,
  passed: passed,
  status: status,
  examType: examType,
  lastSubmittedDt: submittedAt,
  isLatest: false,
  correctNumber: passed ? 9 : 1,
  skippedNumber: 0,
  totalQuestions: 10,
  scorePercentage: passed ? 90 : 10,
);

class _Exams implements ExamService {
  final levels = <int, GradeLevels>{};
  final pendingLevels = <int, Future<GradeLevels>>{};
  final pendingRoadmaps = <int, Future<List<ExamStats>>>{};
  final levelRequests = <(int, int)>[];
  final roadmapRequests = <(int, int)>[];
  List<ExamStats> sessions = [];
  bool failRoadmap = false;

  @override
  Future<GradeLevels> getGradeLevels({
    required int profileId,
    required int grade,
  }) {
    levelRequests.add((profileId, grade));
    return pendingLevels[grade] ??
        Future.value(
          levels[grade] ?? const GradeLevels(latestLevel: 1, maxLevel: 1),
        );
  }

  @override
  Future<List<ExamStats>> getGradeRoadmap({
    required int profileId,
    required int grade,
  }) {
    roadmapRequests.add((profileId, grade));
    if (failRoadmap) return Future.error(StateError('history'));
    return pendingRoadmaps[grade] ?? Future.value(sessions);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Progress implements ProfileGradeProgressStore {
  _Progress([Future<ProfileGradeProgress>? result])
    : result = result ?? Future.value(ProfileGradeProgress.initial);
  final Future<ProfileGradeProgress> result;

  @override
  Future<ProfileGradeProgress> read(int profileId) => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
