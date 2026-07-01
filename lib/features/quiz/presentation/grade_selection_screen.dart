import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/quiz/ai_shake_service.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/assessment_screen.dart';

part '../widgets/grade_selection/grade_failure_notice.dart';
part '../widgets/grade_selection/grade_background.dart';
part '../widgets/grade_selection/grade_header.dart';
part '../widgets/grade_selection/grade_grid.dart';
part '../widgets/grade_selection/grade_load_state.dart';
part '../widgets/grade_selection/grade_skeleton_card.dart';
part '../widgets/grade_selection/grade_load_error.dart';
part '../widgets/grade_selection/grade_card.dart';
part '../widgets/grade_selection/grade_badge.dart';
part '../widgets/grade_selection/grade_bottom_bar.dart';
part '../widgets/grade_selection/pill_action_button.dart';
part '../widgets/grade_selection/grade_option.dart';
part '../widgets/grade_selection/grade_number_from_label.dart';
part '../widgets/grade_selection/default_grade_label.dart';

const _gradeMint = Color(0xFFEBFAEC);
const _gradeTeal = Color(0xFF006762);
const _gradeInk = Color(0xFF253228);
const _gradePeach = Color(0xFFFFDCCA);
const _gradeRust = Color(0xFFA03A0F);

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

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

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
    return _defaultGradeLabel(
      grades,
      preferredGradeId: widget.initialGradeId,
      preferredGradeLabel: widget.initialGradeLabel,
    );
  }

  void selectGrade(_GradeOption option) {
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _gradeMint,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = math.min(constraints.maxWidth, 430.0);
              final height = constraints.maxHeight;
              final scale = math.min(
                width / GradeSelectionScreen._designWidth,
                height / GradeSelectionScreen._designHeight,
              );

              double s(double value) => value * scale;

              return Center(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      const Positioned.fill(child: _GradeBackground()),
                      Positioned.fill(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            s(38),
                            s(132),
                            s(38),
                            s(128),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                context.getText(AppKeys.gradeQuestionTitle),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _gradeInk,
                                  fontSize: s(31),
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                  letterSpacing: 0,
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: showGenerationFailed
                                    ? Padding(
                                        key: const ValueKey(
                                          'generate-failed-notice',
                                        ),
                                        padding: EdgeInsets.only(top: s(18)),
                                        child: _GradeFailureNotice(
                                          scale: scale,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              SizedBox(height: s(26)),
                              _GradeGrid(
                                scale: scale,
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
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: _GradeHeader(scale: scale),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _GradeBottomBar(
                          scale: scale,
                          onSkip: openAssessment,
                          onContinue: continueWithSelectedGrade,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
