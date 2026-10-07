import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:numi/core/helpers/api_date_time.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/controllers/grade_roadmap_state.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/grade_exam_completion.dart';
import 'package:numi/features/exam/models/grade_levels.dart';

/// Owns roadmap loading, session reconciliation and level progression.
/// Navigation, localization and scrolling remain with the screen.
class GradeRoadmapController extends ChangeNotifier {
  GradeRoadmapController({
    required this.profileId,
    required ExamService examService,
    required this.progressStore,
    List<GeneratedExam> initialExams = const [],
    int initialGrade = 0,
    GradeExamCompletion? initialCompletion,
  }) : _examService = examService,
       _exams = List.of(initialExams),
       _selectedGrade = AssessmentFlowPolicy.clampGrade(initialGrade),
       _hasInitialCompletion = initialCompletion != null {
    if (initialCompletion != null) {
      _selectedGrade = AssessmentFlowPolicy.clampGrade(initialCompletion.grade);
      _recordCompletion(initialCompletion);
    }
    _state = _snapshot();
  }

  static const _maxLevel = 10;
  final int profileId;
  final ProfileGradeProgressStore progressStore;
  final ExamService _examService;
  final bool _hasInitialCompletion;
  final List<GeneratedExam> _exams;
  GradeLevels? _gradeLevels;
  int _selectedGrade;
  int _levelRequestId = 0;
  final Map<int, int> _locallyUnlockedLevels = {};
  final Set<int> _gradesWithKnownUnlockBaseline = {};
  final Map<(int, int), ExamStats> _roadmapSessions = {};
  final Map<(int, int), ExamStats> _pendingSessions = {};
  bool _isLoading = true;
  bool _isOpeningExam = false;
  int? _openingLevel;
  String? _errorKey;
  bool _disposed = false;
  late GradeRoadmapState _state;

  GradeRoadmapState get state => _state;

  bool _isCurrent(int requestId) => !_disposed && requestId == _levelRequestId;

  Future<void> initialize() async {
    if (_disposed) return;
    final requestId = ++_levelRequestId;
    final saved = await _readSavedProgress();
    if (!_isCurrent(requestId)) return;
    if ((saved.grade > 0 || saved.level > 0) && !_hasInitialCompletion) {
      _selectedGrade = AssessmentFlowPolicy.clampGrade(saved.grade);
    }
    await _loadGradeLevels(_selectedGrade);
  }

  Future<ProfileGradeProgress> _readSavedProgress() async {
    try {
      return await progressStore.read(profileId);
    } catch (_) {
      return ProfileGradeProgress.initial;
    }
  }

  Future<void> selectGrade(int grade) {
    if (_disposed) return Future<void>.value();
    _selectedGrade = AssessmentFlowPolicy.clampGrade(grade);
    return _loadGradeLevels(_selectedGrade);
  }

  Future<void> reload() => _loadGradeLevels(_selectedGrade);

  Future<void> _loadGradeLevels(int grade) async {
    if (_disposed) return;
    final requestId = ++_levelRequestId;
    _isLoading = true;
    _errorKey = null;
    _gradeLevels = null;
    _notify();
    try {
      final (levels, sessions) = await (
        _examService.getGradeLevels(profileId: profileId, grade: grade),
        _examService.getGradeRoadmap(profileId: profileId, grade: grade),
      ).wait;
      if (!_isCurrent(requestId)) return;
      _gradeLevels = levels;
      _roadmapSessions.removeWhere((key, _) => key.$1 == grade);
      // Roadmap supplies one representative session per level, regardless of is_latest.
      for (final session in sessions) {
        final level = session.level;
        if (session.grade != grade ||
            level == null ||
            level < 1 ||
            level > _maxLevel ||
            (session.userExamId ?? 0) <= 0 ||
            (session.examType != null &&
                session.examType!.trim().toUpperCase() != examTypeGrade)) {
          continue;
        }
        // A passed attempt keeps the next level unlocked, even after a retry.
        if (session.passed == true && isCompletedAssessmentStats(session)) {
          _locallyUnlockedLevels[grade] = math.max(
            _locallyUnlockedLevels[grade] ?? 1,
            (level + 1).clamp(1, _maxLevel),
          );
        }
        final key = (grade, level);
        _roadmapSessions[key] = session;
      }
      _pendingSessions.removeWhere((key, pending) {
        if (key.$1 != grade) return false;
        final latest = _roadmapSessions[key];
        if (latest == null) return false;
        if (latest.userExamId == pending.userExamId) return true;
        return _isNewerServerSession(latest, pending);
      });
      _isLoading = false;
      _notify();
    } catch (_) {
      if (!_isCurrent(requestId)) return;
      _isLoading = false;
      _errorKey = AppKeys.gradeRoadmapLoadFailed;
      _notify();
    }
  }

  bool _isNewerServerSession(ExamStats latest, ExamStats pending) {
    // Compare matching server fields, never the device clock or session IDs.
    for (final (latestDate, pendingDate) in [
      (latest.lastSubmittedDt, pending.lastSubmittedDt),
      (latest.createDt, pending.createDt),
      (latest.endedDt, pending.endedDt),
    ]) {
      if (latestDate != null && pendingDate != null) {
        return latestDate.isAfter(pendingDate);
      }
    }
    return false;
  }

  void _mergeExam(GeneratedExam exam) {
    final index = _exams.indexWhere(
      (existing) =>
          exam.userExamId != null && existing.userExamId == exam.userExamId,
    );
    if (index < 0) {
      _exams.add(exam);
    } else if (!_isActiveExam(_exams[index]) && _isActiveExam(exam)) {
      return;
    } else if (_isActiveExam(_exams[index]) ||
        !_examDate(exam).isBefore(_examDate(_exams[index]))) {
      _exams[index] = exam;
    }
  }

  void _recordCompletion(GradeExamCompletion completion) {
    final grade = completion.grade;
    final level = completion.level;
    final exam = completion.exam;
    final submittedAt =
        tryParseApiDateTime(exam.submittedDt ?? '') ??
        tryParseApiDateTime(exam.modifyDt ?? '');
    // Capture the visible baseline before switching to local outcome tracking.
    final previouslyUnlocked = grade == _selectedGrade && _gradeLevels != null
        ? _currentLevel
        : _locallyUnlockedLevels[grade] ?? level;
    if (grade == _selectedGrade && _gradeLevels != null) {
      _gradesWithKnownUnlockBaseline.add(grade);
    }
    _mergeExam(
      GeneratedExam(
        examId: exam.examId,
        userAiExamId: exam.userAiExamId,
        userExamId: exam.userExamId,
        profileId: profileId,
        examStatus: 'COMPLETE',
        examType: examTypeGrade,
        grade: grade,
        level: level,
        createDt: exam.createDt,
        modifyDt: exam.modifyDt,
        submittedDt:
            submittedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        grading: exam.grading,
        aiTitle: exam.aiTitle,
        aiShortText: exam.aiShortText,
        aiReviewShort: exam.aiReviewShort,
        aiReviewLong: exam.aiReviewLong,
        questions: const <ExamQuestion>[],
      ),
    );
    // Keep the completed attempt visible until roadmap catches up or supersedes it.
    _pendingSessions[(grade, level)] = ExamStats(
      userExamId: exam.userExamId,
      examType: examTypeGrade,
      status: 'COMPLETE',
      grade: grade,
      level: level,
      passed: completion.outcome.passed,
      isLatest: true,
      lastSubmittedDt: submittedAt,
      createDt: tryParseApiDateTime(exam.createDt ?? ''),
      correctNumber: exam.grading?.correctNumber ?? 0,
      scorePercentage: (exam.grading?.scorePercentage ?? 0).toDouble(),
      skippedNumber: exam.grading?.skippedNumber ?? 0,
      totalQuestions: exam.grading?.totalQuestions ?? 0,
    );
    final unlocked = (level + (completion.outcome.passed ? 1 : 0)).clamp(
      0,
      _maxLevel,
    );
    _locallyUnlockedLevels[grade] = math.max(previouslyUnlocked, unlocked);
  }

  ExamStats? _latestSessionFor(int grade, int level) =>
      _pendingSessions[(grade, level)] ?? _roadmapSessions[(grade, level)];

  bool _isActiveExam(GeneratedExam exam) {
    final status = exam.examStatus?.trim().toUpperCase();
    return status == 'ACTIVE' || status == 'IN_PROGRESS';
  }

  bool _isGradeExam(GeneratedExam exam) {
    final examType = exam.examType?.trim().toUpperCase();
    return examType == null || examType == examTypeGrade;
  }

  GeneratedExam? _activeExamFor(int grade, int level) {
    final session = _latestSessionFor(grade, level);
    if (session != null) return activeInProgressAssessmentExam(session);
    GeneratedExam? latest;
    for (final exam in _exams) {
      if (_isGradeExam(exam) &&
          _isActiveExam(exam) &&
          exam.grade == grade &&
          exam.level == level) {
        if (latest == null || _examDate(exam).isAfter(_examDate(latest))) {
          latest = exam;
        }
      }
    }
    return latest;
  }

  GeneratedExam? _completedExamFor(int grade, int level) {
    final session = _latestSessionFor(grade, level);
    if (session != null) {
      return session.passed == true && isCompletedAssessmentStats(session)
          ? completedAssessmentFromStats(
              session,
              profileId: profileId,
              fallbackExamType: examTypeGrade,
            )
          : null;
    }
    GeneratedExam? latest;
    for (final exam in _exams) {
      if (_isGradeExam(exam) &&
          (const {
                'COMPLETE',
                'SUBMITTED',
              }.contains(exam.examStatus?.trim().toUpperCase()) ||
              (exam.examStatus?.trim().isEmpty != false &&
                  exam.grading != null)) &&
          exam.grade == grade &&
          exam.level == level) {
        if (latest == null || _examDate(exam).isAfter(_examDate(latest))) {
          latest = exam;
        }
      }
    }
    return latest;
  }

  DateTime _examDate(GeneratedExam exam) {
    return tryParseApiDateTime(
          exam.modifyDt ?? exam.submittedDt ?? exam.createDt ?? '',
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  int get _currentLevel {
    // Keep the single-step outcome while the server catches up after submission.
    final local = _locallyUnlockedLevels[_selectedGrade];
    final remote = (_gradeLevels?.maxLevel ?? 1).clamp(1, _maxLevel);
    return (_gradesWithKnownUnlockBaseline.contains(_selectedGrade)
            ? local ?? remote
            : math.max(remote, local ?? 0))
        .clamp(1, _maxLevel);
  }

  bool _isLevelUnlocked(int level) {
    return level <= _currentLevel ||
        _completedExamFor(_selectedGrade, level) != null;
  }

  bool _isLevelCompleted(int level) {
    if (level < _currentLevel) return true;
    final session = _latestSessionFor(_selectedGrade, level);
    if (session != null) {
      return isCompletedAssessmentStats(session) && session.passed == true;
    }
    final exam = _completedExamFor(_selectedGrade, level);
    final score = exam?.grading?.scorePercentage;
    return exam != null && score != null && score >= 50;
  }

  GradeRoadmapExamTarget? beginOpeningLevel(int level) {
    if (_disposed ||
        _isOpeningExam ||
        level < 1 ||
        level > _maxLevel ||
        !_isLevelUnlocked(level)) {
      return null;
    }
    final completed = _completedExamFor(_selectedGrade, level);
    final canReview =
        completed != null &&
        (completed.userExamId != null ||
            completed.examId != null ||
            completed.userAiExamId != null);
    final target = GradeRoadmapExamTarget(
      destination: canReview
          ? GradeRoadmapExamDestination.review
          : GradeRoadmapExamDestination.attempt,
      grade: _selectedGrade,
      level: level,
      exam: canReview ? completed : _activeExamFor(_selectedGrade, level),
    );
    _isOpeningExam = true;
    _openingLevel = canReview ? null : level;
    _notify();
    return target;
  }

  void finishOpeningExam() {
    if (_disposed) return;
    _isOpeningExam = false;
    _openingLevel = null;
    _notify();
  }

  void recordCompletion(GradeExamCompletion completion) {
    if (_disposed) return;
    _recordCompletion(completion);
    _notify();
  }

  void discardActiveExam(GeneratedExam exam) {
    if (_disposed || !_exams.remove(exam)) return;
    _notify();
  }

  GradeRoadmapState _snapshot() => GradeRoadmapState(
    selectedGrade: _selectedGrade,
    currentLevel: _currentLevel,
    gradeLevels: _gradeLevels,
    isLoading: _isLoading,
    errorKey: _errorKey,
    isOpeningExam: _isOpeningExam,
    openingLevel: _openingLevel,
    levels: [
      for (var level = 1; level <= _maxLevel; level++)
        GradeRoadmapLevelState(
          level: level,
          isUnlocked: _isLevelUnlocked(level),
          isCompleted: _isLevelCompleted(level),
          activeExam: _activeExamFor(_selectedGrade, level),
          completedExam: _completedExamFor(_selectedGrade, level),
        ),
    ],
  );

  void _notify() {
    if (_disposed) return;
    _state = _snapshot();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _levelRequestId++;
    super.dispose();
  }
}
