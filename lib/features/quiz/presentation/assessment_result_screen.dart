import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';

const _resultTeal = Color(0xFF006762);
const _resultHeaderTeal = Color(0xFF38898C);
const _resultScoreGreen = Color(0xFF006D36);
const _resultInk = Color(0xFF253228);
const _resultMuted = Color(0xFF515F54);
const _resultCoral = Color(0xFFEC724F);
const _resultCardBorder = Color(0xFFE5E8EB);
const _resultAiAccent = Color(0xFFE8FEFF);
const _resultMascotBorder = Color(0xFF974320);
const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

class AssessmentResultScreen extends StatefulWidget {
  const AssessmentResultScreen({
    super.key,
    this.quiz,
    this.quizService,
    this.onTestAgainGenerated,
  });

  final GeneratedQuiz? quiz;
  final QuizService? quizService;
  final ValueChanged<GeneratedQuiz>? onTestAgainGenerated;

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  late final QuizService _quizService;
  bool isGeneratingAgain = false;

  static const _designWidth = 390.0;
  static const _designHeight = 800.0;

  @override
  void initState() {
    super.initState();
    _quizService = widget.quizService ??
        (_useFakeQuizApi ? const FakeQuizApi() : QuizApi());
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
          AppStrings.current(AppKeys.testAgainCreateMissingQuiz));
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
      );
      if (!mounted) {
        return;
      }

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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = math.min(constraints.maxWidth, 430.0);
              final height = constraints.maxHeight;
              final scale =
                  math.min(width / _designWidth, height / _designHeight);

              double s(double value) => value * scale;
              final grading = widget.quiz?.grading;
              final scoreText = _scoreText(grading);
              final reviewText = _reviewText(grading);

              return Center(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: isGeneratingAgain
                      ? _TestAgainLoader(scale: scale)
                      : Stack(
                          children: [
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              child: _ResultHeader(scale: scale),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: s(111),
                              child: _ScoreRing(
                                scale: scale,
                                scoreText: scoreText,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: s(285),
                              child: Text(
                                context.getText(AppKeys.excellentResultTitle),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.andika(
                                  color: _resultInk,
                                  fontSize: 24 * scale,
                                  fontWeight: FontWeight.w800,
                                  height: 32 / 24,
                                  letterSpacing: -0.4 * scale,
                                ),
                              ),
                            ),
                            Positioned(
                              left: s(26),
                              right: s(26),
                              top: s(369),
                              child: _AiReviewCard(
                                scale: scale,
                                reviewText: reviewText,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: s(592),
                              child: _ResultBottomBar(
                                scale: scale,
                                onTest: generateTestAgain,
                                onPractice: generatePracticeAgain,
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

class _TestAgainLoader extends StatefulWidget {
  const _TestAgainLoader({required this.scale});

  final double scale;

  @override
  State<_TestAgainLoader> createState() => _TestAgainLoaderState();
}

class _TestAgainLoaderState extends State<_TestAgainLoader>
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
                      style: GoogleFonts.andika(
                        color: _resultTeal,
                        fontSize: 40 * widget.scale,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: 3 * widget.scale,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 18 * widget.scale),
              Text(
                context.getText(AppKeys.generatingNewQuiz),
                textAlign: TextAlign.center,
                style: GoogleFonts.andika(
                  color: _resultMuted,
                  fontSize: 16 * widget.scale,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 * scale,
      padding: EdgeInsets.only(left: 20 * scale, right: 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _HeaderIconButton(
              icon: Icons.arrow_back_rounded,
              scale: scale,
              onTap: () => _exitToGradeSelection(context),
            ),
          ),
          Text(
            context.getText(AppKeys.assessmentResultTitle),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: _resultHeaderTeal,
              fontSize: 25 * scale,
              fontWeight: FontWeight.w800,
              height: 34 / 25,
              letterSpacing: -0.2 * scale,
            ),
          ),
        ],
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
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: SizedBox(
          width: 40 * scale,
          height: 40 * scale,
          child: Icon(
            icon,
            color: _resultHeaderTeal,
            size: 23 * scale,
          ),
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.scale,
    required this.scoreText,
  });

  final double scale;
  final String scoreText;

  @override
  Widget build(BuildContext context) {
    final slashIndex = scoreText.indexOf('/');
    final scoreValue =
        slashIndex == -1 ? scoreText : scoreText.substring(0, slashIndex);
    final scoreTotal =
        slashIndex == -1 ? '/10' : scoreText.substring(slashIndex);

    return Center(
      child: SizedBox(
        width: 192 * scale,
        height: 168 * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 192 * scale,
                height: 160 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0F7).withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE6F0F7).withValues(alpha: 0.70),
                      blurRadius: 32 * scale,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 150 * scale,
              height: 150 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _resultTeal, width: 9 * scale),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: scoreValue,
                          style: GoogleFonts.andika(
                            color: _resultScoreGreen,
                            fontSize: 48 * scale,
                            fontWeight: FontWeight.w800,
                            height: 40 / 48,
                            letterSpacing: -0.9 * scale,
                          ),
                        ),
                        TextSpan(
                          text: scoreTotal,
                          style: GoogleFonts.andika(
                            color: Colors.black,
                            fontSize: 36 * scale,
                            fontWeight: FontWeight.w800,
                            height: 40 / 36,
                            letterSpacing: -0.9 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    context.getText(AppKeys.scoreUpper),
                    style: GoogleFonts.andika(
                      color: _resultMuted,
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w800,
                      height: 15 / 10,
                      letterSpacing: 1 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiReviewCard extends StatelessWidget {
  const _AiReviewCard({
    required this.scale,
    required this.reviewText,
  });

  final double scale;
  final String reviewText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 161 * scale,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _resultCardBorder),
        borderRadius: BorderRadius.circular(32 * scale),
        boxShadow: [
          BoxShadow(
            color: _resultInk.withValues(alpha: 0.05),
            blurRadius: 2 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45 * scale,
            top: -45 * scale,
            child: Container(
              width: 96 * scale,
              height: 96 * scale,
              decoration: const BoxDecoration(
                color: _resultAiAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56 * scale,
                height: 56 * scale,
                padding: EdgeInsets.all(2 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _resultMascotBorder,
                    width: 2 * scale,
                  ),
                ),
                child: ClipOval(
                  child: Transform.scale(
                    scale: 1.18,
                    child: Image.asset(
                      'assets/images/onboarding_splash_mascot.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.getText(AppKeys.numiAiReview),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.andika(
                                color: _resultInk,
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w800,
                                height: 20 / 14,
                                letterSpacing: -0.1 * scale,
                              ),
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: _resultTeal,
                            size: 15 * scale,
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * scale),
                      _ReviewText(scale: scale, reviewText: reviewText),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewText extends StatelessWidget {
  const _ReviewText({
    required this.scale,
    required this.reviewText,
  });

  final double scale;
  final String reviewText;

  @override
  Widget build(BuildContext context) {
    final text = '"$reviewText"';
    final highlight = context.getText(AppKeys.defaultAiReviewHighlight);
    final highlightIndex = text.toLowerCase().indexOf(highlight);
    final bodyStyle = GoogleFonts.andika(
      color: _resultMuted,
      fontSize: 12 * scale,
      fontWeight: FontWeight.w400,
      height: 19.5 / 12,
      letterSpacing: -0.1 * scale,
    );

    if (highlightIndex == -1) {
      return Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: bodyStyle,
      );
    }

    return RichText(
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: bodyStyle,
        children: [
          TextSpan(text: text.substring(0, highlightIndex)),
          TextSpan(
            text: text.substring(
              highlightIndex,
              highlightIndex + highlight.length,
            ),
            style: bodyStyle.copyWith(
              color: _resultTeal,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text.substring(highlightIndex + highlight.length)),
        ],
      ),
    );
  }
}

class _ResultBottomBar extends StatelessWidget {
  const _ResultBottomBar({
    required this.scale,
    required this.onTest,
    required this.onPractice,
  });

  final double scale;
  final VoidCallback onTest;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ResultActionButton(
          label: context.getText(AppKeys.assessmentUpper),
          background: _resultCoral,
          scale: scale,
          onTap: onTest,
        ),
        SizedBox(width: 40 * scale),
        _ResultActionButton(
          label: context.getText(AppKeys.practiceUpper),
          icon: Icons.arrow_forward_rounded,
          background: _resultHeaderTeal,
          scale: scale,
          onTap: onPractice,
        ),
      ],
    );
  }
}

class _ResultActionButton extends StatelessWidget {
  const _ResultActionButton({
    required this.label,
    required this.background,
    required this.scale,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color background;
  final double scale;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20 * scale),
        child: Ink(
          width: 145 * scale,
          height: 57 * scale,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 2 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w800,
                      height: 28 / 18,
                      letterSpacing: -0.2 * scale,
                    ),
                  ),
                ),
              ),
              if (icon != null) ...[
                SizedBox(width: 8 * scale),
                Icon(
                  icon,
                  color: Colors.white,
                  size: 18 * scale,
                  weight: 700,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void _exitToGradeSelection(BuildContext context) {
  HapticFeedback.mediumImpact();
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
  }
  if (navigator.canPop()) {
    navigator.pop();
  }
}

String _scoreText(QuizGrading? grading) {
  final scorePercentage = grading?.scorePercentage;
  if (scorePercentage != null) {
    final scoreOutOf10 = (scorePercentage / 10).round().clamp(0, 10);
    return '$scoreOutOf10/10';
  }

  return '10/10';
}

String _reviewText(QuizGrading? grading) {
  final review = grading?.aiReview?.trim();
  if (review != null && review.isNotEmpty) {
    return review;
  }

  return AppStrings.current(AppKeys.defaultAiReview);
}
