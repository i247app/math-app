import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/features/quiz/cache/quiz_cache.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/assessment_result_screen.dart';

part '../widgets/assessment/assessment_header.dart';
part '../widgets/assessment/header_icon_button.dart';
part '../widgets/assessment/progress_section.dart';
part '../widgets/assessment/assessment_error_state.dart';
part '../widgets/assessment/generating_question_loader.dart';
part '../widgets/assessment/generating_question_loader_state.dart';
part '../widgets/assessment/question_card.dart';
part '../widgets/assessment/answer_grid.dart';
part '../widgets/assessment/answer_button.dart';
part '../widgets/assessment/assessment_bottom_bar.dart';
part '../widgets/assessment/bottom_action_button.dart';

const _assessmentMint = Color(0xFFEBFAEC);
const _assessmentTeal = Color(0xFF006762);
const _assessmentInk = Color(0xFF253228);
const _assessmentMuted = Color(0xFF515F54);
const _assessmentPeach = Color(0xFFFFC4B1);
const _assessmentRust = Color(0xFFA03A0F);
const _assessmentProgress = Color(0xFF00618D);
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
  late final QuizService _quizService;
  GeneratedQuiz? quiz;
  int questionIndex = 0;
  final Map<int, String> selectedAnswerLabels = {};
  String? errorMessage;
  VoidCallback? errorRetryAction;
  bool isGeneratingQuiz = false;
  bool isSubmittingQuiz = false;
  int _generateRequestId = 0;

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  void initState() {
    super.initState();
    _quizService =
        widget.quizService ??
        (_useFakeQuizApi ? const FakeQuizApi() : QuizApi());
    final initialQuiz = widget.initialQuiz;
    if (initialQuiz == null) {
      generateQuiz();
    } else {
      quiz = initialQuiz;
    }
  }

  Future<void> generateQuiz() async {
    if (isGeneratingQuiz) {
      return;
    }
    final requestId = ++_generateRequestId;
    setState(() {
      quiz = null;
      questionIndex = 0;
      selectedAnswerLabels.clear();
      errorMessage = null;
      errorRetryAction = null;
      isGeneratingQuiz = true;
      isSubmittingQuiz = false;
    });

    try {
      final generatedQuiz = await _quizService.generateAssessmentQuiz(
        purpose: widget.purpose,
        typeOfQuiz: widget.typeOfQuiz,
        gradeLabel: widget.gradeLabel,
        chapters: widget.chapters,
        profileId: widget.profileId,
      );
      if (!mounted || requestId != _generateRequestId) {
        return;
      }
      QuizCache.seedDetail(generatedQuiz);

      setState(() {
        quiz = generatedQuiz;
        isGeneratingQuiz = false;
      });
    } on QuizException catch (error) {
      if (!mounted || requestId != _generateRequestId) {
        return;
      }

      setState(() => isGeneratingQuiz = false);
      handleGenerationFailure(error.message);
    } catch (_) {
      if (!mounted || requestId != _generateRequestId) {
        return;
      }

      setState(() => isGeneratingQuiz = false);
      handleGenerationFailure(AppStrings.current(AppKeys.createQuestionFailed));
    }
  }

  void handleGenerationFailure(String message) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(AiAssessmentResult.generationFailed);
      return;
    }

    setState(() => errorMessage = message);
  }

  void selectAnswer(QuizAnswer answer) {
    HapticFeedback.selectionClick();
    setState(() => selectedAnswerLabels[questionIndex] = answer.label);
  }

  void goToPreviousQuestion() {
    if (questionIndex == 0) {
      HapticFeedback.selectionClick();
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => questionIndex--);
  }

  void goToNextQuestion() {
    final questions = quiz?.questions ?? const <QuizQuestion>[];
    if (questionIndex >= questions.length - 1) {
      submitCurrentQuiz();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      questionIndex++;
    });
  }

  Future<void> submitCurrentQuiz() async {
    if (isSubmittingQuiz) {
      return;
    }

    final currentQuiz = quiz;
    final questions = currentQuiz?.questions ?? const <QuizQuestion>[];
    final quizId = currentQuiz?.quizId;
    if (currentQuiz == null || questions.isEmpty || quizId == null) {
      setState(() {
        errorMessage = AppStrings.current(AppKeys.missingQuizToSubmit);
        errorRetryAction = null;
      });
      return;
    }

    var hasUnansweredQuestion = false;
    for (var index = 0; index < questions.length; index++) {
      if (selectedAnswerLabels[index] == null) {
        hasUnansweredQuestion = true;
        break;
      }
    }
    if (hasUnansweredQuestion) {
      HapticFeedback.selectionClick();
      for (var index = 0; index < questions.length; index++) {
        if (selectedAnswerLabels[index] == null) {
          setState(() => questionIndex = index);
          break;
        }
      }
      return;
    }

    final answers = <SubmitQuizAnswer>[
      for (var index = 0; index < questions.length; index++)
        SubmitQuizAnswer(
          questionNumber: questions[index].questionNumber,
          label: selectedAnswerLabels[index]!,
        ),
    ];

    HapticFeedback.mediumImpact();
    setState(() {
      errorMessage = null;
      errorRetryAction = null;
      isSubmittingQuiz = true;
    });

    try {
      final submittedQuiz = await _quizService.submitQuiz(
        quizId: quizId,
        answers: answers,
        profileId: widget.profileId,
      );
      if (!mounted) {
        return;
      }
      final profileId =
          widget.profileId ?? submittedQuiz.profileId ?? currentQuiz.profileId;
      QuizCache.seedDetail(submittedQuiz);
      QuizCache.invalidateLists(profileId: profileId);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AssessmentResultScreen(
            quiz: submittedQuiz,
            quizService: _quizService,
            profileId: widget.profileId,
            onTestAgainGenerated: openGeneratedQuiz,
            onBack: widget.onResultBack,
          ),
        ),
      );
    } on QuizException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = error.message;
        errorRetryAction = () {
          submitCurrentQuiz();
        };
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = AppStrings.current(AppKeys.submitQuizFailed);
        errorRetryAction = () {
          submitCurrentQuiz();
        };
      });
    } finally {
      if (mounted) {
        setState(() => isSubmittingQuiz = false);
      }
    }
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
          quizService: _quizService,
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
              color: _assessmentInk,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          content: Text(
            context.getText(AppKeys.unansweredSubmitMessage),
            style: const TextStyle(
              color: _assessmentMuted,
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
                  color: _assessmentRust,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _assessmentTeal,
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
    final currentQuiz = quiz;
    final questions = currentQuiz?.questions ?? const <QuizQuestion>[];
    final currentQuestion = questions.isEmpty ? null : questions[questionIndex];
    final selectedAnswerLabel = selectedAnswerLabels[questionIndex];
    final isGeneratingQuestion =
        (isGeneratingQuiz || currentQuestion == null) && errorMessage == null;
    final backgroundColor = isGeneratingQuestion
        ? Colors.white
        : _assessmentMint;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
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
                              ? _AssessmentErrorState(
                                  key: const ValueKey('question-error'),
                                  scale: scale,
                                  message: errorMessage!,
                                  onRetry:
                                      errorRetryAction ??
                                      () {
                                        generateQuiz();
                                      },
                                )
                              : isSubmittingQuiz
                              ? _GeneratingQuestionLoader(
                                  key: const ValueKey('submit-loader'),
                                  scale: scale,
                                  message: context.getText(
                                    AppKeys.submittingForYou,
                                  ),
                                )
                              : isGeneratingQuestion
                              ? _GeneratingQuestionLoader(
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
                                      _ProgressSection(
                                        scale: scale,
                                        currentQuestion: questionIndex + 1,
                                        totalQuestions: questions.length,
                                      ),
                                      SizedBox(height: s(32)),
                                      _QuestionCard(
                                        scale: scale,
                                        question: currentQuestion!.questionName,
                                      ),
                                      SizedBox(height: s(32)),
                                      _AnswerGrid(
                                        scale: scale,
                                        answers: currentQuestion.answers,
                                        selectedAnswerLabel:
                                            selectedAnswerLabel,
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
                          child: _AssessmentHeader(scale: scale),
                        ),
                      if (!isGeneratingQuestion &&
                          !isSubmittingQuiz &&
                          errorMessage == null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _AssessmentBottomBar(
                            scale: scale,
                            canGoBack: questionIndex > 0,
                            isLastQuestion:
                                questionIndex >= questions.length - 1,
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
      ),
    );
  }
}
