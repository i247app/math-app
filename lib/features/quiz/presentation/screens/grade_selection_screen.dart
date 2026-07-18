import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/quiz/data/ai_shake_service.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/presentation/screens/assessment_screen.dart';
import 'package:numi/features/quiz/helpers/default_grade_label.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_background.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_bottom_bar.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_failure_notice.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_grid.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_header.dart';
import 'package:numi/features/quiz/widgets/grade_selection/grade_option.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class GradeSelectionScreen extends StatefulWidget {
  const GradeSelectionScreen({
    super.key,
    this.user,
    this.initialGrades = const <GradeModel>[],
    this.gradeService,
    this.quizPurpose = quizPurposeAssessment,
    this.profileId,
    this.initialGradeId,
    this.initialGradeLabel,
    this.onResultBack,
  });

  final LoginUser? user;
  final List<GradeModel> initialGrades;
  final GradeService? gradeService;
  final String quizPurpose;
  final int? profileId;
  final int? initialGradeId;
  final String? initialGradeLabel;
  final VoidCallback? onResultBack;

  @override
  State<GradeSelectionScreen> createState() => _GradeSelectionScreenState();
}

class _GradeSelectionScreenState extends State<GradeSelectionScreen> {
  late final GradeService _gradeService;
  bool showGenerationFailed = false;
  bool isLoadingGrades = false;
  String? gradeLoadError;
  List<GradeModel> grades = const <GradeModel>[];
  String? selectedGradeLabel;

  @override
  void initState() {
    super.initState();
    _gradeService = widget.gradeService ?? GradeApi();
    grades = widget.initialGrades;
    selectedGradeLabel = _initialSelectedGradeLabel(grades);
    if (widget.quizPurpose == quizPurposeAssessment) {
      unawaited(AIShakeService.shared.aiShake());
    }
    if (grades.isEmpty) {
      loadGrades();
    }
  }

  Future<void> loadGrades() async {
    final userId = widget.user?.id;
    if (userId == null || userId <= 0) {
      setState(() {
        isLoadingGrades = false;
        gradeLoadError = AppStrings.current(AppKeys.noAccountForGrades);
        grades = const <GradeModel>[];
      });
      return;
    }

    setState(() {
      isLoadingGrades = true;
      gradeLoadError = null;
    });

    try {
      final loadedGrades = await _gradeService.listGrades(userId: userId);
      if (!mounted) {
        return;
      }

      setState(() {
        grades = loadedGrades;
        isLoadingGrades = false;
        if (!loadedGrades.any(
          (grade) => grade.label?.trim() == selectedGradeLabel,
        )) {
          selectedGradeLabel = _initialSelectedGradeLabel(loadedGrades);
        }
      });
    } on GradeException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        gradeLoadError = error.message;
        isLoadingGrades = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        gradeLoadError = AppStrings.current(AppKeys.gradeLoadFailed);
        isLoadingGrades = false;
      });
    }
  }

  Future<void> openAssessment({String? gradeLabel}) async {
    HapticFeedback.mediumImpact();
    if (showGenerationFailed) {
      setState(() => showGenerationFailed = false);
    }

    final result = await Navigator.of(context).push<AiAssessmentResult>(
      MaterialPageRoute<AiAssessmentResult>(
        builder: (_) => AiAssessmentScreen(
          purpose: widget.quizPurpose,
          typeOfQuiz: quizTypeGeneral,
          gradeLabel: gradeLabel,
          profileId: widget.profileId,
          onResultBack: widget.onResultBack,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == AiAssessmentResult.generationFailed) {
      setState(() => showGenerationFailed = true);
      return;
    }

    setState(() {
      showGenerationFailed = false;
      selectedGradeLabel = _initialSelectedGradeLabel(grades);
    });
  }

  String? _initialSelectedGradeLabel(List<GradeModel> grades) {
    if (widget.quizPurpose == quizPurposeAssessment) {
      return null;
    }
    return defaultGradeLabel(
      grades,
      preferredGradeId: widget.initialGradeId,
      preferredGradeLabel: widget.initialGradeLabel,
    );
  }

  void selectGrade(GradeOption option) {
    HapticFeedback.selectionClick();
    setState(() => selectedGradeLabel = option.label);
  }

  void continueWithSelectedGrade() {
    final gradeLabel = selectedGradeLabel;
    if (gradeLabel == null || gradeLabel.isEmpty) {
      HapticFeedback.selectionClick();
      return;
    }

    openAssessment(gradeLabel: gradeLabel);
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
              child: Stack(
                children: [
                  const Positioned.fill(child: GradeBackground()),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(38, 132, 38, 128),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.getText(AppKeys.gradeQuestionTitle),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                              height: 1.08,
                              letterSpacing: 0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 26),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: showGenerationFailed
                                  ? const Padding(
                                      key: ValueKey('generate-failed-notice'),
                                      padding: EdgeInsets.only(top: 18),
                                      child: GradeFailureNotice(),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          GradeGrid(
                            grades: grades,
                            selectedGradeLabel: selectedGradeLabel,
                            isLoading: isLoadingGrades,
                            errorMessage: gradeLoadError,
                            onSelected: selectGrade,
                            onRetry: loadGrades,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: GradeHeader(),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: GradeBottomBar(
                      onSkip: openAssessment,
                      onContinue: continueWithSelectedGrade,
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
