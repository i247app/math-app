import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/data/cache/quiz_cache.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/errors/quiz_exception.dart';
import 'package:numi/features/quiz/widgets/assessment_result/ai_review_card.dart';
import 'package:numi/features/quiz/widgets/assessment_result/assessment_result_review_text.dart';
import 'package:numi/features/quiz/widgets/assessment_result/exit_to_grade_selection.dart';
import 'package:numi/features/quiz/widgets/assessment_result/result_bottom_bar.dart';
import 'package:numi/features/quiz/widgets/assessment_result/result_header.dart';
import 'package:numi/features/quiz/helpers/result_level_for_score.dart';
import 'package:numi/features/quiz/widgets/assessment_result/score_out_of10.dart';
import 'package:numi/features/quiz/widgets/assessment_result/score_ring.dart';
import 'package:numi/features/quiz/widgets/assessment_result/test_again_loader.dart';

class AssessmentResultScreen extends StatefulWidget {
  const AssessmentResultScreen({
    super.key,
    this.quiz,
    this.quizService,
    this.profileId,
    this.onTestAgainGenerated,
    this.onBack,
  });

  final GeneratedQuiz? quiz;
  final QuizService? quizService;
  final int? profileId;
  final ValueChanged<GeneratedQuiz>? onTestAgainGenerated;
  final VoidCallback? onBack;

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  late final QuizService _quizService;
  bool isGeneratingAgain = false;

  @override
  void initState() {
    super.initState();
    _quizService = widget.quizService ?? QuizApi();
  }

  Future<void> generateTestAgain() async {
    await generateAgain(
      purpose: quizPurposeAssessment,
      typeOfQuiz: quizTypeGeneral,
      gradeLabel: assessmentQuizGradeLabel,
    );
  }

  Future<void> generatePracticeAgain() async {
    final previousQuizId = widget.quiz?.quizId;
    if (previousQuizId == null) {
      HapticFeedback.selectionClick();
      showTestAgainError(
        AppStrings.current(AppKeys.testAgainCreateMissingQuiz),
      );
      return;
    }

    await generateAgain(
      purpose: quizPurposeAssessment,
      typeOfQuiz: quizTypeReinforcement,
      previousQuizId: previousQuizId,
    );
  }

  Future<void> generateAgain({
    required String purpose,
    required String typeOfQuiz,
    String? gradeLabel,
    int? previousQuizId,
  }) async {
    HapticFeedback.mediumImpact();
    setState(() => isGeneratingAgain = true);

    try {
      final generatedQuiz = await _quizService.generateAssessmentQuiz(
        purpose: purpose,
        typeOfQuiz: typeOfQuiz,
        gradeLabel: gradeLabel,
        previousQuizId: previousQuizId,
        profileId: widget.profileId,
      );
      if (!mounted) {
        return;
      }
      QuizCache.seedDetail(generatedQuiz);

      final onGenerated = widget.onTestAgainGenerated;
      if (onGenerated != null) {
        onGenerated(generatedQuiz);
      } else {
        Navigator.of(context).pop(generatedQuiz);
      }
    } on QuizException catch (error) {
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
          child: Center(
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
    final grading = widget.quiz?.grading;
    final score = scoreOutOf10(grading);
    final resultLevel = resultLevelForScore(score);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AssessmentResultHeader(onBack: exitResult),
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
                fontSize: 24,
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
