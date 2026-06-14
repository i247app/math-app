import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/homework/presentation/student_homework_result_screen.dart';

const _homeworkAttemptMint = Color(0xFFEBFAEC);
const _homeworkAttemptTeal = Color(0xFF006762);
const _homeworkAttemptInk = Color(0xFF253228);
const _homeworkAttemptMuted = Color(0xFF515F54);
const _homeworkAttemptPeach = Color(0xFFFFC4B1);
const _homeworkAttemptRust = Color(0xFFA03A0F);
const _homeworkAttemptProgress = Color(0xFF00618D);

class StudentHomeworkAttemptScreen extends StatefulWidget {
  const StudentHomeworkAttemptScreen({
    super.key,
    required this.exerciseId,
    required this.profileId,
    this.initialExercise,
    ClassroomExerciseService? exerciseService,
  }) : _exerciseService = exerciseService;

  final int exerciseId;
  final int profileId;
  final ClassroomExercise? initialExercise;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<StudentHomeworkAttemptScreen> createState() =>
      _StudentHomeworkAttemptScreenState();
}

class _StudentHomeworkAttemptScreenState
    extends State<StudentHomeworkAttemptScreen> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();

  ClassroomExercise? _exercise;
  int _questionIndex = 0;
  final Map<int, String> _selectedAnswerLabels = <int, String>{};
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  VoidCallback? _errorRetryAction;

  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  @override
  void initState() {
    super.initState();
    _exercise = widget.initialExercise;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorRetryAction = null;
    });

    try {
      final exercise = await _exerciseService.getExerciseDetail(
        exerciseId: widget.exerciseId,
        profileId: widget.profileId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _exercise = exercise ?? _exercise;
        _questionIndex = 0;
        _selectedAnswerLabels.clear();
      });
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message.trim().isEmpty
            ? context.readText(AppKeys.studentHomeworkLoadFailed)
            : error.message;
        _errorRetryAction = _loadDetail;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = context.readText(AppKeys.studentHomeworkLoadFailed);
        _errorRetryAction = _loadDetail;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectAnswer(_HomeworkAttemptAnswer answer) {
    HapticFeedback.selectionClick();
    setState(() => _selectedAnswerLabels[_questionIndex] = answer.label);
  }

  void _goToPreviousQuestion() {
    if (_questionIndex == 0) {
      HapticFeedback.selectionClick();
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _questionIndex--);
  }

  void _goToNextQuestion(List<_HomeworkAttemptQuestion> questions) {
    if (_questionIndex >= questions.length - 1) {
      _submitHomework(questions);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _questionIndex++);
  }

  Future<void> _submitHomework(
    List<_HomeworkAttemptQuestion> questions,
  ) async {
    if (_isSubmitting) {
      return;
    }

    final exerciseId = (_exercise?.stableId ?? widget.exerciseId);
    if (exerciseId <= 0) {
      setState(() {
        _errorMessage =
            context.readText(AppKeys.studentHomeworkMissingExercise);
        _errorRetryAction = null;
      });
      return;
    }

    for (var index = 0; index < questions.length; index++) {
      if (_selectedAnswerLabels[index] == null) {
        HapticFeedback.selectionClick();
        setState(() => _questionIndex = index);
        return;
      }
    }

    final answers = <SubmitClassroomExerciseAnswer>[
      for (var index = 0; index < questions.length; index++)
        SubmitClassroomExerciseAnswer(
          questionNumber: questions[index].questionNumber,
          label: _selectedAnswerLabels[index]!,
        ),
    ];

    HapticFeedback.mediumImpact();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _errorRetryAction = null;
    });

    try {
      final submission = await _exerciseService.submitExercise(
        profileId: widget.profileId,
        classroomExerciseId: exerciseId,
        answers: answers,
      );
      if (!mounted) {
        return;
      }
      final exercise = _exercise;
      if (exercise == null) {
        setState(() {
          _errorMessage =
              context.readText(AppKeys.studentHomeworkMissingExercise);
          _errorRetryAction = null;
        });
        return;
      }
      Navigator.of(context).pushReplacement<bool, void>(
        MaterialPageRoute<bool>(
          builder: (_) => StudentHomeworkResultScreen(
            summary: studentHomeworkResultSummary(
              exercise: exercise,
              submission: submission,
              answers: answers,
            ),
          ),
        ),
      );
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message.trim().isEmpty
            ? context.readText(AppKeys.studentHomeworkSubmitFailed)
            : error.message;
        _errorRetryAction = () => _submitHomework(questions);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppStrings.current(AppKeys.studentHomeworkSubmitFailed);
        _errorRetryAction = () => _submitHomework(questions);
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _homeworkAttemptMint,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final scale = math
                .min(width / _designWidth, height / _designHeight)
                .clamp(0.78, 1.18);
            final s = scale.toDouble();
            final questions = _attemptQuestions(_exercise);
            final questionError =
                _isLoading ? null : _questionDataError(context, questions);
            final effectiveError = _errorMessage ?? questionError;
            final currentQuestion = questions.isEmpty
                ? null
                : questions[_questionIndex.clamp(0, questions.length - 1)];
            final selectedAnswerLabel = _selectedAnswerLabels[_questionIndex];
            final isQuestionContentVisible = !_isLoading &&
                !_isSubmitting &&
                effectiveError == null &&
                currentQuestion != null;

            return Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: _isLoading || _isSubmitting
                        ? Colors.white
                        : _homeworkAttemptMint,
                  ),
                ),
                Positioned.fill(
                  top: _isLoading || _isSubmitting ? 0 : 80 * s,
                  bottom: _isLoading || _isSubmitting || effectiveError != null
                      ? 0
                      : 97 * s,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: effectiveError != null
                        ? _HomeworkAttemptErrorState(
                            key: const ValueKey('homework-error'),
                            scale: s,
                            message: effectiveError,
                            onRetry: _errorRetryAction ?? _loadDetail,
                          )
                        : _isSubmitting
                            ? _HomeworkAttemptLoader(
                                key: const ValueKey('homework-submit-loader'),
                                scale: s,
                                message:
                                    context.getText(AppKeys.submittingForYou),
                              )
                            : _isLoading
                                ? _HomeworkAttemptLoader(
                                    key: const ValueKey('homework-loader'),
                                    scale: s,
                                    message: context.getText(
                                      AppKeys.studentHomework,
                                    ),
                                  )
                                : SingleChildScrollView(
                                    key: const ValueKey('homework-content'),
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(
                                      24 * s,
                                      0,
                                      24 * s,
                                      24 * s,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _HomeworkAttemptProgressSection(
                                          scale: s,
                                          currentQuestion: _questionIndex + 1,
                                          totalQuestions: questions.length,
                                        ),
                                        SizedBox(height: 32 * s),
                                        _HomeworkAttemptQuestionCard(
                                          scale: s,
                                          question: currentQuestion!.prompt,
                                        ),
                                        SizedBox(height: 32 * s),
                                        _HomeworkAttemptAnswerGrid(
                                          scale: s,
                                          answers: currentQuestion.answers,
                                          selectedAnswerLabel:
                                              selectedAnswerLabel,
                                          onSelected: _selectAnswer,
                                        ),
                                      ],
                                    ),
                                  ),
                  ),
                ),
                if (!_isLoading && !_isSubmitting)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: _HomeworkAttemptHeader(scale: s),
                  ),
                if (isQuestionContentVisible)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _HomeworkAttemptBottomBar(
                      scale: s,
                      canGoBack: _questionIndex > 0,
                      isLastQuestion: _questionIndex >= questions.length - 1,
                      isSubmitting: _isSubmitting,
                      onBack: _goToPreviousQuestion,
                      onContinue: () => _goToNextQuestion(questions),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeworkAttemptHeader extends StatelessWidget {
  const _HomeworkAttemptHeader({required this.scale});

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
            color: _homeworkAttemptMint.withValues(alpha: 0.84),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(32 * scale),
            ),
            boxShadow: [
              BoxShadow(
                color: _homeworkAttemptInk.withValues(alpha: 0.05),
                blurRadius: 2 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              _HomeworkHeaderIconButton(
                icon: Icons.close_rounded,
                scale: scale,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Text(
                  context.getText(AppKeys.studentHomework),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _homeworkAttemptTeal,
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _HomeworkHeaderIconButton(
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

class _HomeworkHeaderIconButton extends StatelessWidget {
  const _HomeworkHeaderIconButton({
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
            color: _homeworkAttemptTeal,
            size: 22 * scale,
          ),
        ),
      ),
    );
  }
}

class _HomeworkAttemptProgressSection extends StatelessWidget {
  const _HomeworkAttemptProgressSection({
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
          context.formatText(AppKeys.questionProgress, {
            'current': currentQuestion,
            'total': totalQuestions,
          }),
          style: TextStyle(
            color: _homeworkAttemptMuted,
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
                  color: _homeworkAttemptPeach,
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
                    color: _homeworkAttemptProgress,
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

class _HomeworkAttemptQuestionCard extends StatelessWidget {
  const _HomeworkAttemptQuestionCard({
    required this.scale,
    required this.question,
  });

  final double scale;
  final String question;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 260 * scale),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 28 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32 * scale),
        border: Border.all(color: const Color(0xFFDCCACA)),
      ),
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _homeworkAttemptInk,
          fontSize: 36 * scale,
          fontWeight: FontWeight.w900,
          height: 1.16,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _HomeworkAttemptAnswerGrid extends StatelessWidget {
  const _HomeworkAttemptAnswerGrid({
    required this.scale,
    required this.answers,
    required this.selectedAnswerLabel,
    required this.onSelected,
  });

  final double scale;
  final List<_HomeworkAttemptAnswer> answers;
  final String? selectedAnswerLabel;
  final ValueChanged<_HomeworkAttemptAnswer> onSelected;

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
        mainAxisExtent: 96 * scale,
      ),
      itemBuilder: (context, index) {
        final answer = answers[index];
        return _HomeworkAttemptAnswerButton(
          answer: answer,
          selected: answer.label == selectedAnswerLabel,
          scale: scale,
          onTap: () => onSelected(answer),
        );
      },
    );
  }
}

class _HomeworkAttemptAnswerButton extends StatelessWidget {
  const _HomeworkAttemptAnswerButton({
    required this.answer,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final _HomeworkAttemptAnswer answer;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? _homeworkAttemptTeal : Colors.black.withValues(alpha: 0);
    final textColor = selected ? _homeworkAttemptTeal : _homeworkAttemptInk;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(32 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32 * scale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
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
          child: Row(
            children: [
              Text(
                answer.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  answer.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: 0,
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

class _HomeworkAttemptBottomBar extends StatelessWidget {
  const _HomeworkAttemptBottomBar({
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
            color: _homeworkAttemptMint.withValues(alpha: 0.90),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFCDE2CF).withValues(alpha: 0.30),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _HomeworkBottomActionButton(
                  label: context.getText(AppKeys.previousQuestionUpper),
                  icon: Icons.arrow_back_rounded,
                  background: _homeworkAttemptPeach.withValues(alpha: 0.50),
                  foreground: _homeworkAttemptRust,
                  scale: scale,
                  onTap: canGoBack && !isSubmitting ? onBack : null,
                ),
              ),
              SizedBox(width: 48 * scale),
              Expanded(
                child: _HomeworkBottomActionButton(
                  label: isSubmitting
                      ? context.getText(AppKeys.submittingUpper)
                      : isLastQuestion
                          ? context.getText(AppKeys.submitUpper)
                          : context.getText(AppKeys.continueUpper),
                  icon: isLastQuestion
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  foreground: const Color(0xFFBEFFF9),
                  scale: scale,
                  onTap: isSubmitting ? null : onContinue,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_homeworkAttemptTeal, Color(0xFF73F1E7)],
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

class _HomeworkBottomActionButton extends StatelessWidget {
  const _HomeworkBottomActionButton({
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
                      color: _homeworkAttemptTeal.withValues(alpha: 0.20),
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
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeworkAttemptErrorState extends StatelessWidget {
  const _HomeworkAttemptErrorState({
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
                color: _homeworkAttemptPeach.withValues(alpha: 0.58),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: _homeworkAttemptRust,
                size: 34 * scale,
              ),
            ),
            SizedBox(height: 20 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _homeworkAttemptMuted,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w800,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 24 * scale),
            SizedBox(
              width: 168 * scale,
              child: _HomeworkBottomActionButton(
                label: context.getText(AppKeys.retryUpper),
                icon: Icons.refresh_rounded,
                foreground: const Color(0xFFBEFFF9),
                scale: scale,
                onTap: onRetry,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_homeworkAttemptTeal, Color(0xFF73F1E7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeworkAttemptLoader extends StatefulWidget {
  const _HomeworkAttemptLoader({
    super.key,
    required this.scale,
    this.message,
  });

  final double scale;
  final String? message;

  @override
  State<_HomeworkAttemptLoader> createState() => _HomeworkAttemptLoaderState();
}

class _HomeworkAttemptLoaderState extends State<_HomeworkAttemptLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const letters = ['n', 'u', 'm', 'i', 'n', 'u', 'm', 'i'];

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(letters.length, (index) {
                  final delayedProgress =
                      (_controller.value - (index * 0.075)) % 1.0;
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
                        color: _homeworkAttemptTeal,
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
                      color: _homeworkAttemptMuted,
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

class _HomeworkAttemptQuestion {
  const _HomeworkAttemptQuestion({
    required this.questionNumber,
    required this.prompt,
    required this.answers,
  });

  final int questionNumber;
  final String prompt;
  final List<_HomeworkAttemptAnswer> answers;
}

class _HomeworkAttemptAnswer {
  const _HomeworkAttemptAnswer({
    required this.label,
    required this.content,
  });

  final String label;
  final String content;
}

List<_HomeworkAttemptQuestion> _attemptQuestions(
  ClassroomExercise? exercise,
) {
  final questions = exercise?.questions ?? const <ClassroomExerciseQuestion>[];
  return <_HomeworkAttemptQuestion>[
    for (var index = 0; index < questions.length; index++)
      _HomeworkAttemptQuestion(
        questionNumber: questions[index].questionNumber ?? index + 1,
        prompt: questions[index].displayPrompt ?? '',
        answers: <_HomeworkAttemptAnswer>[
          for (var answerIndex = 0;
              answerIndex < questions[index].answers.length;
              answerIndex++)
            if (questions[index].answers[answerIndex].trim().isNotEmpty)
              _HomeworkAttemptAnswer(
                label: _answerLabel(answerIndex),
                content: questions[index].answers[answerIndex].trim(),
              ),
        ],
      ),
  ];
}

String? _questionDataError(
  BuildContext context,
  List<_HomeworkAttemptQuestion> questions,
) {
  if (questions.isEmpty) {
    return context.getText(AppKeys.studentHomeworkNoQuestions);
  }
  if (questions.any((question) => question.answers.isEmpty)) {
    return context.getText(AppKeys.studentHomeworkQuestionMissingAnswers);
  }
  return null;
}

String _answerLabel(int index) {
  if (index >= 0 && index < 26) {
    return String.fromCharCode(65 + index);
  }
  return (index + 1).toString();
}
