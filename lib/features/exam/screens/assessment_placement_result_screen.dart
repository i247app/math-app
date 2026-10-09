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
import 'package:numi/features/exam/controllers/placement_result_controller.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/exam_practice_topic_formatter.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/placement_result_config.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_grade_ribbon.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/exam/widgets/assessment_result/exit_to_grade_selection.dart';
import 'package:numi/features/exam/widgets/assessment_result/grade_exam_level_ribbon.dart';
import 'package:numi/features/exam/widgets/assessment_result/placement_action_button.dart';
import 'package:numi/features/exam/widgets/assessment_result/placement_celebration_mascot.dart';
import 'package:numi/features/exam/widgets/assessment_result/placement_grade_title.dart';
import 'package:numi/features/exam/widgets/assessment_result/placement_weak_topics_dropdown.dart';
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
  late final PlacementResultController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlacementResultController(
      examService: widget.examService ?? context.read<ExamService>(),
      grade: widget.grade,
      level: widget.level,
      correctAnswers: widget.correctAnswers,
      totalQuestions: widget.totalQuestions,
      examType: widget.examType,
      profileId: widget.profileId,
      userExamId: widget.userExamId,
      previousGrade: widget.previousGrade,
    )..addListener(_handleStateChanged);
    _controller.initialize();
  }

  void _handleStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateNextExam() async {
    HapticFeedback.mediumImpact();
    try {
      final generatedExam = await _controller.generateNextExam();
      if (!mounted || generatedExam == null) return;
      final onGenerated = widget.onTestAgainGenerated;
      if (onGenerated != null) {
        onGenerated(generatedExam);
      } else {
        Navigator.of(context).pop(generatedExam);
      }
    } on ExamException catch (error) {
      if (mounted) _showGenerationError(error.message);
    } catch (_) {
      if (mounted) {
        _showGenerationError(AppStrings.current(AppKeys.testAgainCreateFailed));
      }
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
    if (_controller.state.isGenerating) {
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
              child: _controller.state.isGenerating
                  ? const AssessmentTestAgainLoader()
                  : !_controller.state.progressResolved
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
    final config = _controller.config;
    final chart = _controller.state.chart;
    final generationAction = config.generationAction;
    final resultSummary = context.formatText(
      AppKeys.placementResultCorrectSummary,
      {
        'correct': _controller.correctAnswers,
        'total': _controller.totalQuestions,
      },
    );
    final weakTopics = examPracticeTopicNames(widget.practiceWeakTopics);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = constraints.maxHeight;
        final isCompact = viewportHeight <= 740;
        final isVeryCompact = viewportHeight <= 600;
        final mascotSize = isCompact
            ? (viewportHeight * 0.12).clamp(76.0, 92.0)
            : (viewportHeight * 0.15).clamp(104.0, 124.0);
        final sectionSpacing = isVeryCompact ? 4.0 : (isCompact ? 6.0 : 10.0);

        return SingleChildScrollView(
          key: const ValueKey('assessment-placement-result'),
          physics: const BouncingScrollPhysics(),
          child: Semantics(
            label: resultSummary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  scale: 0.9,
                  title: config.headerTitleKey == null
                      ? null
                      : context.getText(config.headerTitleKey!),
                  topInset: 0,
                  backgroundColor: Colors.white,
                  actionWidth: 44,
                  horizontalPadding: 16,
                  trailing: Align(
                    alignment: Alignment.centerRight,
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
                SizedBox(height: isCompact ? 2.0 : 6.0),
                Text(
                  context.getText(config.headingKey),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF04A8B3),
                    fontSize: FontSize.xxl,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(
                  height: isVeryCompact ? 4.0 : (isCompact ? 8.0 : 10.0),
                ),
                PlacementGradeTitle(
                  grade: _controller.state.grade,
                  compact: isCompact,
                ),
                if (widget.level case final level?) ...[
                  const SizedBox(height: 6),
                  Text(
                    context.formatText(AppKeys.placementResultGradeLevel, {
                      'level': level,
                    }),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: colors.brandStrong,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
                if (!isVeryCompact) ...[
                  SizedBox(height: isCompact ? 2.0 : 4.0),
                  PlacementCelebrationMascot(size: mascotSize),
                  SizedBox(height: isCompact ? 2.0 : 4.0),
                ],
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
                        child: config.ribbon == PlacementResultRibbon.gradeLevel
                            ? GradeExamLevelRibbon(
                                currentLevel: widget.level ?? 0,
                              )
                            : AssessmentGradeRibbon(
                                currentGrade: _controller.state.grade,
                              ),
                      ),
                      if (config.showsAssessmentChart) ...[
                        SizedBox(height: sectionSpacing),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AssessmentProgressionChart(
                            finalGrade: _controller.state.grade,
                            previousGrades: chart.previousGrades,
                            testNumbers: chart.testNumbers,
                            firstTestNumber: chart.firstTestNumber,
                            lastSubmittedAt: chart.lastSubmittedAt,
                            chartHeight: isCompact ? 90.0 : 115.0,
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
                    child: PlacementWeakTopicsDropdown(
                      topics: weakTopics,
                      maxExpandedHeight: viewportHeight * 0.25,
                    ),
                  ),
                ],
                SizedBox(height: sectionSpacing),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: generationAction != null
                                ? double.infinity
                                : 220,
                            child: PlacementActionButton(
                              key: const ValueKey('placement-view-details'),
                              label: context.getText(
                                AppKeys.placementResultReview,
                              ),
                              icon: Icons.assignment_outlined,
                              color: AppColors.resultCoral,
                              outlined: true,
                              onTap: _viewDetails,
                            ),
                          ),
                        ),
                      ),
                      if (generationAction != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: PlacementActionButton(
                            key: const ValueKey('placement-continue-grade'),
                            label: context.getText(generationAction.labelKey),
                            icon: Icons.arrow_forward_rounded,
                            color: AppColors.teal500,
                            onTap: _generateNextExam,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  height: isVeryCompact ? 4.0 : (isCompact ? 10.0 : 16.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
