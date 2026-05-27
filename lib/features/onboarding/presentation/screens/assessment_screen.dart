import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/quiz_models.dart';
import '../../data/quiz_api.dart';
import 'assessment_result_screen.dart';

const _assessmentMint = Color(0xFFEBFAEC);
const _assessmentTeal = Color(0xFF006762);
const _assessmentInk = Color(0xFF253228);
const _assessmentMuted = Color(0xFF515F54);
const _assessmentPeach = Color(0xFFFFC4B1);
const _assessmentRust = Color(0xFFA03A0F);
const _assessmentProgress = Color(0xFF00618D);
const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

enum AiAssessmentResult {
  generationFailed,
}

class AiAssessmentScreen extends StatefulWidget {
  const AiAssessmentScreen({
    super.key,
    this.quizService,
    this.initialQuiz,
    this.purpose = quizPurposeAssessment,
    this.typeOfQuiz = quizTypeGeneral,
    this.gradeLabel,
  });

  final QuizService? quizService;
  final GeneratedQuiz? initialQuiz;
  final String purpose;
  final String typeOfQuiz;
  final String? gradeLabel;

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
  bool isSubmittingQuiz = false;

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  void initState() {
    super.initState();
    _quizService = widget.quizService ??
        (_useFakeQuizApi ? const FakeQuizApi() : QuizApi());
    final initialQuiz = widget.initialQuiz;
    if (initialQuiz == null) {
      generateQuiz();
    } else {
      quiz = initialQuiz;
    }
  }

  Future<void> generateQuiz() async {
    setState(() {
      quiz = null;
      questionIndex = 0;
      selectedAnswerLabels.clear();
      errorMessage = null;
      errorRetryAction = null;
      isSubmittingQuiz = false;
    });

    try {
      final generatedQuiz = await _quizService.generateAssessmentQuiz(
        purpose: widget.purpose,
        typeOfQuiz: widget.typeOfQuiz,
        gradeLabel: widget.gradeLabel,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        quiz = generatedQuiz;
      });
    } on QuizException catch (error) {
      if (!mounted) {
        return;
      }

      handleGenerationFailure(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      handleGenerationFailure('Không thể tạo câu hỏi. Vui lòng thử lại.');
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
        errorMessage = 'Không tìm thấy bài test để nộp.';
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
      );
      if (!mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AssessmentResultScreen(
            quiz: submittedQuiz,
            quizService: _quizService,
            onTestAgainGenerated: openGeneratedQuiz,
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
        errorMessage = 'Nộp bài thất bại. Vui lòng thử lại.';
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
          title: const Text(
            'Bạn có câu hỏi chưa trả lời',
            style: TextStyle(
              color: _assessmentInk,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          content: const Text(
            'Bạn có chắc muốn nộp bài không?',
            style: TextStyle(
              color: _assessmentMuted,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Ở LẠI',
                style: TextStyle(
                  color: _assessmentRust,
                  fontFamily: 'Nunito',
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
              child: const Text(
                'NỘP BÀI',
                style: TextStyle(
                  fontFamily: 'Nunito',
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
        currentQuestion == null && errorMessage == null;
    final backgroundColor =
        isGeneratingQuestion ? Colors.white : _assessmentMint;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = math.min(constraints.maxWidth, 430.0);
              final height = constraints.maxHeight;
              final scale =
                  math.min(width / _designWidth, height / _designHeight);

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
                        bottom: isGeneratingQuestion ||
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
                                  onRetry: errorRetryAction ??
                                      () {
                                        generateQuiz();
                                      },
                                )
                              : isSubmittingQuiz
                                  ? _GeneratingQuestionLoader(
                                      key: const ValueKey('submit-loader'),
                                      scale: scale,
                                      message: 'đợi Numi nộp bài cho bạn nhé!',
                                    )
                                  : isGeneratingQuestion
                                      ? _GeneratingQuestionLoader(
                                          key:
                                              const ValueKey('question-loader'),
                                          scale: scale,
                                          message:
                                              'Để Numi tạo bài kiểm tra cho bạn nhé',
                                        )
                                      : SingleChildScrollView(
                                          key: const ValueKey(
                                              'question-content'),
                                          physics:
                                              const BouncingScrollPhysics(),
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
                                                currentQuestion:
                                                    questionIndex + 1,
                                                totalQuestions:
                                                    questions.length,
                                              ),
                                              SizedBox(height: s(32)),
                                              _QuestionCard(
                                                scale: scale,
                                                question: currentQuestion!
                                                    .questionName,
                                              ),
                                              SizedBox(height: s(32)),
                                              _AnswerGrid(
                                                scale: scale,
                                                answers:
                                                    currentQuestion.answers,
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

class _AssessmentHeader extends StatelessWidget {
  const _AssessmentHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32 * scale)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 80 * scale,
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          decoration: BoxDecoration(
            color: _assessmentMint.withValues(alpha: 0.84),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(32 * scale),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF253228).withValues(alpha: 0.05),
                blurRadius: 2 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              _HeaderIconButton(
                icon: Icons.close_rounded,
                scale: scale,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Text(
                  'Thử thách AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _assessmentTeal,
                    fontFamily: 'Nunito',
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _HeaderIconButton(
                icon: Icons.help_outline_rounded,
                scale: scale,
                onTap: HapticFeedback.selectionClick,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34 * scale,
          height: 34 * scale,
          child: Icon(
            icon,
            color: _assessmentTeal,
            size: 22 * scale,
          ),
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.scale,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  final double scale;
  final int currentQuestion;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final progress =
        totalQuestions == 0 ? 0.0 : currentQuestion / totalQuestions;
    final progressValue = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CÂU $currentQuestion/$totalQuestions',
          style: TextStyle(
            color: _assessmentMuted,
            fontFamily: 'Nunito',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w900,
            height: 1.5,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 12 * scale),
        SizedBox(
          height: 16 * scale,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final inset = 4 * scale;
              final trackWidth = constraints.maxWidth;
              final fillWidth =
                  math.max(0.0, (trackWidth - inset * 2) * progressValue);

              return Container(
                padding: EdgeInsets.all(inset),
                decoration: BoxDecoration(
                  color: _assessmentPeach,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4 * scale,
                      offset: Offset(0, 2 * scale),
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: fillWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: _assessmentProgress,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AssessmentErrorState extends StatelessWidget {
  const _AssessmentErrorState({
    super.key,
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72 * scale,
              height: 72 * scale,
              decoration: BoxDecoration(
                color: _assessmentPeach.withValues(alpha: 0.58),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: _assessmentRust,
                size: 34 * scale,
              ),
            ),
            SizedBox(height: 20 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _assessmentMuted,
                fontFamily: 'Nunito',
                fontSize: 15 * scale,
                fontWeight: FontWeight.w800,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 24 * scale),
            SizedBox(
              width: 168 * scale,
              child: _BottomActionButton(
                label: 'THỬ LẠI',
                icon: Icons.refresh_rounded,
                foreground: const Color(0xFFBEFFF9),
                scale: scale,
                onTap: onRetry,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_assessmentTeal, Color(0xFF73F1E7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratingQuestionLoader extends StatefulWidget {
  const _GeneratingQuestionLoader({
    super.key,
    required this.scale,
    this.message,
  });

  final double scale;
  final String? message;

  @override
  State<_GeneratingQuestionLoader> createState() =>
      _GeneratingQuestionLoaderState();
}

class _GeneratingQuestionLoaderState extends State<_GeneratingQuestionLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const letters = ['n', 'u', 'm', 'i', 'n', 'u', 'm', 'i'];

    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(letters.length, (index) {
                  final delayedProgress =
                      (controller.value - (index * 0.075)) % 1.0;
                  final lift = delayedProgress <= 0.20
                      ? -34 *
                          widget.scale *
                          math.sin(delayedProgress / 0.20 * math.pi)
                      : 0.0;

                  return Transform.translate(
                    offset: Offset(0, lift),
                    child: Text(
                      letters[index],
                      style: TextStyle(
                        color: _assessmentTeal,
                        fontFamily: 'Nunito',
                        fontSize: 40 * widget.scale,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 3 * widget.scale,
                      ),
                    ),
                  );
                }),
              ),
              if (widget.message != null) ...[
                SizedBox(height: 18 * widget.scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32 * widget.scale),
                  child: Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _assessmentMuted,
                      fontFamily: 'Nunito',
                      fontSize: 16 * widget.scale,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.scale,
    required this.question,
  });

  final double scale;
  final String question;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 356 * scale,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 26 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32 * scale),
        border: Border.all(color: const Color(0xFFDCCACA)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _assessmentInk,
            fontFamily: 'Nunito',
            fontSize: 72 * scale,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({
    required this.scale,
    required this.answers,
    required this.selectedAnswerLabel,
    required this.onSelected,
  });

  final double scale;
  final List<QuizAnswer> answers;
  final String? selectedAnswerLabel;
  final ValueChanged<QuizAnswer> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: answers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16 * scale,
        crossAxisSpacing: 16 * scale,
        mainAxisExtent: 88 * scale,
      ),
      itemBuilder: (context, index) {
        final answer = answers[index];
        return _AnswerButton(
          answer: answer,
          selected: answer.label == selectedAnswerLabel,
          scale: scale,
          onTap: () => onSelected(answer),
        );
      },
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.answer,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final QuizAnswer answer;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? _assessmentTeal : Colors.black.withValues(alpha: 0);
    final textColor = selected ? _assessmentTeal : _assessmentInk;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(32 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32 * scale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32 * scale),
            border: Border.all(color: borderColor, width: 2 * scale),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF73F1E7).withValues(alpha: 0.20),
                      spreadRadius: 4 * scale,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 6 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2 * scale,
                      offset: Offset(0, 1 * scale),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                answer.content,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Nunito',
                  fontSize: 30 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 8 * scale : 0,
                height: selected ? 12 * scale : 0,
                padding: EdgeInsets.only(top: 4 * scale),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: _assessmentTeal,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentBottomBar extends StatelessWidget {
  const _AssessmentBottomBar({
    required this.scale,
    required this.canGoBack,
    required this.isLastQuestion,
    required this.isSubmitting,
    required this.onBack,
    required this.onContinue,
  });

  final double scale;
  final bool canGoBack;
  final bool isLastQuestion;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 97 * scale,
          padding: EdgeInsets.fromLTRB(
            24 * scale,
            25 * scale,
            24 * scale,
            24 * scale,
          ),
          decoration: BoxDecoration(
            color: _assessmentMint.withValues(alpha: 0.90),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFCDE2CF).withValues(alpha: 0.30),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _BottomActionButton(
                  label: 'CÂU TRƯỚC',
                  icon: Icons.arrow_back_rounded,
                  background: _assessmentPeach.withValues(alpha: 0.50),
                  foreground: _assessmentRust,
                  scale: scale,
                  onTap: canGoBack && !isSubmitting ? onBack : null,
                ),
              ),
              SizedBox(width: 48 * scale),
              Expanded(
                child: _BottomActionButton(
                  label: isSubmitting
                      ? 'ĐANG NỘP'
                      : isLastQuestion
                          ? 'NỘP BÀI'
                          : 'TIẾP TỤC',
                  icon: isLastQuestion
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  foreground: const Color(0xFFBEFFF9),
                  scale: scale,
                  onTap: isSubmitting ? null : onContinue,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_assessmentTeal, Color(0xFF73F1E7)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.scale,
    required this.onTap,
    this.background,
    this.gradient,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final double scale;
  final VoidCallback? onTap;
  final Color? background;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final effectiveForeground =
        enabled ? foreground : foreground.withValues(alpha: 0.38);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 48 * scale,
          decoration: BoxDecoration(
            color: background?.withValues(alpha: enabled ? 1 : 0.42),
            gradient: gradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: gradient == null
                ? null
                : [
                    BoxShadow(
                      color: _assessmentTeal.withValues(alpha: 0.20),
                      blurRadius: 6 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: effectiveForeground, size: 16 * scale),
              SizedBox(width: 8 * scale),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: effectiveForeground,
                  fontFamily: 'Nunito',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
