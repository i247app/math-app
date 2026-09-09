import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/widgets/assessment_result/ai_review_card.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_result_review_text.dart';
import 'package:numi/features/exam/widgets/assessment_result/exit_to_grade_selection.dart';
import 'package:numi/features/exam/widgets/assessment_result/result_bottom_bar.dart';
import 'package:numi/features/exam/helpers/result_level_for_score.dart';
import 'package:numi/features/exam/widgets/assessment_result/score_out_of10.dart';
import 'package:numi/features/exam/widgets/assessment_result/score_ring.dart';
import 'package:numi/features/exam/widgets/assessment_result/test_again_loader.dart';
import 'package:numi/features/exam/widgets/shared/exam_header_icon_button.dart';
import 'package:numi/shared/layouts/page_header.dart';

class AssessmentResultScreen extends StatefulWidget {
  const AssessmentResultScreen({
    super.key,
    this.exam,
    this.examService,
    this.gradeLabel,
    this.profileId,
    this.onTestAgainGenerated,
    this.onBack,
  });

  final GeneratedExam? exam;
  final ExamService? examService;
  final String? gradeLabel;
  final int? profileId;
  final ValueChanged<GeneratedExam>? onTestAgainGenerated;
  final VoidCallback? onBack;

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  late final ExamService _examService;
  bool isGeneratingAgain = false;

  @override
  void initState() {
    super.initState();
    _examService = widget.examService ?? context.read<ExamService>();
  }

  Future<void> generateTestAgain() async {
    await generateAgain(
      purpose: examPurposeAssessment,
      typeOfExam: examTypeGeneral,
      gradeLabel: widget.gradeLabel,
    );
  }

  Future<void> generatePracticeAgain() async {
    final previousExamId = widget.exam?.examId;
    if (previousExamId == null) {
      HapticFeedback.selectionClick();
      showTestAgainError(
        AppStrings.current(AppKeys.testAgainCreateMissingExam),
      );
      return;
    }

    await generateAgain(
      purpose: examPurposePractice,
      typeOfExam: examTypeReinforcement,
      gradeLabel: widget.gradeLabel,
      previousExamId: previousExamId,
    );
  }

  Future<void> generateAgain({
    required String purpose,
    required String typeOfExam,
    String? gradeLabel,
    int? previousExamId,
  }) async {
    HapticFeedback.mediumImpact();
    setState(() => isGeneratingAgain = true);

    try {
      final generatedExam = await _examService.generateAssessmentExam(
        purpose: purpose,
        typeOfExam: typeOfExam,
        gradeLabel: gradeLabel,
        previousExamId: previousExamId,
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

      setState(() => isGeneratingAgain = false);
      showTestAgainError(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => isGeneratingAgain = false);
      showTestAgainError(AppStrings.current(AppKeys.testAgainCreateFailed));
    }
  }

  void showTestAgainError(String message) {
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

  void exitResult() {
    HapticFeedback.mediumImpact();
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }
    exitToGradeSelection(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colors.pageBackground,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: isGeneratingAgain
                  ? const AssessmentTestAgainLoader()
                  : _buildResultContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent(BuildContext context) {
    final grading = widget.exam?.grading;
    final score = scoreOutOf10(grading);
    final resultLevel = resultLevelForScore(score);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.getText(AppKeys.assessmentResultTitle),
            topInset: 0,
            actionWidth: 40,
            horizontalPadding: 20,
            titleFontSize: 25,
            leading: ExamHeaderIconButton(
              icon: Icons.arrow_back_rounded,
              color: context.themeColors.brandStrong,
              size: 40,
              iconSize: 23,
              borderRadius: 12,
              onTap: exitResult,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 51),
            child: AssessmentScoreRing(
              scoreText: '$score/10',
              accentColor: resultLevel.color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              context.getText(resultLevel.titleKey),
              textAlign: TextAlign.center,
              style: GoogleFonts.andika(
                color: resultLevel.color,
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w800,
                height: 32 / 24,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 52, 26, 0),
            child: AssessmentAiReviewCard(
              reviewText: assessmentResultReviewText(grading),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 62, 26, 24),
            child: AssessmentResultBottomBar(
              onTest: generateTestAgain,
              onPractice: generatePracticeAgain,
            ),
          ),
        ],
      ),
    );
  }
}
