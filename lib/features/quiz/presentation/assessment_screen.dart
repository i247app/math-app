import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/features/quiz/controllers/assessment_controller.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/assessment_result_screen.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment/answer_grid.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment/assessment_bottom_bar.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment/assessment_error_state.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment/assessment_header.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment/assessment_style.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment/generating_question_loader.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment/progress_section.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment/question_card.dart';

const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

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

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  void initState() {
    super.initState();
    _controller = AssessmentController(
      quizService:
          widget.quizService ??
          (_useFakeQuizApi ? const FakeQuizApi() : QuizApi()),
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

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssessmentResultScreen(
          quiz: result.quiz,
          quizService: _controller.quizService,
          profileId: widget.profileId,
          onTestAgainGenerated: openGeneratedQuiz,
          onBack: widget.onResultBack,
        ),
      ),
    );
  }

  Future<void> retryErrorAction() {
    return switch (_controller.errorRetryAction) {
      AssessmentRetryAction.submit => submitCurrentQuiz(),
      _ => generateQuiz(),
    };
  }

  void openGeneratedQuiz(GeneratedQuiz generatedQuiz) {
    if (!mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AiAssessmentScreen(
          quizService: _controller.quizService,
          initialQuiz: generatedQuiz,
          purpose: generatedQuiz.purpose ?? widget.purpose,
          typeOfQuiz: generatedQuiz.typeOfQuiz ?? widget.typeOfQuiz,
          gradeLabel: widget.gradeLabel,
          profileId: widget.profileId,
          onResultBack: widget.onResultBack,
        ),
      ),
    );
  }

  Future<bool> showUnansweredSubmitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            context.getText(AppKeys.unansweredSubmitTitle),
            style: const TextStyle(
              color: AssessmentStyle.ink,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          content: Text(
            context.getText(AppKeys.unansweredSubmitMessage),
            style: const TextStyle(
              color: AssessmentStyle.muted,
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
                style: const TextStyle(
                  color: AssessmentStyle.rust,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AssessmentStyle.teal,
                foregroundColor: const Color(0xFFBEFFF9),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final currentQuiz = _controller.quiz;
          final questions = currentQuiz?.questions ?? const <QuizQuestion>[];
          final currentQuestion = _controller.currentQuestion;
          final errorMessage = _controller.errorMessage;
          final isGeneratingQuestion = _controller.isGeneratingQuestion;
          final isSubmittingQuiz = _controller.isSubmittingQuiz;
          final backgroundColor = isGeneratingQuestion
              ? Colors.white
              : AssessmentStyle.mint;

          return Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = math.min(constraints.maxWidth, 430.0);
                  final height = constraints.maxHeight;
                  final scale = math.min(
                    width / _designWidth,
                    height / _designHeight,
                  );

                  double s(double value) => value * scale;

                  return Center(
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ColoredBox(color: backgroundColor),
                          ),
                          Positioned.fill(
                            top: isGeneratingQuestion || isSubmittingQuiz
                                ? 0
                                : s(80),
                            bottom:
                                isGeneratingQuestion ||
                                    isSubmittingQuiz ||
                                    errorMessage != null
                                ? 0
                                : s(97),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: errorMessage != null
                                  ? AssessmentErrorState(
                                      key: const ValueKey('question-error'),
                                      scale: scale,
                                      message: errorMessage,
                                      onRetry: retryErrorAction,
                                    )
                                  : isSubmittingQuiz
                                  ? GeneratingQuestionLoader(
                                      key: const ValueKey('submit-loader'),
                                      scale: scale,
                                      message: context.getText(
                                        AppKeys.submittingForYou,
                                      ),
                                    )
                                  : isGeneratingQuestion
                                  ? GeneratingQuestionLoader(
                                      key: const ValueKey('question-loader'),
                                      scale: scale,
                                      message: context.getText(
                                        AppKeys.generatingAssessment,
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      key: const ValueKey('question-content'),
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.fromLTRB(
                                        s(24),
                                        0,
                                        s(24),
                                        s(24),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          AssessmentProgressSection(
                                            scale: scale,
                                            currentQuestion:
                                                _controller.questionIndex + 1,
                                            totalQuestions: questions.length,
                                          ),
                                          SizedBox(height: s(32)),
                                          AssessmentQuestionCard(
                                            scale: scale,
                                            question:
                                                currentQuestion!.questionName,
                                          ),
                                          SizedBox(height: s(32)),
                                          AssessmentAnswerGrid(
                                            scale: scale,
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
                              child: AssessmentHeader(scale: scale),
                            ),
                          if (!isGeneratingQuestion &&
                              !isSubmittingQuiz &&
                              errorMessage == null)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: AssessmentBottomBar(
                                scale: scale,
                                canGoBack: _controller.questionIndex > 0,
                                isLastQuestion: _controller.isLastQuestion,
                                isSubmitting: isSubmittingQuiz,
                                onBack: goToPreviousQuestion,
                                onContinue: goToNextQuestion,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
