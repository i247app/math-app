import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/exam/controllers/grade_roadmap_controller.dart';
import 'package:numi/features/exam/controllers/grade_roadmap_state.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/grade_roadmap_layout.dart';
import 'package:numi/features/exam/models/exam.dart';
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

  late final GradeRoadmapController _controller;
  bool _wasLoading = true;
  bool _isOpeningGradeSelection = false;
  final List<ScrollController> _scrollControllers = List.generate(
    6,
    (_) => ScrollController(),
  );

  ScrollController get _scrollController =>
      _scrollControllers[_controller.state.selectedGrade];

  @override
  void initState() {
    super.initState();
    _controller = GradeRoadmapController(
      profileId: widget.profileId,
      examService: widget.examService,
      progressStore:
          widget.gradeProgressStore ?? const SecureProfileGradeProgressStore(),
      initialExams: widget.initialExams,
      initialGrade: widget.initialGrade,
      initialCompletion: widget.initialCompletion,
    )..addListener(_handleStateChanged);
    unawaited(_controller.initialize());
  }

  void _handleStateChanged() {
    if (!mounted) return;
    final state = _controller.state;
    final shouldScroll =
        _wasLoading && !state.isLoading && state.gradeLevels != null;
    _wasLoading = state.isLoading;
    setState(() {});
    if (shouldScroll) _scrollToCurrentLevel();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChanged);
    _controller.dispose();
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleLevelTap(int level) async {
    final target = _controller.beginOpeningLevel(level);
    if (target == null) return;
    try {
      if (target.destination == GradeRoadmapExamDestination.review) {
        final completed = target.exam!;
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
      } else {
        await _openAssessment(target);
      }
    } finally {
      _controller.finishOpeningExam();
    }
  }

  Future<void> _openAssessment(GradeRoadmapExamTarget target) async {
    HapticFeedback.mediumImpact();
    final roadmapRoute = ModalRoute.of(context);
    final activeExam = target.exam;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ExamAttemptScreen(
          examService: widget.examService,
          initialExam: activeExam,
          examType: examTypeGrade,
          gradeLabel: AssessmentFlowPolicy.gradeLabel(target.grade),
          level: target.level,
          profileId: widget.profileId,
          startAtKindergarten: false,
          gradeProgressStore: _controller.progressStore,
          allowQuestionNavigation: false,
          showQuestionNavigation: false,
          isResumedAssessment: activeExam != null,
          onGradeCompleted: _controller.recordCompletion,
          onResultBack: () {
            if (!mounted) return;
            if (activeExam != null) _controller.discardActiveExam(activeExam);
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
    if (mounted) await _controller.reload();
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
            gradeProgressStore: _controller.progressStore,
            examType: examTypeGrade,
            profileId: widget.profileId,
            initialGradeLabel: AssessmentFlowPolicy.gradeLabel(
              _controller.state.selectedGrade,
            ),
            selectionOnly: true,
          ),
        ),
      );
      if (!mounted || selectedGrade == null) return;
      await _controller.selectGrade(selectedGrade);
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
        _controller.state.currentLevel,
        viewport.size.width,
        grade: _controller.state.selectedGrade,
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
    final state = _controller.state;
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
              child: state.isLoading
                  ? Center(
                      key: const ValueKey('grade-roadmap-loading'),
                      child: CircularProgressIndicator(
                        color: colors.brandStrong,
                      ),
                    )
                  : state.gradeLevels == null
                  ? const SizedBox.expand(
                      key: ValueKey('grade-roadmap-unavailable'),
                    )
                  : RefreshIndicator(
                      key: ValueKey('grade-roadmap-${state.selectedGrade}'),
                      color: colors.brandStrong,
                      onRefresh: _controller.reload,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics(),
                        ),
                        padding: EdgeInsets.only(bottom: widget.bottomPadding),
                        child: _GradeRoadmapPath(
                          grade: state.selectedGrade,
                          currentLevel: state.currentLevel,
                          openingLevel: state.openingLevel,
                          isCompleted: (level) =>
                              state.level(level).isCompleted,
                          isUnlocked: (level) => state.level(level).isUnlocked,
                          hasActiveExam: (level) =>
                              state.level(level).activeExam != null,
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
                  selectedGrade: state.selectedGrade,
                  gradeTitles: List<String>.generate(
                    6,
                    (grade) => _gradeTitle(context, grade),
                  ),
                  onGradeTap: _openGradeSelection,
                  onBack: widget.showCloseButton
                      ? () => Navigator.pop(context)
                      : null,
                ),
                if (state.errorKey != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _RoadmapError(
                      message: context.getText(state.errorKey!),
                      onRetry: _controller.reload,
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
    required this.grade,
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

  final int grade;
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
        final height = GradeRoadmapLayout.heightForWidth(width, grade: grade);
        return SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Image.asset(
                  GradeRoadmapLayout.backgroundAssetForGrade(grade),
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
                  center: GradeRoadmapLayout.centerForLevel(
                    level,
                    width,
                    grade: grade,
                  ),
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
        : Color.lerp(levelColor, const Color(0xFFDFE5D7), 0.24)!;
    final faceHighlight = Color.lerp(faceColor, Colors.white, 0.2)!;
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
                    top: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF9F8E3), Color(0xFFD0D4B9)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2B6D6846),
                            offset: Offset(0, 4),
                            blurRadius: 10,
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
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [faceHighlight, faceColor],
                          stops: const [0, 0.8],
                        ),
                        border: Border.all(
                          color: const Color(0xFFFCF8DF),
                          width: 3.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F7D8053),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: SizedBox.square(
                        dimension: 104,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            IgnorePointer(
                              child: CustomPaint(
                                painter: _RoadmapNodeSheenPainter(
                                  rimColor: lowerRim,
                                ),
                              ),
                            ),
                            Center(
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (completed)
                    Positioned(
                      key: ValueKey('grade-roadmap-level-$level-completed'),
                      top: 0,
                      right: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Color(0xFFFFFEF4)],
                          ),
                          border: Border.all(color: const Color(0xFFF6F6DF)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x28606C43),
                              offset: Offset(0, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.check_rounded,
                            color: faceColor,
                            size: 22,
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

class _RoadmapNodeSheenPainter extends CustomPainter {
  const _RoadmapNodeSheenPainter({required this.rimColor});

  final Color rimColor;

  @override
  void paint(Canvas canvas, Size size) {
    final face = (Offset.zero & size).deflate(5.5);
    canvas.drawArc(
      face,
      0,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi,
          colors: [
            rimColor.withValues(alpha: 0),
            rimColor.withValues(alpha: 0.55),
            rimColor.withValues(alpha: 0.9),
            rimColor.withValues(alpha: 0.55),
            rimColor.withValues(alpha: 0),
          ],
          stops: const [0, 0.22, 0.5, 0.78, 1],
        ).createShader(face),
    );

    canvas.save();
    canvas.translate(size.width * 0.2, size.height * 0.2);
    canvas.rotate(-math.pi / 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 28, height: 12),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 21, height: 6),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );
    canvas.restore();
    canvas.drawCircle(
      Offset(size.width * 0.33, size.height * 0.12),
      2.5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }

  @override
  bool shouldRepaint(_RoadmapNodeSheenPainter oldDelegate) =>
      oldDelegate.rimColor != rimColor;
}

class _RoadmapLevelLabel extends StatelessWidget {
  const _RoadmapLevelLabel({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    const numberStyle = TextStyle(
      color: Colors.white,
      fontSize: 38,
      fontWeight: FontWeight.w900,
      height: 1,
      shadows: [
        Shadow(color: Color(0x33744E24), offset: Offset(0, 2), blurRadius: 3),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.getText(AppKeys.gradeRoadmapLevel),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1,
            shadows: [
              Shadow(
                color: Color(0x33744E24),
                offset: Offset(0, 1.5),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Stack(
          alignment: Alignment.center,
          children: [
            // Reinforce the glyphs even when the inherited font has no
            // heavier weight, without changing their size or semantics.
            ExcludeSemantics(
              child: RichText(
                textScaler: MediaQuery.textScalerOf(context),
                text: TextSpan(
                  text: '$level',
                  style: DefaultTextStyle.of(context).style
                      .merge(numberStyle)
                      .copyWith(
                        foreground: Paint()
                          ..color = Colors.white
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1.6
                          ..strokeJoin = StrokeJoin.round,
                        shadows: const [],
                      ),
                ),
              ),
            ),
            Text('$level', style: numberStyle),
          ],
        ),
      ],
    );
  }
}
