import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/application/assessment_controller.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/presentation/screens/assessment_result_screen.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_answer_grid.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_bottom_bar.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_error_state.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_generating_loader.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_header.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_progress_section.dart';
import 'package:numi/features/quiz/widgets/assessment/assessment_question_card.dart';
import 'package:numi/features/quiz/widgets/shared/attempt_exit_dialog.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

enum AiAssessmentResult { generationFailed }

class AiAssessmentScreen extends StatefulWidget {
  const AiAssessmentScreen({
    super.key,
    this.quizService,
    this.initialQuiz,
    this.purpose = quizPurposeAssessment,
    this.typeOfQuiz = quizTypeGeneral,
    this.gradeLabel,
    this.chapters,
    this.profileId,
    this.onResultBack,
  });

  final QuizService? quizService;
  final GeneratedQuiz? initialQuiz;
  final String purpose;
  final String typeOfQuiz;
  final String? gradeLabel;
  final List<String>? chapters;
  final int? profileId;
  final VoidCallback? onResultBack;

  @override
  State<AiAssessmentScreen> createState() => _AiAssessmentScreenState();
}

class _AiAssessmentScreenState extends State<AiAssessmentScreen> {
  static const double _backSwipeTriggerDistance = 48;
  static const double _backSwipeTriggerVelocity = 350;

  late final AssessmentController _controller;
  bool _allowPop = false;
  bool _isExitDialogOpen = false;
  double _backSwipeDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AssessmentController(
      quizService: widget.quizService ?? QuizApi(),
      initialQuiz: widget.initialQuiz,
      purpose: widget.purpose,
      typeOfQuiz: widget.typeOfQuiz,
      gradeLabel: widget.gradeLabel,
      chapters: widget.chapters,
      profileId: widget.profileId,
    );
    if (widget.initialQuiz == null) {
      generateQuiz();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> generateQuiz() async {
    final generated = await _controller.generateQuiz();
    if (!mounted || generated) {
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(AiAssessmentResult.generationFailed);
    }
  }

  void selectAnswer(QuizAnswer answer) {
    HapticFeedback.selectionClick();
    _controller.selectAnswer(answer);
  }

  void goToPreviousQuestion() {
    HapticFeedback.selectionClick();
    _controller.goToPreviousQuestion();
  }

  void goToNextQuestion() {
    if (_controller.isLastQuestion) {
      submitCurrentQuiz();
      return;
    }

    HapticFeedback.mediumImpact();
    _controller.goToNextQuestion();
  }

  Future<void> submitCurrentQuiz() async {
    HapticFeedback.mediumImpact();
    final result = await _controller.submitCurrentQuiz();
    if (!mounted || result.status != AssessmentSubmitStatus.submitted) {
      if (result.status == AssessmentSubmitStatus.unanswered) {
        HapticFeedback.selectionClick();
      }
      return;
    }

    final navigator = Navigator.of(context);
    final quizService = _controller.quizService;
    final fallbackPurpose = widget.purpose;
    final fallbackTypeOfQuiz = widget.typeOfQuiz;
    final gradeLabel = widget.gradeLabel;
    final profileId = widget.profileId;
    final onResultBack = widget.onResultBack;

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (resultContext) {
          return AssessmentResultScreen(
            quiz: result.quiz,
            quizService: quizService,
            profileId: profileId,
            onTestAgainGenerated: (generatedQuiz) {
              Navigator.of(resultContext).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => AiAssessmentScreen(
                    quizService: quizService,
                    initialQuiz: generatedQuiz,
                    purpose: generatedQuiz.purpose ?? fallbackPurpose,
                    typeOfQuiz: generatedQuiz.typeOfQuiz ?? fallbackTypeOfQuiz,
                    gradeLabel: gradeLabel,
                    profileId: profileId,
                    onResultBack: onResultBack,
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
      AssessmentRetryAction.submit => submitCurrentQuiz(),
      _ => generateQuiz(),
    };
  }

  Future<void> _requestExit() async {
    if (!mounted ||
        _allowPop ||
        _isExitDialogOpen ||
        _controller.isGeneratingQuestion ||
        _controller.isSubmittingQuiz) {
      return;
    }

    final hasActiveAttempt = _controller.quiz?.questions.isNotEmpty ?? false;
    if (!hasActiveAttempt) {
      await Navigator.of(context).maybePop();
      return;
    }

    _isExitDialogOpen = true;
    final shouldExit = await showAttemptExitDialog(context);
    _isExitDialogOpen = false;
    if (shouldExit && mounted) {
      await _popAttempt();
    }
  }

  Future<void> _popAttempt() async {
    if (!mounted) {
      return;
    }
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleBackSwipeStart(DragStartDetails _) {
    _backSwipeDistance = 0;
  }

  void _handleBackSwipeUpdate(DragUpdateDetails details) {
    _backSwipeDistance += details.primaryDelta ?? 0;
  }

  void _handleBackSwipeEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldRequestExit =
        _backSwipeDistance >= _backSwipeTriggerDistance ||
        velocity >= _backSwipeTriggerVelocity;
    _backSwipeDistance = 0;
    if (shouldRequestExit) {
      _requestExit();
    }
  }

  void _handleBackSwipeCancel() {
    _backSwipeDistance = 0;
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
          final currentQuiz = _controller.quiz;
          final questions = currentQuiz?.questions ?? const <QuizQuestion>[];
          final currentQuestion = _controller.currentQuestion;
          final errorMessage = _controller.errorMessage;
          final isGeneratingQuestion = _controller.isGeneratingQuestion;
          final isSubmittingQuiz = _controller.isSubmittingQuiz;
          final hasActiveAttempt = questions.isNotEmpty;
          final isBusy = isGeneratingQuestion || isSubmittingQuiz;
          final needsIosBackSwipeDetector =
              Theme.of(context).platform == TargetPlatform.iOS &&
              hasActiveAttempt &&
              !isBusy;
          final backgroundColor = isGeneratingQuestion
              ? colors.surface
              : colors.pageBackground;

          final screen = Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ColoredBox(color: backgroundColor),
                      ),
                      Positioned.fill(
                        top: isGeneratingQuestion || isSubmittingQuiz ? 0 : 80,
                        bottom:
                            isGeneratingQuestion ||
                                isSubmittingQuiz ||
                                errorMessage != null
                            ? 0
                            : 97,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: errorMessage != null
                              ? AssessmentErrorState(
                                  key: const ValueKey('question-error'),
                                  message: errorMessage,
                                  onRetry: retryErrorAction,
                                )
                              : isSubmittingQuiz
                              ? AssessmentGeneratingLoader(
                                  key: const ValueKey('submit-loader'),
                                  message: context.getText(
                                    AppKeys.submittingForYou,
                                  ),
                                )
                              : isGeneratingQuestion
                              ? AssessmentGeneratingLoader(
                                  key: const ValueKey('question-loader'),
                                  message: context.getText(
                                    AppKeys.generatingAssessment,
                                  ),
                                )
                              : SingleChildScrollView(
                                  key: const ValueKey('question-content'),
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    0,
                                    24,
                                    24,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    spacing: 32,
                                    children: [
                                      AssessmentProgressSection(
                                        currentQuestion:
                                            _controller.questionIndex + 1,
                                        totalQuestions: questions.length,
                                      ),
                                      AssessmentQuestionCard(
                                        question: currentQuestion!.questionName,
                                      ),
                                      AssessmentAnswerGrid(
                                        answers: currentQuestion.answers,
                                        selectedAnswerLabel:
                                            _controller.selectedAnswerLabel,
                                        onSelected: selectAnswer,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      if (!isGeneratingQuestion && !isSubmittingQuiz)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: AssessmentHeader(onClose: _requestExit),
                        ),
                      if (!isGeneratingQuestion &&
                          !isSubmittingQuiz &&
                          errorMessage == null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: AssessmentBottomBar(
                            canGoBack: _controller.questionIndex > 0,
                            isLastQuestion: _controller.isLastQuestion,
                            isSubmitting: isSubmittingQuiz,
                            onBack: goToPreviousQuestion,
                            onContinue: goToNextQuestion,
                          ),
                        ),
                      if (needsIosBackSwipeDetector)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 24,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            excludeFromSemantics: true,
                            onHorizontalDragStart: _handleBackSwipeStart,
                            onHorizontalDragUpdate: _handleBackSwipeUpdate,
                            onHorizontalDragEnd: _handleBackSwipeEnd,
                            onHorizontalDragCancel: _handleBackSwipeCancel,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );

          return PopScope(
            canPop: _allowPop || (!hasActiveAttempt && !isBusy),
            onPopInvokedWithResult: (didPop, _) async {
              if (!didPop) {
                await _requestExit();
              }
            },
            child: screen,
          );
        },
      ),
    );
  }
}
