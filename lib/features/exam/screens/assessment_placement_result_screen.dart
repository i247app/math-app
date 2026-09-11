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
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/assessment_result/exit_to_grade_selection.dart';
import 'package:numi/features/exam/widgets/assessment_result/test_again_loader.dart';
import 'package:numi/features/exam/widgets/shared/exam_header_icon_button.dart';
import 'package:numi/shared/layouts/page_header.dart';

class AssessmentPlacementResultScreen extends StatefulWidget {
  const AssessmentPlacementResultScreen({
    super.key,
    required this.grade,
    required this.correctAnswers,
    required this.totalQuestions,
    this.examService,
    this.profileId,
    this.onTestAgainGenerated,
    this.onViewDetails,
    this.onBack,
  });

  final int grade;
  final int correctAnswers;
  final int totalQuestions;
  final ExamService? examService;
  final int? profileId;
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

  int get _grade => AssessmentFlowPolicy.clampGrade(widget.grade);
  int get _totalQuestions => widget.totalQuestions.clamp(0, 1000000);
  int get _correctAnswers => widget.correctAnswers.clamp(0, _totalQuestions);

  @override
  void initState() {
    super.initState();
    _examService = widget.examService ?? context.read<ExamService>();
  }

  Future<void> _generateAgain(String examType) async {
    HapticFeedback.mediumImpact();
    setState(() => _isGeneratingAgain = true);

    try {
      final generatedExam = await _examService.generateAssessmentExam(
        examType: examType,
        gradeLabel: AssessmentFlowPolicy.gradeLabel(_grade),
        profileId: widget.profileId,
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
                  : _buildResultContent(context),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = constraints.maxHeight;
        final topSpacing = (viewportHeight * 0.075).clamp(36.0, 62.0);
        final mascotSize = (viewportHeight * 0.40).clamp(250.0, 330.0);
        final actionSpacing = (viewportHeight * 0.06).clamp(28.0, 50.0);

        return SingleChildScrollView(
          key: const ValueKey('assessment-placement-result'),
          physics: const BouncingScrollPhysics(),
          child: Semantics(
            label: resultSummary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: context.getText(AppKeys.assessmentResultTitle),
                  topInset: 0,
                  backgroundColor: Colors.white,
                  actionWidth: 40,
                  horizontalPadding: 14,
                  titleFontSize: FontSize.xl,
                  leading: Align(
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.border),
                      ),
                      child: ExamHeaderIconButton(
                        icon: Icons.close_rounded,
                        color: colors.brandStrong,
                        size: 36,
                        iconSize: 24,
                        circle: true,
                        onTap: _exitResult,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: topSpacing),
                Text(
                  context.getText(AppKeys.placementResultLevel),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.andika(
                    color: colors.brandStrong,
                    fontSize: FontSize.xl,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                _PlacementGradeTitle(grade: _grade),
                const SizedBox(height: 18),
                _CelebrationMascot(size: mascotSize),
                SizedBox(height: actionSpacing),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
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
                            AppKeys.placementResultPracticeAgain,
                          ),
                          icon: Icons.sync_rounded,
                          color: AppColors.teal500,
                          onTap: () => _generateAgain(examTypePractice),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
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
    final firstPart = separatorIndex < 0
        ? label
        : label.substring(0, separatorIndex + 1);
    final secondPart = separatorIndex < 0
        ? ''
        : label.substring(separatorIndex + 1);
    final textStyle = GoogleFonts.andika(
      fontSize: 44,
      fontWeight: FontWeight.w900,
      height: 1.08,
      letterSpacing: 1.2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: firstPart,
                style: textStyle.copyWith(color: AppColors.teal600),
              ),
              if (secondPart.isNotEmpty)
                TextSpan(
                  text: secondPart,
                  style: textStyle.copyWith(color: AppColors.coral600),
                ),
            ],
            style: textStyle,
          ),
          key: const ValueKey('placement-grade'),
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }
}

class _CelebrationMascot extends StatelessWidget {
  const _CelebrationMascot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        key: const ValueKey('placement-mascot'),
        dimension: size,
        child: Image.asset(
          'assets/images/assessment-placement-mascot.png',
          fit: BoxFit.contain,
          cacheWidth: 660,
          cacheHeight: 660,
          filterQuality: FilterQuality.high,
          semanticLabel: context.getText(AppKeys.placementResultLevel),
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
