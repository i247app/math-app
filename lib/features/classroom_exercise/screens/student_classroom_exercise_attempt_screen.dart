import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/controllers/student_classroom_exercise_attempt_controller.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/screens/student_classroom_exercise_result_screen.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_answer_grid.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_bottom_bar.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_error_state.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_header.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_helpers.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_loading_skeleton.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_progress_section.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_question_card.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom_exercise/widgets/student_result/student_classroom_exercise_result_helpers.dart';
import 'package:numi/features/quiz/widgets/shared/quiz_wave_loader.dart';
import 'package:numi/features/quiz/widgets/shared/attempt_exit_dialog.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

class StudentClassroomExerciseAttemptScreen extends StatefulWidget {
  const StudentClassroomExerciseAttemptScreen({
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
  State<StudentClassroomExerciseAttemptScreen> createState() =>
      _StudentClassroomExerciseAttemptScreenState();
}

class _StudentClassroomExerciseAttemptScreenState
    extends State<StudentClassroomExerciseAttemptScreen> {
  late final StudentClassroomExerciseAttemptController _controller;
  final GuardedExitController<bool> _exitController =
      GuardedExitController<bool>();

  @override
  void initState() {
    super.initState();
    _controller = StudentClassroomExerciseAttemptController(
      exerciseId: widget.exerciseId,
      profileId: widget.profileId,
      exerciseService:
          widget._exerciseService ?? context.read<ClassroomExerciseService>(),
      initialExercise: widget.initialExercise,
    );
    _controller.loadDetail();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectAnswer(StudentClassroomExerciseAttemptAnswer answer) {
    HapticFeedback.selectionClick();
    _controller.selectAnswer(answer);
  }

  void _goToPreviousQuestion() {
    HapticFeedback.selectionClick();
    _controller.goToPreviousQuestion();
  }

  void _goToNextQuestion() {
    if (_controller.isLastQuestion) {
      _submitClassroomExercise();
      return;
    }
    HapticFeedback.mediumImpact();
    _controller.goToNextQuestion();
  }

  Future<void> _submitClassroomExercise() async {
    if (_controller.isSubmitting) return;
    final pendingSubmission = _controller.submit();
    if (_controller.isSubmitting) {
      HapticFeedback.mediumImpact();
    }
    final result = await pendingSubmission;
    if (!mounted) return;

    switch (result.status) {
      case StudentClassroomExerciseSubmitStatus.submitted:
        Navigator.of(context).pushReplacement<bool, void>(
          MaterialPageRoute<bool>(
            builder: (_) => StudentClassroomExerciseResultScreen(
              summary: studentClassroomExerciseResultSummary(
                submission: result.submission!,
              ),
            ),
          ),
        );
      case StudentClassroomExerciseSubmitStatus.unanswered:
        HapticFeedback.selectionClick();
      case StudentClassroomExerciseSubmitStatus.notOpen:
        await _returnFromNotOpenClassroomExercise();
      case StudentClassroomExerciseSubmitStatus.missingExercise:
      case StudentClassroomExerciseSubmitStatus.failed:
      case StudentClassroomExerciseSubmitStatus.ignored:
        break;
    }
  }

  void _retry() {
    if (_controller.retryAction == StudentClassroomExerciseRetryAction.submit) {
      _submitClassroomExercise();
    } else {
      _controller.loadDetail();
    }
  }

  String? _errorText(BuildContext context) {
    final message = _controller.errorMessage;
    if (message != null) return message;
    return switch (_controller.error) {
      StudentClassroomExerciseAttemptError.loadFailed => context.getText(
        AppKeys.studentClassroomExerciseLoadFailed,
      ),
      StudentClassroomExerciseAttemptError.submitFailed => context.getText(
        AppKeys.studentClassroomExerciseSubmitFailed,
      ),
      StudentClassroomExerciseAttemptError.missingExercise => context.getText(
        AppKeys.studentClassroomExerciseMissingExercise,
      ),
      null => null,
    };
  }

  Future<void> _returnFromNotOpenClassroomExercise() async {
    final message = context.readText(AppKeys.studentClassroomExerciseNotOpen);
    await context.showErrorDialog(message);
    if (!mounted) {
      return;
    }
    await _exitController.exit();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final isLoading = _controller.isLoading;
    final isSubmitting = _controller.isSubmitting;
    final questionIndex = _controller.questionIndex;
    final questions = _controller.questions;
    final colors = context.themeColors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomBarHeight =
        StudentClassroomExerciseAttemptBottomBar.contentHeight + bottomInset;

    final hasActiveAttempt = questions.isNotEmpty;
    final screen = Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Builder(
              builder: (context) {
                final questionError = isLoading
                    ? null
                    : studentClassroomExerciseAttemptQuestionDataError(
                        context,
                        questions,
                      );
                final effectiveError = _errorText(context) ?? questionError;
                final currentQuestion = questions.isEmpty
                    ? null
                    : questions[questionIndex.clamp(0, questions.length - 1)];
                final selectedAnswerLabel = _controller.selectedAnswerLabel;
                final isQuestionContentVisible =
                    !isLoading &&
                    !isSubmitting &&
                    effectiveError == null &&
                    currentQuestion != null;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: ColoredBox(
                        color: isLoading || isSubmitting
                            ? colors.surface
                            : colors.pageBackground,
                      ),
                    ),
                    Positioned.fill(
                      top: isLoading || isSubmitting ? 0 : 80,
                      bottom:
                          isLoading || isSubmitting || effectiveError != null
                          ? 0
                          : bottomBarHeight,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: effectiveError != null
                            ? StudentClassroomExerciseAttemptErrorState(
                                key: const ValueKey('homework-error'),
                                message: effectiveError,
                                onRetry: _retry,
                              )
                            : isSubmitting
                            ? QuizWaveLoader(
                                key: const ValueKey('homework-submit-loader'),
                                message: context.getText(
                                  AppKeys.submittingForYou,
                                ),
                                letterStyle: TextStyle(
                                  color: colors.brandStrong,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  letterSpacing: 3,
                                ),
                                messageStyle: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: FontSize.normal,
                                  fontWeight: FontWeight.w800,
                                  height: 1.35,
                                  letterSpacing: 0,
                                ),
                              )
                            : isLoading
                            ? const StudentClassroomExerciseAttemptLoadingSkeleton(
                                key: ValueKey('homework-loader'),
                              )
                            : SingleChildScrollView(
                                key: const ValueKey('homework-content'),
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
                                    StudentClassroomExerciseAttemptProgressSection(
                                      currentQuestion: questionIndex + 1,
                                      totalQuestions: questions.length,
                                    ),
                                    StudentClassroomExerciseAttemptQuestionCard(
                                      question: currentQuestion!.prompt,
                                    ),
                                    StudentClassroomExerciseAttemptAnswerGrid(
                                      answers: currentQuestion.answers,
                                      selectedAnswerLabel: selectedAnswerLabel,
                                      onSelected: _selectAnswer,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    if (!isSubmitting)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: StudentClassroomExerciseAttemptHeader(
                          onClose: _exitController.requestExit,
                        ),
                      ),
                    if (isQuestionContentVisible)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: StudentClassroomExerciseAttemptBottomBar(
                          bottomInset: bottomInset,
                          canGoBack: questionIndex > 0,
                          isLastQuestion: questionIndex >= questions.length - 1,
                          isSubmitting: isSubmitting,
                          onBack: _goToPreviousQuestion,
                          onContinue: _goToNextQuestion,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    return GuardedExitScope<bool>(
      controller: _exitController,
      shouldConfirm: hasActiveAttempt,
      isExitBlocked: isSubmitting,
      confirmExit: showAttemptExitDialog,
      exitResult: false,
      child: screen,
    );
  }
}
