import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/features/homework/cache/student_homework_cache.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/homework/presentation/student_homework_result_screen.dart';

part '../widgets/student_attempt/student_homework_attempt_header.dart';
part '../widgets/student_attempt/student_homework_attempt_header_icon_button.dart';
part '../widgets/student_attempt/student_homework_attempt_progress_section.dart';
part '../widgets/student_attempt/student_homework_attempt_question_card.dart';
part '../widgets/student_attempt/student_homework_attempt_answer_grid.dart';
part '../widgets/student_attempt/student_homework_attempt_answer_button.dart';
part '../widgets/student_attempt/student_homework_attempt_bottom_bar.dart';
part '../widgets/student_attempt/student_homework_attempt_bottom_action_button.dart';
part '../widgets/student_attempt/student_homework_attempt_error_state.dart';
part '../widgets/student_attempt/student_homework_attempt_loader.dart';
part '../widgets/student_attempt/student_homework_attempt_helpers.dart';

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

  void _selectAnswer(_StudentHomeworkAttemptAnswer answer) {
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

  void _goToNextQuestion(List<_StudentHomeworkAttemptQuestion> questions) {
    if (_questionIndex >= questions.length - 1) {
      _submitHomework(questions);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _questionIndex++);
  }

  Future<void> _submitHomework(
    List<_StudentHomeworkAttemptQuestion> questions,
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
        _returnFromNotOpenHomework();
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

  void _returnFromNotOpenHomework() {
    final message = context.readText(AppKeys.studentHomeworkNotOpen);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
    Navigator.of(context).maybePop();
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
            final questionError = _isLoading
                ? null
                : _questionDataError(context, questions);
            final effectiveError = _errorMessage ?? questionError;
            final currentQuestion = questions.isEmpty
                ? null
                : questions[_questionIndex.clamp(0, questions.length - 1)];
            final selectedAnswerLabel = _selectedAnswerLabels[_questionIndex];
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
                        ? _StudentHomeworkAttemptErrorState(
                            key: const ValueKey('homework-error'),
                            scale: s,
                            message: effectiveError,
                            onRetry: _errorRetryAction ?? _loadDetail,
                          )
                        : _isSubmitting
                        ? _StudentHomeworkAttemptLoader(
                            key: const ValueKey('homework-submit-loader'),
                            scale: s,
                            message: context.getText(AppKeys.submittingForYou),
                          )
                        : _isLoading
                        ? _StudentHomeworkAttemptLoader(
                            key: const ValueKey('homework-loader'),
                            scale: s,
                            message: context.getText(AppKeys.studentHomework),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _StudentHomeworkAttemptProgressSection(
                                  scale: s,
                                  currentQuestion: _questionIndex + 1,
                                  totalQuestions: questions.length,
                                ),
                                SizedBox(height: 32 * s),
                                _StudentHomeworkAttemptQuestionCard(
                                  scale: s,
                                  question: currentQuestion!.prompt,
                                ),
                                SizedBox(height: 32 * s),
                                _StudentHomeworkAttemptAnswerGrid(
                                  scale: s,
                                  answers: currentQuestion.answers,
                                  selectedAnswerLabel: selectedAnswerLabel,
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
                    child: _StudentHomeworkAttemptHeader(scale: s),
                  ),
                if (isQuestionContentVisible)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _StudentHomeworkAttemptBottomBar(
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
