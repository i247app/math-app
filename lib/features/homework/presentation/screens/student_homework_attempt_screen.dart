import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/data/cache/student_homework_cache.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/homework/presentation/screens/student_homework_result_screen.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_answer_grid.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_bottom_bar.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_error_state.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_header.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_helpers.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_loading_skeleton.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_progress_section.dart';
import 'package:numi/features/homework/widgets/student_attempt/student_homework_attempt_question_card.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/widgets/student_result/student_homework_result_helpers.dart';
import 'package:numi/features/quiz/widgets/shared/quiz_wave_loader.dart';
import 'package:numi/features/quiz/widgets/shared/attempt_exit_dialog.dart';
import 'package:numi/features/homework/errors/classroom_exercise_exception.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

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
      widget._exerciseService ?? context.read<ClassroomExerciseService>();
  final GuardedExitController<bool> _exitController =
      GuardedExitController<bool>();

  ClassroomExercise? _exercise;
  int _questionIndex = 0;
  final Map<int, String> _selectedAnswerLabels = <int, String>{};
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  VoidCallback? _errorRetryAction;

  @override
  void initState() {
    super.initState();
    _exercise = widget.initialExercise;
    final initialExercise = widget.initialExercise;
    if (initialExercise != null) {
      StudentHomeworkCache.seedDetail(
        profileId: widget.profileId,
        exercise: initialExercise,
      );
    }
    _loadDetail();
  }

  Future<void> _loadDetail({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedExercise = StudentHomeworkCache.peekFullDetail(
        exerciseId: widget.exerciseId,
        profileId: widget.profileId,
      );
      if (cachedExercise != null) {
        setState(() {
          _exercise = cachedExercise;
          _isLoading = true;
          _errorMessage = null;
          _errorRetryAction = null;
        });
        await _loadDetail(forceRefresh: true);
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorRetryAction = null;
    });

    try {
      final exercise = await StudentHomeworkCache.loadDetail(
        service: _exerciseService,
        exerciseId: widget.exerciseId,
        profileId: widget.profileId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      final shouldResetProgress =
          !forceRefresh || _exercise == null || _selectedAnswerLabels.isEmpty;
      setState(() {
        _exercise = exercise ?? _exercise;
        if (shouldResetProgress) {
          _questionIndex = 0;
          _selectedAnswerLabels.clear();
        }
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

  void _selectAnswer(StudentHomeworkAttemptAnswer answer) {
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

  void _goToNextQuestion(List<StudentHomeworkAttemptQuestion> questions) {
    if (_questionIndex >= questions.length - 1) {
      _submitHomework(questions);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _questionIndex++);
  }

  Future<void> _submitHomework(
    List<StudentHomeworkAttemptQuestion> questions,
  ) async {
    if (_isSubmitting) {
      return;
    }

    final exerciseId = (_exercise?.stableId ?? widget.exerciseId);
    if (exerciseId <= 0) {
      setState(() {
        _errorMessage = context.readText(
          AppKeys.studentHomeworkMissingExercise,
        );
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
          answer: questions[index].selectedAnswerContent(
            _selectedAnswerLabels[index]!,
          ),
          answerContent: questions[index].selectedAnswerContent(
            _selectedAnswerLabels[index]!,
          ),
        ),
    ];

    HapticFeedback.mediumImpact();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _errorRetryAction = null;
    });

    var shouldResetSubmitting = true;
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
          _errorMessage = context.readText(
            AppKeys.studentHomeworkMissingExercise,
          );
          _errorRetryAction = null;
        });
        return;
      }
      StudentHomeworkCache.markSubmitted(
        profileId: widget.profileId,
        exercise: exercise,
      );
      Navigator.of(context).pushReplacement<bool, void>(
        MaterialPageRoute<bool>(
          builder: (_) => StudentHomeworkResultScreen(
            summary: studentHomeworkResultSummary(submission: submission),
          ),
        ),
      );
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      if (error.status == 12706) {
        shouldResetSubmitting = false;
        await _returnFromNotOpenHomework();
      } else {
        setState(() {
          _errorMessage = error.message.trim().isEmpty
              ? context.readText(AppKeys.studentHomeworkSubmitFailed)
              : error.message;
          _errorRetryAction = () => _submitHomework(questions);
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppStrings.current(AppKeys.studentHomeworkSubmitFailed);
        _errorRetryAction = () => _submitHomework(questions);
      });
    } finally {
      if (mounted && shouldResetSubmitting) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _returnFromNotOpenHomework() async {
    final message = context.readText(AppKeys.studentHomeworkNotOpen);
    await context.showErrorDialog(message);
    if (!mounted) {
      return;
    }
    await _exitController.exit();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomBarHeight =
        StudentHomeworkAttemptBottomBar.contentHeight + bottomInset;

    final hasActiveAttempt = studentHomeworkAttemptQuestions(
      _exercise,
    ).isNotEmpty;
    final screen = Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Builder(
              builder: (context) {
                final questions = studentHomeworkAttemptQuestions(_exercise);
                final questionError = _isLoading
                    ? null
                    : studentHomeworkAttemptQuestionDataError(
                        context,
                        questions,
                      );
                final effectiveError = _errorMessage ?? questionError;
                final currentQuestion = questions.isEmpty
                    ? null
                    : questions[_questionIndex.clamp(0, questions.length - 1)];
                final selectedAnswerLabel =
                    _selectedAnswerLabels[_questionIndex];
                final isQuestionContentVisible =
                    !_isLoading &&
                    !_isSubmitting &&
                    effectiveError == null &&
                    currentQuestion != null;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: ColoredBox(
                        color: _isLoading || _isSubmitting
                            ? colors.surface
                            : colors.pageBackground,
                      ),
                    ),
                    Positioned.fill(
                      top: _isLoading || _isSubmitting ? 0 : 80,
                      bottom:
                          _isLoading || _isSubmitting || effectiveError != null
                          ? 0
                          : bottomBarHeight,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: effectiveError != null
                            ? StudentHomeworkAttemptErrorState(
                                key: const ValueKey('homework-error'),
                                message: effectiveError,
                                onRetry: _errorRetryAction ?? _loadDetail,
                              )
                            : _isSubmitting
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
                            : _isLoading
                            ? const StudentHomeworkAttemptLoadingSkeleton(
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
                                    StudentHomeworkAttemptProgressSection(
                                      currentQuestion: _questionIndex + 1,
                                      totalQuestions: questions.length,
                                    ),
                                    StudentHomeworkAttemptQuestionCard(
                                      question: currentQuestion!.prompt,
                                    ),
                                    StudentHomeworkAttemptAnswerGrid(
                                      answers: currentQuestion.answers,
                                      selectedAnswerLabel: selectedAnswerLabel,
                                      onSelected: _selectAnswer,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    if (!_isSubmitting)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: StudentHomeworkAttemptHeader(
                          onClose: _exitController.requestExit,
                        ),
                      ),
                    if (isQuestionContentVisible)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: StudentHomeworkAttemptBottomBar(
                          bottomInset: bottomInset,
                          canGoBack: _questionIndex > 0,
                          isLastQuestion:
                              _questionIndex >= questions.length - 1,
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
        ),
      ),
    );

    return GuardedExitScope<bool>(
      controller: _exitController,
      shouldConfirm: hasActiveAttempt,
      isExitBlocked: _isSubmitting,
      confirmExit: showAttemptExitDialog,
      exitResult: false,
      child: screen,
    );
  }
}
