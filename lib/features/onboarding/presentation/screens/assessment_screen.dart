import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _assessmentMint = Color(0xFFEBFAEC);
const _assessmentTeal = Color(0xFF006762);
const _assessmentInk = Color(0xFF253228);
const _assessmentMuted = Color(0xFF515F54);
const _assessmentPeach = Color(0xFFFFC4B1);
const _assessmentRust = Color(0xFFA03A0F);
const _assessmentProgress = Color(0xFF00618D);

class AiAssessmentScreen extends StatefulWidget {
  const AiAssessmentScreen({super.key});

  @override
  State<AiAssessmentScreen> createState() => _AiAssessmentScreenState();
}

class _AiAssessmentScreenState extends State<AiAssessmentScreen> {
  int selectedAnswer = 22;
  bool isGeneratingQuestion = true;
  Timer? generationTimer;

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;
  static const _answers = [20, 22, 25, 18];

  @override
  void initState() {
    super.initState();
    generationTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => isGeneratingQuestion = false);
      }
    });
  }

  @override
  void dispose() {
    generationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _assessmentMint,
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
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: _assessmentMint),
                        ),
                      ),
                      Positioned.fill(
                        top: s(80),
                        bottom: isGeneratingQuestion ? 0 : s(97),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: isGeneratingQuestion
                              ? _GeneratingQuestionLoader(
                                  key: const ValueKey('question-loader'),
                                  scale: scale,
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
                                      _ProgressSection(scale: scale),
                                      SizedBox(height: s(32)),
                                      _QuestionCard(scale: scale),
                                      SizedBox(height: s(32)),
                                      _AnswerGrid(
                                        scale: scale,
                                        answers: _answers,
                                        selectedAnswer: selectedAnswer,
                                        onSelected: (answer) {
                                          HapticFeedback.selectionClick();
                                          setState(
                                            () => selectedAnswer = answer,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: _AssessmentHeader(scale: scale),
                      ),
                      if (!isGeneratingQuestion)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _AssessmentBottomBar(scale: scale),
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
  const _ProgressSection({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CÂU 1/10',
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
        Container(
          height: 16 * scale,
          padding: EdgeInsets.all(4 * scale),
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
          child: FractionallySizedBox(
            widthFactor: 0.10,
            child: Container(
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
          ),
        ),
      ],
    );
  }
}

class _GeneratingQuestionLoader extends StatefulWidget {
  const _GeneratingQuestionLoader({super.key, required this.scale});

  final double scale;

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
          return Row(
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
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.scale});

  final double scale;

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
          '15 + 7 = ?',
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
    required this.selectedAnswer,
    required this.onSelected,
  });

  final double scale;
  final List<int> answers;
  final int selectedAnswer;
  final ValueChanged<int> onSelected;

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
          selected: answer == selectedAnswer,
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

  final int answer;
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
                '$answer',
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
  const _AssessmentBottomBar({required this.scale});

  final double scale;

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
                  label: 'THOÁT',
                  icon: Icons.logout_rounded,
                  background: _assessmentPeach.withValues(alpha: 0.50),
                  foreground: _assessmentRust,
                  scale: scale,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
              SizedBox(width: 48 * scale),
              Expanded(
                child: _BottomActionButton(
                  label: 'TIẾP TỤC',
                  icon: Icons.arrow_forward_rounded,
                  foreground: const Color(0xFFBEFFF9),
                  scale: scale,
                  onTap: HapticFeedback.mediumImpact,
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
  final VoidCallback onTap;
  final Color? background;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 48 * scale,
          decoration: BoxDecoration(
            color: background,
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
              Icon(icon, color: foreground, size: 16 * scale),
              SizedBox(width: 8 * scale),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: foreground,
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
