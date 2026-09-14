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
import 'package:numi/features/exam/data/pending_assessment_completion_store.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/assessment_journey_completion.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/assessment_result/exit_to_grade_selection.dart';
import 'package:numi/features/exam/widgets/assessment_result/result_action_button.dart';
import 'package:numi/features/exam/widgets/assessment_result/score_ring.dart';
import 'package:numi/features/exam/widgets/assessment_result/test_again_loader.dart';
import 'package:numi/features/exam/widgets/shared/exam_header_icon_button.dart';
import 'package:numi/shared/layouts/page_header.dart';

class PracticeResultScreen extends StatefulWidget {
  const PracticeResultScreen({
    super.key,
    required this.grade,
    required this.correctAnswers,
    required this.totalQuestions,
    this.examService,
    this.profileId,
    this.userExamId,
    this.pendingCompletionStore,
    this.onPracticeAgainGenerated,
    this.onViewDetails,
    this.onBack,
  });

  final int grade;
  final int correctAnswers;
  final int totalQuestions;
  final ExamService? examService;
  final int? profileId;
  final int? userExamId;
  final PendingAssessmentCompletionStore? pendingCompletionStore;
  final ValueChanged<GeneratedExam>? onPracticeAgainGenerated;
  final VoidCallback? onViewDetails;
  final VoidCallback? onBack;

  @override
  State<PracticeResultScreen> createState() => _PracticeResultScreenState();
}

class _PracticeResultScreenState extends State<PracticeResultScreen> {
  late final ExamService _examService;
  late final PendingAssessmentCompletionStore _pendingCompletionStore;
  bool _isGeneratingAgain = false;
  bool _isCompletingJourney = false;

  int get _grade => AssessmentFlowPolicy.clampGrade(widget.grade);
  int get _totalQuestions => widget.totalQuestions.clamp(0, 1000000);
  int get _correctAnswers => widget.correctAnswers.clamp(0, _totalQuestions);

  @override
  void initState() {
    super.initState();
    _examService = widget.examService ?? context.read<ExamService>();
    _pendingCompletionStore =
        widget.pendingCompletionStore ??
        const SecurePendingAssessmentCompletionStore();
  }

  Future<void> _generatePracticeAgain() async {
    if (_isGeneratingAgain) {
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isGeneratingAgain = true);

    try {
      final generatedExam = await _examService.generateAssessmentExam(
        examType: examTypePractice,
        gradeLabel: AssessmentFlowPolicy.gradeLabel(_grade),
        profileId: widget.profileId,
        userExamId: widget.userExamId,
      );
      if (!mounted) {
        return;
      }
      ExamCache.seedDetail(generatedExam);
      final onGenerated = widget.onPracticeAgainGenerated;
      if (onGenerated != null) {
        onGenerated(generatedExam);
      } else {
        Navigator.of(context).pop(generatedExam);
      }
    } on ExamException catch (error) {
      _handleGenerationFailure(error.message);
    } catch (_) {
      _handleGenerationFailure(
        AppStrings.current(AppKeys.testAgainCreateFailed),
      );
    }
  }

  void _handleGenerationFailure(String message) {
    if (!mounted) {
      return;
    }
    setState(() => _isGeneratingAgain = false);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.getText(AppKeys.testAgainDialogTitle)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.getText(AppKeys.close)),
          ),
        ],
      ),
    );
  }

  Future<void> _exitResult() async {
    if (_isGeneratingAgain || _isCompletingJourney) {
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isCompletingJourney = true);
    try {
      await completeAssessmentJourney(
        examService: _examService,
        completionStore: _pendingCompletionStore,
        userExamId: widget.userExamId,
        profileId: widget.profileId,
      );
    } on ExamException catch (error) {
      _handleCompletionFailure(error.message);
      return;
    } catch (_) {
      _handleCompletionFailure(
        AppStrings.current(AppKeys.assessmentStatusUpdateFailed),
      );
      return;
    }
    if (!mounted) {
      return;
    }
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }
    exitToGradeSelection(context);
  }

  void _handleCompletionFailure(String message) {
    if (!mounted) {
      return;
    }
    setState(() => _isCompletingJourney = false);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.getText(AppKeys.assessmentResultTitle)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.getText(AppKeys.close)),
          ),
        ],
      ),
    );
  }

  void _viewDetails() {
    HapticFeedback.selectionClick();
    widget.onViewDetails?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colors.pageBackground,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _isGeneratingAgain || _isCompletingJourney
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: context.getText(AppKeys.assessmentResultTitle),
          topInset: 0,
          actionWidth: 40,
          horizontalPadding: 20,
          titleFontSize: 25,
          leading: ExamHeaderIconButton(
            key: const ValueKey('practice-result-close'),
            icon: Icons.close_rounded,
            color: colors.brandStrong,
            size: 40,
            iconSize: 23,
            borderRadius: 20,
            onTap: _exitResult,
          ),
        ),
        const Spacer(flex: 2),
        AssessmentScoreRing(
          scoreText: '$_correctAnswers/$_totalQuestions',
          accentColor: AppColors.teal500,
        ),
        const SizedBox(height: 12),
        Text(
          context.getText(AppKeys.correct),
          textAlign: TextAlign.center,
          style: GoogleFonts.andika(
            color: colors.brandStrong,
            fontSize: FontSize.xxxl,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(flex: 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 28),
          child: Row(
            children: [
              Expanded(
                child: AssessmentResultActionButton(
                  label: context.getText(AppKeys.placementResultViewDetails),
                  icon: Icons.assignment_outlined,
                  background: AppColors.resultCoral,
                  onTap: _viewDetails,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AssessmentResultActionButton(
                  label: context.getText(AppKeys.placementResultPracticeAgain),
                  icon: Icons.sync_rounded,
                  background: AppColors.teal500,
                  onTap: _generatePracticeAgain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
