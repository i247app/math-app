import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/controllers/assessment_controller.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/screens/assessment_placement_result_screen.dart';
import 'package:numi/features/exam/screens/exam_review_entry_screen.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_grid.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_bottom_bar.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_error_state.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_generating_loader.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_header.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_progress_section.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_question_card.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_question_skeleton.dart';
import 'package:numi/features/exam/widgets/shared/attempt_exit_dialog.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

enum AiAssessmentResult { generationFailed }

class AiAssessmentScreen extends StatefulWidget {
  const AiAssessmentScreen({
    super.key,
    this.examService,
    this.initialExam,
    this.examType = examTypeAssessment,
    this.gradeLabel,
    this.profileId,
    this.startAtKindergarten = true,
    this.onResultBack,
    this.allowQuestionNavigation = true,
    this.showQuestionNavigation = true,
  });

  final ExamService? examService;
  final GeneratedExam? initialExam;
  final String examType;
  final String? gradeLabel;
  final int? profileId;

  /// Direct placement starts at grade 0; explicit grade-selection can opt out.
  final bool startAtKindergarten;
  final VoidCallback? onResultBack;
  final bool allowQuestionNavigation;
  final bool showQuestionNavigation;

  @override
  State<AiAssessmentScreen> createState() => _AiAssessmentScreenState();
}

class _AiAssessmentScreenState extends State<AiAssessmentScreen> {
  late final AssessmentController _controller;
  final GuardedExitController<AiAssessmentResult> _exitController =
      GuardedExitController<AiAssessmentResult>();

  @override
  void initState() {
    super.initState();
    _controller = AssessmentController(
      examService: widget.examService ?? context.read<ExamService>(),
      initialExam: widget.initialExam,
      examType: widget.examType,
      gradeLabel: widget.gradeLabel,
      profileId: widget.profileId,
      startAtKindergarten: widget.startAtKindergarten,
    );
    if (widget.initialExam == null) {
      generateExam();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> generateExam() async {
    final generated = await _controller.generateExam();
    if (!mounted || generated) {
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(AiAssessmentResult.generationFailed);
    }
  }

  void selectAnswer(ExamAnswer answer) {
    HapticFeedback.selectionClick();
    _controller.selectAnswer(answer);
    _advanceFlowAfterAnswer();
  }

  void _advanceFlowAfterAnswer() {
    final action = _controller.prepareAssessmentFlow();
    if (action != AssessmentFlowAction.submit) {
      return;
    }
    unawaited(submitCurrentExam());
  }

  void goToPreviousQuestion() {
    HapticFeedback.selectionClick();
    _controller.goToPreviousQuestion();
  }

  void goToQuestion(int index) {
    final moved = _controller.goToQuestion(index);
    if (moved) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void goToNextQuestion() {
    unawaited(_goToNextQuestion());
  }

  Future<void> _goToNextQuestion() async {
    if (!_controller.isAssessment) {
      if (_controller.allQuestionsAnswered) {
        await submitCurrentExam();
        return;
      }
      HapticFeedback.mediumImpact();
      _moveToNextQuestion();
      return;
    }

    HapticFeedback.mediumImpact();
    final action = await _controller.advanceAssessmentFlow();
    if (!mounted) {
      return;
    }
    if (action == AssessmentFlowAction.submit) {
      await submitCurrentExam();
      return;
    }
    if (action == AssessmentFlowAction.generateSet) {
      return;
    }
    _moveToNextQuestion();
  }

  bool _moveToNextQuestion() {
    if (!_controller.isLastQuestion) {
      return _controller.goToNextQuestion();
    }

    final firstUnansweredIndex = _controller.firstUnansweredQuestionIndex;
    return firstUnansweredIndex != null &&
        _controller.goToQuestion(firstUnansweredIndex);
  }

  Future<void> submitCurrentExam() async {
    HapticFeedback.mediumImpact();
    final result = await _controller.submitCurrentExam();
    if (!mounted || result.status != AssessmentSubmitStatus.submitted) {
      if (result.status == AssessmentSubmitStatus.unanswered) {
        HapticFeedback.selectionClick();
      }
      return;
    }

    final navigator = Navigator.of(context);
    final examService = _controller.examService;
    final fallbackExamType = widget.examType;
    final finalGrade = _controller.currentGrade;
    final gradeLabel = _controller.currentGradeLabel;
    final correctAnswers = _controller.totalCorrectAnswerCount;
    final totalQuestions = _controller.totalAnsweredQuestionCount;
    final profileId = widget.profileId;
    final onResultBack = widget.onResultBack;
    final allowQuestionNavigation = widget.allowQuestionNavigation;
    final showQuestionNavigation = widget.showQuestionNavigation;
    final submittedExam = result.exam!;
    final submittedUserExamId = submittedExam.userExamId;
    final submittedExamId = submittedExam.examId ?? submittedExam.userAiExamId;
    final reviewDetailId = submittedUserExamId ?? submittedExamId;

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (resultContext) {
          return AssessmentPlacementResultScreen(
            grade: finalGrade,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            examService: examService,
            profileId: profileId,
            onViewDetails: reviewDetailId == null
                ? null
                : () {
                    Navigator.of(resultContext).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RepositoryProvider<ExamService>.value(
                          value: examService,
                          child: ExamReviewScreen(
                            examId: submittedUserExamId == null
                                ? submittedExamId
                                : null,
                            userExamId: submittedUserExamId,
                            profileId: profileId ?? submittedExam.profileId,
                            initialExam: submittedUserExamId == null
                                ? submittedExam
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
            onTestAgainGenerated: (generatedExam) {
              Navigator.of(resultContext).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => AiAssessmentScreen(
                    examService: examService,
                    initialExam: generatedExam,
                    examType: generatedExam.examType ?? fallbackExamType,
                    gradeLabel: gradeLabel,
                    profileId: profileId,
                    onResultBack: onResultBack,
                    allowQuestionNavigation: allowQuestionNavigation,
                    showQuestionNavigation: showQuestionNavigation,
                  ),
                ),
              );
            },
            onBack: onResultBack,
          );
        },
      ),
    );
  }

  Future<void> retryErrorAction() {
    return switch (_controller.errorRetryAction) {
      AssessmentRetryAction.submit => submitCurrentExam(),
      _ => retryGeneration(),
    };
  }

  Future<void> retryGeneration() async {
    final isInitialGeneration = _controller.exam == null;
    final generated = await _controller.retryGeneration();
    if (!mounted || generated || !isInitialGeneration) {
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(AiAssessmentResult.generationFailed);
    }
  }

  Future<bool> showUnansweredSubmitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final colors = context.themeColors;
        return AlertDialog(
          backgroundColor: colors.elevatedSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            context.getText(AppKeys.unansweredSubmitTitle),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          content: Text(
            context.getText(AppKeys.unansweredSubmitMessage),
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                context.getText(AppKeys.stayUpper),
                style: TextStyle(
                  color: colors.accentStrong,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.brandStrong,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                context.getText(AppKeys.submitUpper),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final currentExam = _controller.exam;
          final questions = currentExam?.questions ?? const <ExamQuestion>[];
          final currentQuestion = _controller.currentQuestion;
          final errorMessage = _controller.errorMessage;
          final isGeneratingQuestion = _controller.isGeneratingQuestion;
          final isTransitioningSet = _controller.isTransitioningSet;
          final isSubmittingExam = _controller.isSubmittingExam;
          final hasActiveAttempt = questions.isNotEmpty;
          final isBusy =
              isGeneratingQuestion || isTransitioningSet || isSubmittingExam;
          final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
          final backgroundColor = colors.surface;

          final screen = Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: errorMessage != null
                        ? Column(
                            key: const ValueKey('question-error-layout'),
                            children: [
                              AssessmentHeader(
                                onClose: _exitController.requestExit,
                              ),
                              Expanded(
                                child: AssessmentErrorState(
                                  key: const ValueKey('question-error'),
                                  message: errorMessage,
                                  onRetry: retryErrorAction,
                                ),
                              ),
                            ],
                          )
                        : isSubmittingExam
                        ? AssessmentGeneratingLoader(
                            key: const ValueKey('submit-loader'),
                            message: context.getText(AppKeys.submittingForYou),
                          )
                        : isGeneratingQuestion
                        ? AssessmentGeneratingLoader(
                            key: const ValueKey('question-loader'),
                            message: context.getText(
                              AppKeys.generatingAssessment,
                            ),
                          )
                        : SizedBox.expand(
                            key: const ValueKey('question-content-layout'),
                            child: KeyedSubtree(
                              key: ValueKey(
                                'assessment-question-${_controller.displayedQuestionNumber}-$isTransitioningSet',
                              ),
                              child: CustomScrollView(
                                key: const ValueKey('question-content'),
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: AssessmentHeader(
                                      onClose: _exitController.requestExit,
                                    ),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    sliver: SliverList.list(
                                      children: [
                                        AssessmentProgressSection(
                                          currentQuestion:
                                              _controller.progressQuestionIndex,
                                          questionNumberOffset: _controller
                                              .progressQuestionNumberOffset,
                                          totalQuestions: questions.length,
                                          answeredQuestionIndexes:
                                              isTransitioningSet
                                              ? const <int>{}
                                              : _controller
                                                    .selectedAnswerLabels
                                                    .keys
                                                    .toSet(),
                                          onQuestionSelected:
                                              widget.allowQuestionNavigation &&
                                                  !isTransitioningSet
                                              ? goToQuestion
                                              : null,
                                          showQuestionNavigation:
                                              widget.showQuestionNavigation,
                                        ),
                                        const SizedBox(height: 16),
                                        if (isTransitioningSet)
                                          const AssessmentQuestionSkeleton()
                                        else ...[
                                          AssessmentQuestionCard(
                                            question:
                                                currentQuestion!.questionName,
                                          ),
                                          const SizedBox(height: 32),
                                          AssessmentAnswerGrid(
                                            answers: currentQuestion.answers,
                                            selectedAnswerLabel:
                                                _controller.selectedAnswerLabel,
                                            onSelected: selectAnswer,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: AssessmentBottomBar(
                                        bottomInset: bottomInset,
                                        canGoBack:
                                            _controller.questionIndex > 0,
                                        allQuestionsAnswered:
                                            _controller.allQuestionsAnswered &&
                                            !_controller.isAssessment,
                                        isSubmitting: isSubmittingExam,
                                        isTransitioning: isTransitioningSet,
                                        onBack: goToPreviousQuestion,
                                        onContinue: goToNextQuestion,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );

          return GuardedExitScope<AiAssessmentResult>(
            controller: _exitController,
            shouldConfirm: hasActiveAttempt,
            isExitBlocked: isBusy,
            confirmExit: showAttemptExitDialog,
            child: screen,
          );
        },
      ),
    );
  }
}
