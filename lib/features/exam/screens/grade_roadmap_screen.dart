import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/assessment_screen.dart';
import 'package:numi/features/exam/screens/exam_review_entry_screen.dart';

class GradeRoadmapScreen extends StatefulWidget {
  const GradeRoadmapScreen({
    super.key,
    required this.profileId,
    required this.examService,
    this.initialExams = const <GeneratedExam>[],
    this.initialGrade = 0,
    this.gradeProgressStore,
  });

  final int profileId;
  final ExamService examService;
  final List<GeneratedExam> initialExams;
  final int initialGrade;
  final ProfileGradeProgressStore? gradeProgressStore;

  @override
  State<GradeRoadmapScreen> createState() => _GradeRoadmapScreenState();
}

class _GradeRoadmapScreenState extends State<GradeRoadmapScreen> {
  static const _backgroundAssets = <String>[
    'assets/images/grade-roadmap-background.png',
    'assets/images/grade-roadmap-background-grade-1.png',
    'assets/images/grade-roadmap-background-grade-2.png',
    'assets/images/grade-roadmap-background-grade-3.png',
    'assets/images/grade-roadmap-background-grade-4.png',
    'assets/images/grade-roadmap-background-grade-5.png',
  ];
  static const _mascotAsset = 'assets/images/grade-roadmap-mascot.png';
  static const _maxLevel = 10;

  late final ProfileGradeProgressStore _progressStore;
  late List<GeneratedExam> _exams;
  ProfileGradeProgress _progress = ProfileGradeProgress.initial;
  late int _selectedGrade;
  bool _isLoading = true;
  bool _isOpeningExam = false;
  bool _didPrecacheBackgrounds = false;
  int _gradeTransitionDirection = 1;
  double _horizontalDragDistance = 0;
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
    unawaited(_loadProgress());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheBackgrounds) return;
    _didPrecacheBackgrounds = true;
    for (final asset in _backgroundAssets) {
      unawaited(precacheImage(AssetImage(asset), context));
    }
  }

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final shouldLoadStats = _exams.isEmpty;
    final savedProgress = _readSavedProgress();
    final stats = shouldLoadStats ? await _readInitialStats() : null;
    if (!mounted) return;

    if (stats != null) {
      _exams = _examsFromStats(stats);
    }
    final fallback = _fallbackProgressFromExams();
    setState(() {
      _progress = fallback;
      _selectedGrade = fallback.grade;
      _isLoading = false;
      _errorMessage = shouldLoadStats && stats == null
          ? context.readText(AppKeys.gradeRoadmapLoadFailed)
          : null;
    });
    _scrollToCurrentLevel();

    final saved = await savedProgress;
    if (!mounted || saved.level <= 0) return;
    setState(() {
      _progress = saved;
      _selectedGrade = saved.grade;
    });
    _scrollToCurrentLevel();
  }

  Future<ProfileGradeProgress> _readSavedProgress() async {
    try {
      return await _progressStore.read(widget.profileId);
    } catch (_) {
      return ProfileGradeProgress.initial;
    }
  }

  Future<List<ExamStats>?> _readInitialStats() async {
    try {
      return await widget.examService.getExamStats(
        profileId: widget.profileId,
        examType: examTypeGrade,
      );
    } catch (_) {
      return null;
    }
  }

  ProfileGradeProgress _fallbackProgressFromExams() {
    final active = _exams.where(_isActiveExam).toList(growable: false);
    final candidates = active.isNotEmpty ? active : _exams;
    if (candidates.isEmpty) {
      return ProfileGradeProgress(grade: _selectedGrade, level: 1);
    }
    final exam = candidates.reduce((latest, candidate) {
      final latestDate = DateTime.tryParse(
        latest.modifyDt ?? latest.submittedDt ?? latest.createDt ?? '',
      );
      final candidateDate = DateTime.tryParse(
        candidate.modifyDt ?? candidate.submittedDt ?? candidate.createDt ?? '',
      );
      if (latestDate == null) return candidate;
      if (candidateDate == null) return latest;
      return candidateDate.isAfter(latestDate) ? candidate : latest;
    });
    return ProfileGradeProgress(
      grade: (exam.grade ?? _selectedGrade).clamp(0, 5),
      level: (exam.level ?? 1).clamp(1, _maxLevel),
    );
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait<Object>([
        widget.examService.getExamStats(
          profileId: widget.profileId,
          examType: examTypeGrade,
        ),
        _progressStore.read(widget.profileId),
      ]);
      if (!mounted) return;
      final stats = results[0] as List<ExamStats>;
      final progress = results[1] as ProfileGradeProgress;
      setState(() {
        _exams = _examsFromStats(stats);
        _progress = progress.level > 0
            ? progress
            : _fallbackProgressFromExams();
        _selectedGrade = _progress.grade;
        _isLoading = false;
      });
      _scrollToCurrentLevel();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.readText(AppKeys.gradeRoadmapLoadFailed);
      });
    }
  }

  List<GeneratedExam> _examsFromStats(List<ExamStats> stats) {
    final exams = <GeneratedExam>[];
    for (final item in stats) {
      final active = item.inProgressExams.where(_isActiveExam).toList();
      if (active.isNotEmpty && !_isTerminalStatus(item.status)) {
        exams.addAll(active);
        continue;
      }
      if ((item.status ?? '').trim().toUpperCase() == 'CANCEL') continue;
      exams.add(
        GeneratedExam(
          userExamId: item.userExamId,
          profileId: widget.profileId,
          examStatus: item.status,
          examType: item.examType ?? examTypeGrade,
          grade: item.grade,
          level: item.level,
          submittedDt: item.lastSubmittedDt?.toIso8601String(),
          grading: ExamGrading(
            correctNumber: item.correctNumber,
            scorePercentage: item.scorePercentage.round(),
            skippedNumber: item.skippedNumber,
            totalQuestions: item.totalQuestions,
          ),
          questions: const <ExamQuestion>[],
        ),
      );
    }
    return exams;
  }

  bool _isTerminalStatus(String? value) {
    final status = value?.trim().toUpperCase();
    return status == 'COMPLETE' || status == 'SUBMITTED' || status == 'CANCEL';
  }

  bool _isActiveExam(GeneratedExam exam) {
    final status = exam.examStatus?.trim().toUpperCase();
    return status == 'ACTIVE' || status == 'IN_PROGRESS';
  }

  GeneratedExam? _activeExamFor(int grade, int level) {
    GeneratedExam? latest;
    for (final exam in _exams) {
      if (_isActiveExam(exam) && exam.grade == grade && exam.level == level) {
        if (latest == null || _examDate(exam).isAfter(_examDate(latest))) {
          latest = exam;
        }
      }
    }
    return latest;
  }

  GeneratedExam? _completedExamFor(int grade, int level) {
    GeneratedExam? latest;
    for (final exam in _exams) {
      if (!_isActiveExam(exam) && exam.grade == grade && exam.level == level) {
        if (latest == null || _examDate(exam).isAfter(_examDate(latest))) {
          latest = exam;
        }
      }
    }
    return latest;
  }

  GeneratedExam? _reviewExamForLevel(int grade, int level) {
    final exactExam = _completedExamFor(grade, level);
    if (exactExam != null) {
      return exactExam;
    }

    final targetValue = (grade * _maxLevel) + level;
    if (targetValue >= _progress.sortValue) {
      return null;
    }

    GeneratedExam? jumpSource;
    for (final exam in _exams) {
      final examGrade = exam.grade;
      final examLevel = exam.level;
      if (_isActiveExam(exam) || examGrade == null || examLevel == null) {
        continue;
      }
      final examValue = (examGrade * _maxLevel) + examLevel;
      final isImmediatelyBeforeSkippedLevel = examValue == targetValue - 1;
      final isPassingAttempt = (exam.grading?.scorePercentage ?? 0) >= 50;
      if (!isImmediatelyBeforeSkippedLevel || !isPassingAttempt) {
        continue;
      }
      if (jumpSource == null ||
          _examDate(exam).isAfter(_examDate(jumpSource))) {
        jumpSource = exam;
      }
    }
    return jumpSource;
  }

  DateTime _examDate(GeneratedExam exam) {
    return DateTime.tryParse(
          exam.modifyDt ?? exam.submittedDt ?? exam.createDt ?? '',
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  int get _currentLevel {
    final active = _exams.where(_isActiveExam).toList(growable: false);
    if (active.isNotEmpty) {
      final selectedActive = active.where(
        (exam) => exam.grade == _selectedGrade,
      );
      if (selectedActive.isNotEmpty) {
        return (selectedActive.last.level ?? 1).clamp(1, _maxLevel);
      }
    }
    if (_selectedGrade == _progress.grade) {
      return _progress.level.clamp(1, _maxLevel);
    }
    return 1;
  }

  int get _highestUnlockedValue {
    final grade = _progress.highestUnlockedGrade ?? _progress.grade;
    final level = _progress.highestUnlockedLevel ?? _progress.level;
    return (grade * _maxLevel) + level.clamp(1, _maxLevel);
  }

  bool _isLevelUnlocked(int level) {
    return (_selectedGrade * _maxLevel) + level <= _highestUnlockedValue;
  }

  bool _isLevelCompleted(int level) {
    final exam = _completedExamFor(_selectedGrade, level);
    final score = exam?.grading?.scorePercentage;
    return exam != null && score != null && score >= 50;
  }

  Future<void> _handleLevelTap(int level) async {
    final active = _activeExamFor(_selectedGrade, level);
    if (active != null) {
      await _openAssessment(level: level, activeExam: active);
      return;
    }

    final reviewExam = _reviewExamForLevel(_selectedGrade, level);
    if (reviewExam != null) {
      _openReview(reviewExam);
      return;
    }

    final isCurrent =
        _selectedGrade == _progress.grade && level == _currentLevel;
    if (isCurrent) {
      await _openAssessment(level: level);
      return;
    }
    if (_isLevelUnlocked(level)) {
      await _openAssessment(level: level);
    }
  }

  void _openReview(GeneratedExam exam) {
    final userExamId = exam.userExamId;
    final examId = exam.examId ?? exam.userAiExamId ?? exam.id;
    if (userExamId == null && examId == null) return;
    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<ExamService>.value(
          value: widget.examService,
          child: ExamReviewScreen(
            examId: userExamId == null ? examId : null,
            userExamId: userExamId,
            profileId: widget.profileId,
            examType: examTypeGrade,
            initialExam: exam,
          ),
        ),
      ),
    );
  }

  Future<void> _openAssessment({
    required int level,
    GeneratedExam? activeExam,
  }) async {
    if (_isOpeningExam) return;
    HapticFeedback.mediumImpact();
    setState(() => _isOpeningExam = true);
    final roadmapRoute = ModalRoute.of(context);
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => AiAssessmentScreen(
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
            onResultBack: () {
              if (!mounted) return;
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
      if (mounted) setState(() => _isOpeningExam = false);
    }
  }

  void _changeGrade(int delta) {
    final next = (_selectedGrade + delta).clamp(0, 5);
    if (next == _selectedGrade) return;
    HapticFeedback.selectionClick();
    setState(() {
      _gradeTransitionDirection = next > _selectedGrade ? 1 : -1;
      _selectedGrade = next;
    });
    _scrollToCurrentLevel();
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _horizontalDragDistance = 0;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    _horizontalDragDistance += details.primaryDelta ?? 0;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final movement = velocity.abs() >= 320 ? velocity : _horizontalDragDistance;
    _horizontalDragDistance = 0;
    if (movement.abs() < 48) return;
    _changeGrade(movement < 0 ? 1 : -1);
  }

  void _handleHorizontalDragCancel() {
    _horizontalDragDistance = 0;
  }

  void _scrollToCurrentLevel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final index = 10 - _currentLevel;
      final target = (index * 152.0 - 90).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(target);
    });
  }

  String _gradeTitle(BuildContext context) {
    if (_selectedGrade == 0) {
      return context.getText(AppKeys.gradeRoadmapKindergarten);
    }
    return context.formatText(AppKeys.gradeRoadmapGrade, {
      'grade': _selectedGrade,
    });
  }

  String get _backgroundAsset => _backgroundAssets[_selectedGrade];

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _handleHorizontalDragStart,
        onHorizontalDragUpdate: _handleHorizontalDragUpdate,
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        onHorizontalDragCancel: _handleHorizontalDragCancel,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 520),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (currentChild, previousChildren) => Stack(
                fit: StackFit.expand,
                children: [...previousChildren, ?currentChild],
              ),
              transitionBuilder: (child, animation) {
                final isIncoming =
                    child.key ==
                    ValueKey('grade-roadmap-background-$_selectedGrade');
                final direction = isIncoming
                    ? _gradeTransitionDirection
                    : -_gradeTransitionDirection;
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(direction * 0.035, 0),
                      end: Offset.zero,
                    ).animate(curved),
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 1.015,
                        end: 1,
                      ).animate(curved),
                      child: child,
                    ),
                  ),
                );
              },
              child: SizedBox.expand(
                key: ValueKey('grade-roadmap-background-$_selectedGrade'),
                child: Image.asset(
                  _backgroundAsset,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Column(
              children: [
                _GradeRoadmapHeader(
                  title: _gradeTitle(context),
                  transitionDirection: _gradeTransitionDirection,
                  onBack: () => Navigator.pop(context),
                ),
                _GradeSwitcher(
                  canGoBack: _selectedGrade > 0,
                  canGoForward: _selectedGrade < 5,
                  onBack: () => _changeGrade(-1),
                  onForward: () => _changeGrade(1),
                ),
                if (_errorMessage != null)
                  _RoadmapError(message: _errorMessage!, onRetry: _reload),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final isIncoming =
                          child.key ==
                          ValueKey('grade-roadmap-$_selectedGrade');
                      final direction = isIncoming
                          ? _gradeTransitionDirection
                          : -_gradeTransitionDirection;
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(direction * 0.09, 0),
                            end: Offset.zero,
                          ).animate(curved),
                          child: child,
                        ),
                      );
                    },
                    child: _isLoading
                        ? Center(
                            key: const ValueKey('grade-roadmap-loading'),
                            child: CircularProgressIndicator(
                              color: colors.brandStrong,
                            ),
                          )
                        : RefreshIndicator(
                            key: ValueKey('grade-roadmap-$_selectedGrade'),
                            color: colors.brandStrong,
                            onRefresh: _reload,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                12,
                                18,
                                36,
                              ),
                              child: _GradeRoadmapPath(
                                currentLevel: _currentLevel,
                                isCurrentGrade:
                                    _selectedGrade == _progress.grade ||
                                    _exams.any(
                                      (exam) =>
                                          _isActiveExam(exam) &&
                                          exam.grade == _selectedGrade,
                                    ),
                                isOpeningExam: _isOpeningExam,
                                isCompleted: _isLevelCompleted,
                                isUnlocked: _isLevelUnlocked,
                                hasActiveExam: (level) =>
                                    _activeExamFor(_selectedGrade, level) !=
                                    null,
                                onLevelTap: _handleLevelTap,
                                mascotAsset: _mascotAsset,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeRoadmapHeader extends StatelessWidget {
  const _GradeRoadmapHeader({
    required this.title,
    required this.transitionDirection,
    required this.onBack,
  });

  final String title;
  final int transitionDirection;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final height = topInset + 82;
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 18,
            top: topInset + 7,
            child: Material(
              color: const Color(0x4DFFFFFF),
              elevation: 2,
              shadowColor: const Color(0x28000000),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: const SizedBox.square(
                  dimension: 42,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: topInset + 5,
            child: SizedBox(
              height: 46,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _HeaderRays(mirrored: true),
                  const SizedBox(width: 9),
                  Flexible(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(transitionDirection * 0.12, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Text(
                        title,
                        key: ValueKey(title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              color: Color(0x26000000),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  const _HeaderRays(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRays extends StatelessWidget {
  const _HeaderRays({this.mirrored = false});

  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    const rays = SizedBox(
      width: 27,
      height: 30,
      child: Stack(
        children: [
          Positioned(left: 1, top: 13, child: _HeaderRay(angle: -0.05)),
          Positioned(left: 8, top: 3, child: _HeaderRay(angle: -0.8)),
          Positioned(left: 18, top: 0, child: _HeaderRay(angle: -1.25)),
        ],
      ),
    );
    return mirrored ? Transform.flip(flipX: true, child: rays) : rays;
  }
}

class _HeaderRay extends StatelessWidget {
  const _HeaderRay({required this.angle});

  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 5,
        height: 13,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD73A),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _GradeSwitcher extends StatelessWidget {
  const _GradeSwitcher({
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: canGoBack ? onBack : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              foregroundColor: colors.brandStrong,
              disabledForegroundColor: colors.textMuted.withValues(alpha: 0.35),
            ),
            icon: const Icon(Icons.chevron_left_rounded, size: 30),
          ),
          Text(
            context.getText(AppKeys.gradeRoadmapCurrent),
            style: TextStyle(
              color: colors.brandStrong,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            onPressed: canGoForward ? onForward : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              foregroundColor: colors.brandStrong,
              disabledForegroundColor: colors.textMuted.withValues(alpha: 0.35),
            ),
            icon: const Icon(Icons.chevron_right_rounded, size: 30),
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
    required this.isCurrentGrade,
    required this.isOpeningExam,
    required this.isCompleted,
    required this.isUnlocked,
    required this.hasActiveExam,
    required this.onLevelTap,
    required this.mascotAsset,
  });

  static const double _rowHeight = 152;
  static const double _nodeSize = 112;

  final int currentLevel;
  final bool isCurrentGrade;
  final bool isOpeningExam;
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
        final horizontalTravel = math.max(0.0, width - _nodeSize - 18);
        return SizedBox(
          height: 10 * _rowHeight + 22,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < 10; index++)
                _buildLevel(
                  context,
                  level: 10 - index,
                  index: index,
                  x:
                      9 +
                      horizontalTravel *
                          ((math.sin(index * math.pi / 3 - math.pi / 2) + 1) /
                              2),
                  isOnLeft: math.sin(index * math.pi / 3 - math.pi / 2) <= 0,
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
    required int index,
    required double x,
    required bool isOnLeft,
  }) {
    final completed = isCompleted(level);
    final active = hasActiveExam(level);
    final current =
        isCurrentGrade &&
        level == currentLevel &&
        (isUnlocked(level) || active);
    final unlocked = isUnlocked(level) || current || active;
    return Positioned(
      left: x,
      top: index * _rowHeight + 8,
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
              isLoading: isOpeningExam && current,
              onTap: unlocked || completed || active
                  ? () => onLevelTap(level)
                  : null,
            ),
            if (current || completed)
              Positioned(
                left: isOnLeft ? -25 : _nodeSize - 1,
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
                left: isOnLeft ? _nodeSize - 3 : -118,
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
                    child: Image.asset(mascotAsset, width: 118, height: 118),
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
    Color(0xFFFF3344),
    Color(0xFFFF7A20),
    Color(0xFFFFD91A),
    Color(0xFF8EEB18),
    Color(0xFF2DD174),
    Color(0xFF13C8C2),
    Color(0xFF18BFE0),
    Color(0xFF1B79ED),
    Color(0xFFB33EEB),
    Color(0xFFF43C9B),
  ];

  static Color colorForLevel(int level) {
    return _levelColors[(level - 1) % _levelColors.length];
  }

  String get _assetState {
    if (completed) return 'completed';
    if (unlocked) return 'available';
    return 'locked';
  }

  String get _assetPath {
    return 'assets/images/grade-roadmap-buttons/'
        'level-${level.toString().padLeft(2, '0')}-$_assetState.png';
  }

  @override
  Widget build(BuildContext context) {
    final stateLabel = completed
        ? context.getText(AppKeys.gradeRoadmapCompleted)
        : current
        ? context.getText(AppKeys.gradeRoadmapCurrent)
        : unlocked
        ? '${context.getText(AppKeys.gradeRoadmapLevel)} $level'
        : context.getText(AppKeys.gradeRoadmapLocked);
    return Semantics(
      key: ValueKey('grade-roadmap-level-$level'),
      button: onTap != null,
      label:
          '${context.getText(AppKeys.gradeRoadmapLevel)} $level, $stateLabel',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    _assetPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                if (unlocked || completed)
                  Align(
                    alignment: Alignment.center,
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.getText(AppKeys.gradeRoadmapLevel),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x45000000),
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
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x45000000),
                                      offset: Offset(0, 2),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
