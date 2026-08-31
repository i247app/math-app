import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/quiz/application/assessment_controller.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';
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
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

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
  late final AssessmentController _controller;
  final GuardedExitController<AiAssessmentResult> _exitController =
      GuardedExitController<AiAssessmentResult>();

  @override
  void initState() {
    super.initState();
    _controller = AssessmentController(
      quizService: widget.quizService ?? context.read<QuizService>(),
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

  void goToQuestion(int index) {
    final moved = _controller.goToQuestion(index);
    if (moved) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void goToNextQuestion() {
    if (_controller.allQuestionsAnswered) {
      submitCurrentQuiz();
      return;
    }

    HapticFeedback.mediumImpact();
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
            gradeLabel: gradeLabel,
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
                        : isSubmittingQuiz
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
                                'assessment-question-${_controller.questionIndex}',
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
                                              _controller.questionIndex + 1,
                                          totalQuestions: questions.length,
                                          answeredQuestionIndexes: _controller
                                              .selectedAnswerLabels
                                              .keys
                                              .toSet(),
                                          onQuestionSelected: goToQuestion,
                                        ),
                                        const SizedBox(height: 16),
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
                                            _controller.allQuestionsAnswered,
                                        isSubmitting: isSubmittingQuiz,
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
