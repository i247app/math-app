import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/exam_practice_topic_formatter.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_grade_ribbon.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/exam/widgets/assessment_result/exit_to_grade_selection.dart';
import 'package:numi/features/exam/widgets/assessment_result/test_again_loader.dart';
import 'package:numi/features/exam/widgets/shared/exam_header_icon_button.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class AssessmentPlacementResultScreen extends StatefulWidget {
  const AssessmentPlacementResultScreen({
    super.key,
    required this.grade,
    this.level,
    required this.correctAnswers,
    required this.totalQuestions,
    this.examType = examTypeAssessment,
    this.examService,
    this.profileId,
    this.userExamId,
    this.previousGrade,
    this.practiceWeakTopics = const <ExamPracticeTopic>[],
    this.onTestAgainGenerated,
    this.onViewDetails,
    this.onBack,
  });

  final int grade;
  final int? level;
  final int correctAnswers;
  final int totalQuestions;
  final String examType;
  final ExamService? examService;
  final int? profileId;
  final int? userExamId;
  final int? previousGrade;
  final List<ExamPracticeTopic> practiceWeakTopics;
  final ValueChanged<GeneratedExam>? onTestAgainGenerated;
  final VoidCallback? onViewDetails;
  final VoidCallback? onBack;

  @override
  State<AssessmentPlacementResultScreen> createState() =>
      _AssessmentPlacementResultScreenState();
}

class _AssessmentPlacementResultScreenState
    extends State<AssessmentPlacementResultScreen> {
  late final ExamService _examService;
  bool _isGeneratingAgain = false;
  bool _progressResolved = false;
  int? _resolvedCurrentGrade;
  List<int> _resolvedPreviousGrades = const <int>[];
  List<int> _resolvedPreviousTestNumbers = const <int>[];
  int _resolvedCurrentTestNumber = 1;

  int get _grade =>
      AssessmentFlowPolicy.clampGrade(_resolvedCurrentGrade ?? widget.grade);
  bool get _showsAssessmentChart =>
      widget.examType.trim().toUpperCase() == examTypeAssessment;
  int get _totalQuestions => widget.totalQuestions.clamp(0, 1000000);
  int get _correctAnswers => widget.correctAnswers.clamp(0, _totalQuestions);

  @override
  void initState() {
    super.initState();
    _examService = widget.examService ?? context.read<ExamService>();
    _resolvedCurrentGrade = widget.grade;
    _progressResolved = !_showsAssessmentChart || widget.profileId == null;
    if (_showsAssessmentChart &&
        _progressResolved &&
        widget.previousGrade != null) {
      _resolvedPreviousGrades = <int>[widget.previousGrade!];
      _resolvedPreviousTestNumbers = const <int>[1];
      _resolvedCurrentTestNumber = 2;
    }
    if (_showsAssessmentChart) _fetchExamProgress();
  }

  Future<void> _fetchExamProgress() async {
    final profileId = widget.profileId;
    if (profileId == null) {
      return;
    }
    var hasUsableProgress = false;
    try {
      final toDt = DateTime.now();
      final progress = await _examService.getExamProgress(
        profileId: profileId,
        fromDt: toDt.subtract(const Duration(days: 7)),
        toDt: toDt,
        examType: widget.examType,
      );
      if (mounted) {
        hasUsableProgress = _applyExamProgress(progress);
      }
    } catch (_) {
      // Keep the current result visible if progress is unavailable.
    } finally {
      if (mounted) {
        setState(() {
          if (!hasUsableProgress) {
            _resolvedPreviousGrades = widget.previousGrade == null
                ? const <int>[]
                : <int>[widget.previousGrade!];
            _resolvedPreviousTestNumbers = widget.previousGrade == null
                ? const <int>[]
                : const <int>[1];
            _resolvedCurrentTestNumber = _resolvedPreviousGrades.isEmpty
                ? 1
                : 2;
          }
          _progressResolved = true;
        });
      }
    }
  }

  bool _applyExamProgress(ExamProgressResponse progress) {
    final validPoints = progress.series.where((point) {
      final status = point.status?.trim().toUpperCase();
      final isCompleted =
          status == null || status == 'COMPLETE' || status == 'SUBMITTED';
      return point.grade != null && isCompleted;
    }).toList();
    if (validPoints.isEmpty) return false;

    validPoints.sort((a, b) {
      final bySequence = a.sequence.compareTo(b.sequence);
      return bySequence != 0
          ? bySequence
          : a.completedDt.compareTo(b.completedDt);
    });

    final currentIndex = widget.userExamId == null
        ? validPoints.length - 1
        : validPoints.indexWhere((point) => point.examId == widget.userExamId);
    final hasCurrentResult = currentIndex >= 0;
    final currentPoint = hasCurrentResult ? validPoints[currentIndex] : null;
    final currentTestNumber = hasCurrentResult
        ? currentPoint!.sequence
        : validPoints.last.sequence + 1;
    final historyEndIndex = hasCurrentResult
        ? currentIndex
        : validPoints.length;
    final historyStartIndex = historyEndIndex > 4 ? historyEndIndex - 4 : 0;
    final previousPoints = validPoints.sublist(
      historyStartIndex,
      historyEndIndex,
    );

    if (currentPoint?.grade != null) {
      _resolvedCurrentGrade = currentPoint!.grade!;
    }
    _resolvedPreviousGrades = previousPoints
        .map((point) => point.grade!)
        .toList(growable: false);
    _resolvedPreviousTestNumbers = previousPoints
        .map((point) => point.sequence)
        .toList(growable: false);
    _resolvedCurrentTestNumber = currentTestNumber;
    return true;
  }

  Future<void> _generateAgain(String examType) async {
    HapticFeedback.mediumImpact();
    setState(() => _isGeneratingAgain = true);

    try {
      final generatedExam = await _examService.generateAssessmentExam(
        examType: examType,
        gradeLabel: AssessmentFlowPolicy.gradeLabel(_grade),
        level: widget.level,
        profileId: widget.profileId,
        userExamId: examType == examTypePractice ? widget.userExamId : null,
      );
      if (!mounted) {
        return;
      }
      ExamCache.seedDetail(generatedExam);
      final onGenerated = widget.onTestAgainGenerated;
      if (onGenerated != null) {
        onGenerated(generatedExam);
      } else {
        Navigator.of(context).pop(generatedExam);
      }
    } on ExamException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isGeneratingAgain = false);
      _showGenerationError(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isGeneratingAgain = false);
      _showGenerationError(AppStrings.current(AppKeys.testAgainCreateFailed));
    }
  }

  void _showGenerationError(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.getText(AppKeys.testAgainDialogTitle)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.getText(AppKeys.close)),
            ),
          ],
        );
      },
    );
  }

  void _exitResult() {
    if (_isGeneratingAgain) {
      return;
    }
    HapticFeedback.mediumImpact();
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }
    exitToGradeSelection(context);
  }

  void _viewDetails() {
    HapticFeedback.selectionClick();
    final onViewDetails = widget.onViewDetails;
    if (onViewDetails != null) {
      onViewDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _isGeneratingAgain
                  ? const AssessmentTestAgainLoader()
                  : !_progressResolved
                  ? _buildProgressSkeleton()
                  : _buildResultContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSkeleton() {
    return SizedBox.expand(
      key: const ValueKey('assessment-placement-progress-loading'),
      child: LayoutBuilder(
        builder: (context, constraints) => AppSkeletonLoader(
          builder: (context, color) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSkeletonBlock(
                    key: const ValueKey('assessment-placement-ribbon-skeleton'),
                    height: 72,
                    radius: 28,
                    color: color,
                  ),
                  const SizedBox(height: 12),
                  AppSkeletonBlock(
                    key: const ValueKey('assessment-placement-chart-skeleton'),
                    height: constraints.maxHeight * 0.38,
                    radius: 20,
                    color: color,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent(BuildContext context) {
    final colors = context.themeColors;
    final resultSummary = context.formatText(
      AppKeys.placementResultCorrectSummary,
      {'correct': _correctAnswers, 'total': _totalQuestions},
    );
    final weakTopics = formatExamPracticeTopics(
      widget.practiceWeakTopics,
      conjunction: context.getText(AppKeys.examReviewTopicConjunction),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = constraints.maxHeight;
        final isCompact = viewportHeight <= 740;
        final mascotSize = isCompact
            ? (viewportHeight * 0.17).clamp(118.0, 138.0)
            : (viewportHeight * 0.21).clamp(150.0, 180.0);
        final sectionSpacing = isCompact ? 8.0 : 12.0;

        return SingleChildScrollView(
          key: const ValueKey('assessment-placement-result'),
          physics: const BouncingScrollPhysics(),
          child: Semantics(
            label: resultSummary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: null,
                  topInset: 0,
                  backgroundColor: Colors.white,
                  actionWidth: 44,
                  horizontalPadding: 16,
                  leading: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFB5EBF4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF04A8B3,
                            ).withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ExamHeaderIconButton(
                        key: const ValueKey('placement-result-close'),
                        icon: Icons.close_rounded,
                        color: const Color(0xFF04A8B3),
                        size: 38,
                        iconSize: 22,
                        circle: true,
                        onTap: _exitResult,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    height: 0,
                    child: Text(context.getText(AppKeys.assessmentResultTitle)),
                  ),
                ),
                SizedBox(height: isCompact ? 2.0 : 6.0),
                Text(
                  context.getText(AppKeys.placementResultLevel),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.andika(
                    color: const Color(0xFF04A8B3),
                    fontSize: FontSize.xxl,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                _PlacementGradeTitle(grade: _grade),
                if (widget.level case final level?) ...[
                  const SizedBox(height: 6),
                  Text(
                    context.formatText(AppKeys.placementResultGradeLevel, {
                      'level': level,
                    }),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.andika(
                      color: colors.brandStrong,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
                SizedBox(height: isCompact ? 2.0 : 4.0),
                _CelebrationMascot(size: mascotSize),
                SizedBox(height: isCompact ? 2.0 : 4.0),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, opacity, child) => Opacity(
                    key: const ValueKey('assessment-placement-history-content'),
                    opacity: opacity,
                    child: child,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AssessmentGradeRibbon(currentGrade: _grade),
                      ),
                      if (_showsAssessmentChart) ...[
                        SizedBox(height: sectionSpacing),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AssessmentProgressionChart(
                            finalGrade: _grade,
                            previousGrades: _resolvedPreviousGrades,
                            testNumbers: <int>[
                              ..._resolvedPreviousTestNumbers,
                              _resolvedCurrentTestNumber,
                            ],
                            firstTestNumber:
                                _resolvedCurrentTestNumber -
                                _resolvedPreviousGrades.length,
                            chartHeight: isCompact ? 145.0 : 180.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (weakTopics.isNotEmpty) ...[
                  SizedBox(height: sectionSpacing),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _PlacementWeakTopicsBanner(topics: weakTopics),
                  ),
                ],
                SizedBox(height: sectionSpacing),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _PlacementActionButton(
                          key: const ValueKey('placement-view-details'),
                          label: context.getText(
                            AppKeys.placementResultViewDetails,
                          ),
                          icon: Icons.assignment_outlined,
                          color: AppColors.resultCoral,
                          outlined: true,
                          onTap: _viewDetails,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PlacementActionButton(
                          key: const ValueKey('placement-practice-again'),
                          label: context.getText(
                            AppKeys.placementResultPractice,
                          ),
                          icon: Icons.sync_rounded,
                          color: AppColors.teal500,
                          onTap: () => _generateAgain(examTypePractice),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isCompact ? 14.0 : 24.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlacementWeakTopicsBanner extends StatelessWidget {
  const _PlacementWeakTopicsBanner({required this.topics});

  final String topics;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('placement-weak-topics'),
      constraints: const BoxConstraints(minHeight: 36),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE2D6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        context.formatText(AppKeys.placementResultWeakTopics, {
          'topics': topics,
        }),
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: AppColors.coral600,
          fontSize: FontSize.small,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}

class _PlacementGradeTitle extends StatelessWidget {
  const _PlacementGradeTitle({required this.grade});

  final int grade;

  @override
  Widget build(BuildContext context) {
    final label = grade == AssessmentFlowPolicy.minimumGrade
        ? context.getText(AppKeys.placementResultKindergarten)
        : context.formatText(AppKeys.placementResultGrade, {'grade': grade});
    final separatorIndex = label.lastIndexOf(' ');
    final splitIndex = separatorIndex < 0
        ? (label.characters.length / 2).ceil()
        : label.characters.toList().indexOf(' ');
    final glyphs = label.characters.toList();
    final textStyle = GoogleFonts.andika(
      fontSize: 44,
      fontWeight: FontWeight.w900,
      height: 1.08,
      letterSpacing: 1.2,
    );

    return SizedBox(
      key: const ValueKey('placement-grade-container'),
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Semantics(
          label: label,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Keeps the complete localized title available to finders and
              // accessibility tools while the visible glyphs follow an arc.
              ExcludeSemantics(
                child: Opacity(
                  opacity: 0,
                  child: Text(label, key: const ValueKey('placement-grade')),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var index = 0; index < glyphs.length; index++)
                      Transform.translate(
                        offset: Offset(
                          0,
                          -5.0 *
                              (1 -
                                  ((index / (glyphs.length - 1)) * 2 - 1)
                                      .abs()),
                        ),
                        child: Transform.rotate(
                          angle: ((index / (glyphs.length - 1)) - 0.5) * 0.22,
                          child: Text(
                            glyphs[index],
                            style: textStyle.copyWith(
                              color: index < splitIndex
                                  ? AppColors.teal600
                                  : AppColors.coral600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CelebrationMascot extends StatefulWidget {
  const _CelebrationMascot({required this.size});

  final double size;

  @override
  State<_CelebrationMascot> createState() => _CelebrationMascotState();
}

class _CelebrationMascotState extends State<_CelebrationMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _mascotScale;
  late final Animation<double> _mascotOffsetY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _mascotScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.78, curve: Curves.easeOutBack),
    ).drive(Tween<double>(begin: 0.96, end: 1));
    _mascotOffsetY =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 12,
              end: -9,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 48,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: -9,
              end: 3,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 3,
              end: 0,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 22,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0, 0.8)),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        key: const ValueKey('placement-mascot'),
        dimension: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: 0,
              child: SizedBox(
                width: 0,
                height: 0,
                child: Stack(
                  children: [
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-stars'),
                      asset: 'assets/images/assessment-result-stars.png',
                      left: widget.size * 0.12,
                      top: 0,
                      dimension: widget.size * 0.76,
                      originOffset: Offset(0, widget.size * 0.075),
                      intervalStart: 0.05,
                    ),
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-numbers'),
                      asset: 'assets/images/assessment-result-numbers.png',
                      left: widget.size * 0.01,
                      top: widget.size * 0.43,
                      dimension: widget.size * 0.25,
                      originOffset: Offset(
                        widget.size * 0.07,
                        -widget.size * 0.015,
                      ),
                      intervalStart: 0.12,
                    ),
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-blocks'),
                      asset: 'assets/images/assessment-result-blocks.png',
                      left: widget.size * 0.035,
                      top: widget.size * 0.69,
                      dimension: widget.size * 0.25,
                      originOffset: Offset(
                        widget.size * 0.065,
                        -widget.size * 0.055,
                      ),
                      intervalStart: 0.2,
                    ),
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-checklist'),
                      asset: 'assets/images/assessment-result-checklist.png',
                      right: widget.size * 0.025,
                      top: widget.size * 0.43,
                      dimension: widget.size * 0.23,
                      originOffset: Offset(
                        -widget.size * 0.065,
                        -widget.size * 0.015,
                      ),
                      intervalStart: 0.16,
                    ),
                    _buildBurstAsset(
                      key: const ValueKey('placement-decoration-pencil'),
                      asset: 'assets/images/assessment-result-pencil.png',
                      right: 0,
                      top: widget.size * 0.7,
                      dimension: widget.size * 0.25,
                      originOffset: Offset(
                        -widget.size * 0.07,
                        -widget.size * 0.055,
                      ),
                      intervalStart: 0.24,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _mascotOffsetY.value),
                  child: Transform.scale(
                    scale: _mascotScale.value,
                    child: child,
                  ),
                ),
                child: Image.asset(
                  'assets/images/assessment-result-mascot.png',
                  key: const ValueKey('placement-mascot-character'),
                  fit: BoxFit.contain,
                  cacheWidth: 520,
                  cacheHeight: 520,
                  filterQuality: FilterQuality.high,
                  semanticLabel: context.getText(AppKeys.placementResultLevel),
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/numi-mascot.png',
                    fit: BoxFit.contain,
                    cacheWidth: 520,
                    cacheHeight: 520,
                    filterQuality: FilterQuality.high,
                    semanticLabel: context.getText(
                      AppKeys.placementResultLevel,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBurstAsset({
    required Key key,
    required String asset,
    required double top,
    required double dimension,
    required Offset originOffset,
    required double intervalStart,
    double? left,
    double? right,
  }) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(intervalStart, 0.82, curve: Curves.easeOutBack),
    );

    return Positioned(
      left: left,
      right: right,
      top: top,
      width: dimension,
      height: dimension,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final progress = animation.value;
            return Opacity(
              opacity: progress.clamp(0, 1),
              child: Transform.translate(
                offset: originOffset * (1 - progress),
                child: Transform.scale(
                  scale: 0.95 + (0.05 * progress),
                  child: child,
                ),
              ),
            );
          },
          child: Image.asset(
            asset,
            key: key,
            fit: BoxFit.contain,
            cacheWidth: 360,
            cacheHeight: 360,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _PlacementActionButton extends StatelessWidget {
  const _PlacementActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(14);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            color: outlined ? Colors.white : color,
            borderRadius: radius,
            border: outlined ? Border.all(color: color, width: 1.5) : null,
            boxShadow: outlined
                ? null
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: outlined ? color : colors.onBrand,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: GoogleFonts.andika(
                      color: outlined ? color : colors.onBrand,
                      fontSize: FontSize.normal,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
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
