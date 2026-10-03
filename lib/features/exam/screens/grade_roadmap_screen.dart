import 'dart:async';
import 'dart:math' as math;

import 'package:numi/core/helpers/api_date_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/grade_roadmap_layout.dart';
import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/grade_levels.dart';
import 'package:numi/features/exam/models/grade_exam_completion.dart';
import 'package:numi/features/exam/screens/exam_attempt_screen.dart';
import 'package:numi/features/exam/screens/exam_review_screen.dart';
import 'package:numi/features/exam/screens/grade_selection_screen.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/models/grade.dart';

class GradeRoadmapScreen extends StatefulWidget {
  const GradeRoadmapScreen({
    super.key,
    required this.profileId,
    required this.examService,
    this.user,
    this.initialGrades = const <GradeModel>[],
    this.gradeService,
    this.initialExams = const <GeneratedExam>[],
    this.initialGrade = 0,
    this.initialCompletion,
    this.gradeProgressStore,
    this.showCloseButton = true,
    this.bottomPadding = 0,
  });

  final int profileId;
  final ExamService examService;
  final LoginUser? user;
  final List<GradeModel> initialGrades;
  final GradeService? gradeService;
  final List<GeneratedExam> initialExams;
  final int initialGrade;
  final GradeExamCompletion? initialCompletion;
  final ProfileGradeProgressStore? gradeProgressStore;
  final bool showCloseButton;
  final double bottomPadding;

  @override
  State<GradeRoadmapScreen> createState() => _GradeRoadmapScreenState();
}

class _GradeRoadmapScreenState extends State<GradeRoadmapScreen> {
  static const _mascotAsset = 'assets/images/grade-roadmap-mascot.png';
  static const _maxLevel = 10;

  late final ProfileGradeProgressStore _progressStore;
  late List<GeneratedExam> _exams;
  GradeLevels? _gradeLevels;
  late int _selectedGrade;
  int _levelRequestId = 0;
  final Map<int, int> _locallyUnlockedLevels = <int, int>{};
  final Set<int> _gradesWithKnownUnlockBaseline = <int>{};
  final Map<(int, int), ExamStats> _roadmapSessions = {};
  final Map<(int, int), ExamStats> _pendingSessions = {};
  bool _isLoading = true;
  bool _isOpeningExam = false;
  int? _openingLevel;
  bool _isOpeningGradeSelection = false;
  String? _errorMessage;
  final List<ScrollController> _scrollControllers = List.generate(
    6,
    (_) => ScrollController(),
  );

  ScrollController get _scrollController =>
      _scrollControllers[_selectedGrade.clamp(0, 5)];

  @override
  void initState() {
    super.initState();
    _progressStore =
        widget.gradeProgressStore ?? const SecureProfileGradeProgressStore();
    _exams = List<GeneratedExam>.of(widget.initialExams);
    _selectedGrade = widget.initialGrade.clamp(0, 5);
    final completion = widget.initialCompletion;
    if (completion != null) {
      _selectedGrade = completion.grade;
      _recordCompletion(completion);
    }
    unawaited(_loadProgress());
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final saved = await _readSavedProgress();
    if (!mounted) return;
    if ((saved.grade > 0 || saved.level > 0) &&
        widget.initialCompletion == null) {
      setState(() => _selectedGrade = saved.grade);
    }
    await _loadGradeLevels(_selectedGrade);
  }

  Future<ProfileGradeProgress> _readSavedProgress() async {
    try {
      return await _progressStore.read(widget.profileId);
    } catch (_) {
      return ProfileGradeProgress.initial;
    }
  }

  Future<void> _loadGradeLevels(int grade) async {
    if (!mounted) return;
    final requestId = ++_levelRequestId;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _gradeLevels = null;
    });
    try {
      final (levels, sessions) = await (
        widget.examService.getGradeLevels(
          profileId: widget.profileId,
          grade: grade,
        ),
        widget.examService.getGradeRoadmap(
          profileId: widget.profileId,
          grade: grade,
        ),
      ).wait;
      if (!mounted || requestId != _levelRequestId) return;
      setState(() {
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
      });
      _scrollToCurrentLevel();
    } catch (_) {
      if (!mounted || requestId != _levelRequestId) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.readText(AppKeys.gradeRoadmapLoadFailed);
      });
    }
  }

  Future<void> _reload() => _loadGradeLevels(_selectedGrade);

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
        profileId: widget.profileId,
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
              profileId: widget.profileId,
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

  Future<void> _handleLevelTap(int level) async {
    if (_isOpeningExam || !_isLevelUnlocked(level)) return;
    final completed = _completedExamFor(_selectedGrade, level);
    if (completed != null &&
        (completed.userExamId != null ||
            completed.examId != null ||
            completed.userAiExamId != null)) {
      setState(() => _isOpeningExam = true);
      try {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => RepositoryProvider<ExamService>.value(
              value: widget.examService,
              child: ExamReviewScreen(
                userExamId: completed.userExamId,
                examId: completed.examId ?? completed.userAiExamId,
                profileId: widget.profileId,
                examType: examTypeGrade,
              ),
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _isOpeningExam = false);
      }
      return;
    }
    final active = _activeExamFor(_selectedGrade, level);
    await _openAssessment(level: level, activeExam: active);
  }

  Future<void> _openAssessment({
    required int level,
    GeneratedExam? activeExam,
  }) async {
    if (_isOpeningExam) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isOpeningExam = true;
      _openingLevel = level;
    });
    final roadmapRoute = ModalRoute.of(context);
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ExamAttemptScreen(
            examService: widget.examService,
            initialExam: activeExam,
            examType: examTypeGrade,
            gradeLabel: AssessmentFlowPolicy.gradeLabel(_selectedGrade),
            level: level,
            profileId: widget.profileId,
            startAtKindergarten: false,
            gradeProgressStore: _progressStore,
            allowQuestionNavigation: false,
            showQuestionNavigation: false,
            isResumedAssessment: activeExam != null,
            onGradeCompleted: (completion) {
              if (!mounted) return;
              setState(() => _recordCompletion(completion));
            },
            onResultBack: () {
              if (!mounted) return;
              if (activeExam != null) _exams.remove(activeExam);
              final navigator = Navigator.of(context);
              if (roadmapRoute == null) {
                navigator.popUntil((route) => route.isFirst);
                return;
              }
              navigator.popUntil((route) => identical(route, roadmapRoute));
            },
          ),
        ),
      );
      if (mounted) await _reload();
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningExam = false;
          _openingLevel = null;
        });
      }
    }
  }

  Future<void> _openGradeSelection() async {
    if (_isOpeningGradeSelection) return;
    HapticFeedback.selectionClick();
    _isOpeningGradeSelection = true;
    try {
      final selectedGrade = await Navigator.of(context).push<int>(
        MaterialPageRoute<int>(
          builder: (_) => GradeSelectionScreen(
            user: widget.user,
            initialGrades: widget.initialGrades,
            gradeService: widget.gradeService,
            examService: widget.examService,
            gradeProgressStore: _progressStore,
            examType: examTypeGrade,
            profileId: widget.profileId,
            initialGradeLabel: AssessmentFlowPolicy.gradeLabel(_selectedGrade),
            selectionOnly: true,
          ),
        ),
      );
      if (!mounted || selectedGrade == null) return;
      setState(() {
        _selectedGrade = AssessmentFlowPolicy.clampGrade(selectedGrade);
      });
      await _loadGradeLevels(_selectedGrade);
    } finally {
      _isOpeningGradeSelection = false;
    }
  }

  void _scrollToCurrentLevel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      // AnimatedSwitcher can keep the outgoing scroll view attached briefly.
      final position = _scrollController.positions.last;
      final viewport = position.context.notificationContext?.findRenderObject();
      if (viewport is! RenderBox || !viewport.hasSize) return;
      final center = GradeRoadmapLayout.centerForLevel(
        _currentLevel,
        viewport.size.width,
      );
      final target = (center.dy - position.viewportDimension * 0.55).clamp(
        0.0,
        position.maxScrollExtent,
      );
      position.jumpTo(target);
    });
  }

  String _gradeTitle(BuildContext context, int grade) {
    if (grade == 0) {
      return context.getText(AppKeys.gradeRoadmapKindergarten);
    }
    return context.formatText(AppKeys.gradeRoadmapGrade, {'grade': grade});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Scaffold(
      backgroundColor: const Color(0xFFD8EFB6),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _isLoading
                  ? Center(
                      key: const ValueKey('grade-roadmap-loading'),
                      child: CircularProgressIndicator(
                        color: colors.brandStrong,
                      ),
                    )
                  : _gradeLevels == null
                  ? const SizedBox.expand(
                      key: ValueKey('grade-roadmap-unavailable'),
                    )
                  : RefreshIndicator(
                      key: ValueKey('grade-roadmap-$_selectedGrade'),
                      color: colors.brandStrong,
                      onRefresh: _reload,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics(),
                        ),
                        padding: EdgeInsets.only(bottom: widget.bottomPadding),
                        child: _GradeRoadmapPath(
                          currentLevel: _currentLevel,
                          openingLevel: _openingLevel,
                          isCompleted: _isLevelCompleted,
                          isUnlocked: _isLevelUnlocked,
                          hasActiveExam: (level) =>
                              _activeExamFor(_selectedGrade, level) != null,
                          onLevelTap: _handleLevelTap,
                          mascotAsset: _mascotAsset,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _GradeRoadmapHeader(
                  selectedGrade: _selectedGrade,
                  gradeTitles: List<String>.generate(
                    6,
                    (grade) => _gradeTitle(context, grade),
                  ),
                  onGradeTap: _openGradeSelection,
                  onBack: widget.showCloseButton
                      ? () => Navigator.pop(context)
                      : null,
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _RoadmapError(
                      message: _errorMessage!,
                      onRetry: _reload,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeRoadmapHeader extends StatelessWidget {
  const _GradeRoadmapHeader({
    required this.selectedGrade,
    required this.gradeTitles,
    required this.onGradeTap,
    required this.onBack,
  });

  final int selectedGrade;
  final List<String> gradeTitles;
  final VoidCallback onGradeTap;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        safePadding.left + 16,
        safePadding.top + 12,
        safePadding.right + 12,
        12,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('grade-roadmap-grade-selector'),
              onTap: onGradeTap,
              borderRadius: BorderRadius.circular(21),
              child: Container(
                key: const ValueKey('grade-roadmap-grade-pill'),
                height: 38,
                width: 132,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: const Color(0xFFE4EEEE)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120F5E64),
                      offset: Offset(0, 2),
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        gradeTitles[selectedGrade].toUpperCase(),
                        key: ValueKey(
                          'grade-roadmap-grade-title-$selectedGrade',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF256B6B),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6B9393),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          if (onBack != null)
            IconButton(
              key: const ValueKey('grade-roadmap-close'),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF256B6B),
                side: const BorderSide(color: Color(0xFFE4EEEE)),
                minimumSize: const Size.square(38),
                maximumSize: const Size.square(38),
              ),
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
        ],
      ),
    );
  }
}

class _RoadmapError extends StatelessWidget {
  const _RoadmapError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: colors.errorSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            message,
            style: TextStyle(color: colors.error, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _GradeRoadmapPath extends StatelessWidget {
  const _GradeRoadmapPath({
    required this.currentLevel,
    required this.openingLevel,
    required this.isCompleted,
    required this.isUnlocked,
    required this.hasActiveExam,
    required this.onLevelTap,
    required this.mascotAsset,
  });

  static const double _nodeSize = 112;
  static const double _mascotSize = 104;

  final int currentLevel;
  final int? openingLevel;
  final bool Function(int level) isCompleted;
  final bool Function(int level) isUnlocked;
  final bool Function(int level) hasActiveExam;
  final Future<void> Function(int level) onLevelTap;
  final String mascotAsset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = GradeRoadmapLayout.heightForWidth(width);
        return SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Image.asset(
                  GradeRoadmapLayout.backgroundAsset,
                  key: const ValueKey('grade-roadmap-background'),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  excludeFromSemantics: true,
                ),
              ),
              for (var level = 10; level >= 1; level--)
                _buildLevel(
                  context,
                  level: level,
                  center: GradeRoadmapLayout.centerForLevel(level, width),
                  width: width,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevel(
    BuildContext context, {
    required int level,
    required Offset center,
    required double width,
  }) {
    final completed = isCompleted(level);
    final active = hasActiveExam(level);
    final current = level == currentLevel;
    final unlocked = isUnlocked(level) || current || active;
    final isOnLeft = center.dx <= width / 2;
    final nodeLeft = center.dx - _nodeSize / 2;
    final mascotLeft =
        (isOnLeft ? center.dx + _nodeSize / 2 - 3 : nodeLeft - _mascotSize)
            .clamp(8.0, math.max(8.0, width - _mascotSize - 8));
    final raysLeft = (isOnLeft ? nodeLeft - 25 : nodeLeft + _nodeSize - 1)
        .clamp(6.0, math.max(6.0, width - 32));
    return Positioned(
      left: nodeLeft,
      top: center.dy - _nodeSize / 2,
      child: SizedBox(
        width: _nodeSize,
        height: _nodeSize + 28,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            _RoadmapLevelNode(
              level: level,
              completed: completed,
              current: current,
              unlocked: unlocked,
              isLoading: openingLevel == level,
              onTap: unlocked ? () => onLevelTap(level) : null,
            ),
            if (current || completed)
              Positioned(
                left: raysLeft - nodeLeft,
                top: -4,
                child: _RoadmapNodeRays(
                  mirrored: isOnLeft,
                  color: current
                      ? const Color(0xFFFFC81E)
                      : Color.lerp(
                          _RoadmapLevelNode.colorForLevel(level),
                          const Color(0xFFFFD326),
                          0.58,
                        )!,
                ),
              ),
            if (current)
              Positioned(
                left: mascotLeft - nodeLeft,
                top: 7,
                child: IgnorePointer(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.96, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (_, value, child) => Transform.scale(
                      scale: value,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                    child: Image.asset(
                      mascotAsset,
                      width: _mascotSize,
                      height: _mascotSize,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoadmapLevelNode extends StatelessWidget {
  const _RoadmapLevelNode({
    required this.level,
    required this.completed,
    required this.current,
    required this.unlocked,
    required this.isLoading,
    required this.onTap,
  });

  final int level;
  final bool completed;
  final bool current;
  final bool unlocked;
  final bool isLoading;
  final VoidCallback? onTap;

  static const _levelColors = <Color>[
    Color(0xFF2E949A),
    Color(0xFFFF6B43),
    Color(0xFF5DDB72),
    Color(0xFFE85BD4),
    Color(0xFF18BFD1),
    Color(0xFFF8C945),
    Color(0xFF8B6DF2),
    Color(0xFFFF9347),
    Color(0xFF35C9A5),
    Color(0xFF4B8EF5),
    Color(0xFFC85BE9),
  ];

  static Color colorForLevel(int level) {
    return _levelColors[level % _levelColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = colorForLevel(level);
    final displayLevel = level - 1;
    final faceColor = unlocked || completed
        ? levelColor
        : Color.lerp(levelColor, const Color(0xFFCFD8DC), 0.14)!;
    final faceHighlight = Color.lerp(faceColor, Colors.white, 0.22)!;
    final lowerRim = Color.lerp(faceColor, Colors.black, 0.18)!;
    final iconColor = Color.lerp(faceColor, Colors.black, 0.42)!;
    final stateLabel = completed
        ? context.getText(AppKeys.gradeRoadmapCompleted)
        : current
        ? context.getText(AppKeys.gradeRoadmapCurrent)
        : unlocked
        ? '${context.getText(AppKeys.gradeRoadmapLevel)} $displayLevel'
        : context.getText(AppKeys.gradeRoadmapLocked);
    return Semantics(
      key: ValueKey('grade-roadmap-level-$level'),
      button: onTap != null,
      label:
          '${context.getText(AppKeys.gradeRoadmapLevel)} $displayLevel, $stateLabel',
      child: AnimatedScale(
        scale: current ? 1.04 : 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 112,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: lowerRim,
                        boxShadow: [
                          BoxShadow(
                            color: faceColor.withValues(
                              alpha: current ? 0.42 : 0.28,
                            ),
                            offset: const Offset(0, 8),
                            blurRadius: current ? 18 : 13,
                            spreadRadius: current ? 1 : 0,
                          ),
                        ],
                      ),
                      child: const SizedBox.square(dimension: 104),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: DecoratedBox(
                      key: ValueKey('grade-roadmap-level-$level-button'),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [faceHighlight, faceColor],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.62),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x21000000),
                            offset: Offset(0, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: SizedBox.square(
                        dimension: 104,
                        child: Center(
                          child: isLoading
                              ? const SizedBox.square(
                                  dimension: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : unlocked || completed
                              ? _RoadmapLevelLabel(level: displayLevel)
                              : Icon(
                                  Icons.lock_rounded,
                                  key: ValueKey(
                                    'grade-roadmap-level-$level-locked',
                                  ),
                                  color: iconColor,
                                  size: 39,
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (completed)
                    Positioned(
                      key: ValueKey('grade-roadmap-level-$level-completed'),
                      top: 3,
                      right: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: faceColor.withValues(alpha: 0.3),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.check_rounded,
                            color: lowerRim,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoadmapLevelLabel extends StatelessWidget {
  const _RoadmapLevelLabel({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.getText(AppKeys.gradeRoadmapLevel),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: [
              Shadow(
                color: Color(0x3D000000),
                offset: Offset(0, 1.5),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$level',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: [
              Shadow(
                color: Color(0x3D000000),
                offset: Offset(0, 2),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoadmapNodeRays extends StatelessWidget {
  const _RoadmapNodeRays({required this.color, required this.mirrored});

  final Color color;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final rays = SizedBox(
      width: 26,
      height: 31,
      child: Stack(
        children: [
          Positioned(
            left: 1,
            top: 18,
            child: _RoadmapNodeRay(color: color, angle: -1.1),
          ),
          Positioned(
            left: 8,
            top: 7,
            child: _RoadmapNodeRay(color: color, angle: -0.55),
          ),
          Positioned(
            left: 18,
            top: 2,
            child: _RoadmapNodeRay(color: color, angle: -0.12),
          ),
        ],
      ),
    );
    return mirrored ? Transform.flip(flipX: true, child: rays) : rays;
  }
}

class _RoadmapNodeRay extends StatelessWidget {
  const _RoadmapNodeRay({required this.color, required this.angle});

  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 5,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
