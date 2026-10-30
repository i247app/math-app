import 'package:numi/features/exam/widgets/shared/exam_numeric_input.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/grade_exam_completion.dart';
import 'package:numi/features/exam/controllers/exam_attempt_controller.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_question_speech_service.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/assessment_journey_completion.dart';
import 'package:numi/features/exam/screens/practice_result_screen.dart';
import 'package:numi/features/exam/screens/assessment_placement_result_screen.dart';
import 'package:numi/features/exam/screens/exam_review_screen.dart';
import 'package:numi/features/exam/screens/grade_roadmap_screen.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_grid.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_bottom_bar.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_error_state.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_generating_loader.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_set_transition_loader.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_header.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_progress_section.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_question_card.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_image_match_card.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_question_skeleton.dart';
import 'package:numi/features/exam/widgets/shared/attempt_exit_dialog.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

enum ExamAttemptResult { generationFailed }

class ExamAttemptScreen extends StatefulWidget {
  const ExamAttemptScreen({
    super.key,
    this.examService,
    this.initialExam,
    this.examType = examTypeAssessment,
    this.gradeLabel,
    this.level,
    this.profileId,
    this.startAtKindergarten = true,
    this.onResultBack,
    this.onGradeCompleted,
    this.allowQuestionNavigation = true,
    this.showQuestionNavigation = true,
    this.allowReviewPractice = true,
    this.isResumedAssessment = false,
    this.gradeProgressStore,
  });

  final ExamService? examService;
  final GeneratedExam? initialExam;
  final String examType;
  final String? gradeLabel;
  final int? level;
  final int? profileId;

  /// Direct placement starts at grade 0; explicit grade-selection can opt out.
  final bool startAtKindergarten;
  final VoidCallback? onResultBack;
  final ValueChanged<GradeExamCompletion>? onGradeCompleted;
  final bool allowQuestionNavigation;
  final bool showQuestionNavigation;
  final bool allowReviewPractice;
  final bool isResumedAssessment;
  final ProfileGradeProgressStore? gradeProgressStore;

  @override
  State<ExamAttemptScreen> createState() => _ExamAttemptScreenState();
}

class _ExamAttemptScreenState extends State<ExamAttemptScreen>
    with WidgetsBindingObserver {
  late final ExamAttemptController _controller;
  late final ProfileGradeProgressStore _gradeProgressStore;
  Timer? _practiceFeedbackTimer;
  bool _isCompletingAssessment = false;
  final _questionSpeech = ExamQuestionSpeechService();
  Object? _spokenQuestionKey;
  bool _speechSuspended = false;

  int? get _questionGrade => questionSpeechGrade(
    questionGrade: _controller.currentQuestion?.questionGrade,
    examGrade: _controller.exam?.grade,
  );

  bool get _canReadQuestion =>
      !_speechSuspended &&
      !_controller.isGeneratingQuestion &&
      !_controller.isGeneratingExam &&
      !_controller.isSubmittingExam &&
      !_isCompletingAssessment &&
      _controller.errorMessage == null &&
      _questionGrade == 0 &&
      questionSpeechText(_controller.currentQuestion?.questionText ?? '') !=
          null;
  final GuardedExitController<ExamAttemptResult> _exitController =
      GuardedExitController<ExamAttemptResult>();

  @override
  void initState() {
    super.initState();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _speechSuspended =
        lifecycle != null && lifecycle != AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _controller = ExamAttemptController(
      examService: widget.examService ?? context.read<ExamService>(),
      initialExam: widget.initialExam,
      examType: widget.examType,
      gradeLabel: widget.gradeLabel,
      level: widget.level,
      profileId: widget.profileId,
      startAtKindergarten: widget.startAtKindergarten,
    );
    _gradeProgressStore =
        widget.gradeProgressStore ?? const SecureProfileGradeProgressStore();
    _controller.addListener(_syncQuestionSpeech);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncQuestionSpeech();
    });
    if (widget.initialExam == null) {
      generateExam();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_syncQuestionSpeech);
    _questionSpeech.dispose();
    _practiceFeedbackTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _speechSuspended = state != AppLifecycleState.resumed;
    if (_speechSuspended) unawaited(_questionSpeech.stop());
    // Returning to the app allows replay without automatically repeating a prompt.
    if (mounted) setState(() {});
  }

  void _syncQuestionSpeech() {
    final question = _controller.currentQuestion;
    final key = (
      _controller.exam?.examId,
      _controller.exam?.aiExamId,
      _controller.setNumber,
      _controller.questionIndex,
      question?.questionNumber,
      question?.questionText,
      _questionGrade,
    );
    if (!_canReadQuestion) {
      if (_spokenQuestionKey != key) _spokenQuestionKey = null;
      unawaited(_questionSpeech.stop());
      return;
    }
    if (_spokenQuestionKey == key) return;
    _spokenQuestionKey = key;
    unawaited(_readQuestion());
  }

  Future<void> _readQuestion({bool manual = false}) async {
    if (!_canReadQuestion || ModalRoute.of(context)?.isCurrent == false) return;
    final result = await _questionSpeech.read(
      _controller.currentQuestion!.questionText,
      language: AppLanguageState.currentApiCode,
    );
    if (mounted && manual && result == QuestionSpeechResult.unavailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.getText(AppKeys.examSpeechUnavailable))),
      );
    }
  }

  Future<void> generateExam() async {
    final generated = await _controller.generateExam();
    if (!mounted || generated || _controller.hasRecoverablePaperError) {
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(ExamAttemptResult.generationFailed);
    }
  }

  void selectAnswer(ExamAnswer answer) {
    HapticFeedback.selectionClick();
    _controller.selectAnswer(answer);
    if (_controller.isPractice) {
      _practiceFeedbackTimer?.cancel();
      if (_controller.selectedAnswerFeedbackCorrect != null) {
        final questionIndex = _controller.questionIndex;
        _practiceFeedbackTimer = Timer(
          const Duration(milliseconds: 650),
          () => _controller.clearPracticeFeedback(questionIndex: questionIndex),
        );
      }
      return;
    }
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

  void handleContinue() {
    unawaited(_advanceExamFlow());
  }

  Future<void> _advanceExamFlow() async {
    if ((_controller.isAssessment ||
            _controller.isPractice ||
            _controller.isGrade) &&
        !_controller.canContinue) {
      HapticFeedback.selectionClick();
      return;
    }

    if (_controller.isPractice) {
      HapticFeedback.mediumImpact();
      final action = _controller.preparePracticeFlow();
      if (action == AssessmentFlowAction.submit) {
        await submitCurrentExam();
        return;
      }
      _moveToNextQuestion();
      return;
    }

    if (_controller.isGrade) {
      HapticFeedback.mediumImpact();
      if (_controller.prepareGradeFlow() == AssessmentFlowAction.submit) {
        await submitCurrentExam();
        return;
      }
      _moveToNextQuestion();
      return;
    }

    if (!_controller.isAssessment) {
      if (_controller.allQuestionsAnswered) {
        await submitCurrentExam();
        return;
      }
      HapticFeedback.mediumImpact();
      _moveToNextQuestion();
      return;
    }

    HapticFeedback.mediumImpact();
    final action = await _controller.advanceAssessmentFlow();
    if (!mounted) {
      return;
    }
    if (action == AssessmentFlowAction.submit) {
      await submitCurrentExam();
      return;
    }
    if (action == AssessmentFlowAction.generateSet) {
      return;
    }
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

  Future<void> submitCurrentExam() async {
    unawaited(_questionSpeech.stop());
    HapticFeedback.mediumImpact();
    final isGradeSubmission = _controller.isGrade;
    if (isGradeSubmission && mounted) {
      setState(() => _isCompletingAssessment = true);
    }
    ProfileGradeProgress? savedGradeProgress;
    if (_controller.isGrade) {
      try {
        savedGradeProgress = await _gradeProgressStore.read(
          widget.profileId ?? _controller.exam?.profileId ?? 0,
        );
      } catch (_) {
        savedGradeProgress = ProfileGradeProgress.initial;
      }
    }
    final gradeOutcome = savedGradeProgress == null
        ? null
        : _controller.gradeOutcome(savedGradeProgress);
    final result = await _controller.submitCurrentExam();
    if (!mounted || result.status != ExamAttemptSubmitStatus.submitted) {
      if (mounted && isGradeSubmission) {
        setState(() => _isCompletingAssessment = false);
      }
      if (result.status == ExamAttemptSubmitStatus.unanswered) {
        HapticFeedback.selectionClick();
      }
      return;
    }

    final navigator = Navigator.of(context);
    final examService = _controller.examService;
    final finalGrade = gradeOutcome?.progress.grade ?? _controller.currentGrade;
    final finalLevel = gradeOutcome?.progress.level ?? _controller.currentLevel;
    final gradeLabel = AssessmentFlowPolicy.gradeLabel(finalGrade);
    final correctAnswers = _controller.totalCorrectAnswerCount;
    final totalQuestions = _controller.totalAnsweredQuestionCount;
    final profileId = widget.profileId;
    final onResultBack = widget.onResultBack;
    final allowQuestionNavigation = widget.allowQuestionNavigation;
    final showQuestionNavigation = widget.showQuestionNavigation;
    final submittedExam = result.exam!;
    final submittedUserExamId =
        submittedExam.userExamId ?? _controller.userExamId;
    final submittedExamId = submittedExam.examId ?? submittedExam.userAiExamId;
    final reviewDetailId = submittedUserExamId ?? submittedExamId;
    var practiceWeakTopics = submittedExam.practiceWeakTopics;
    if (_controller.isAssessment || _controller.isGrade) {
      setState(() => _isCompletingAssessment = true);
      try {
        await completeAssessmentJourney(
          examService: examService,
          userExamId: submittedUserExamId,
          profileId: profileId ?? submittedExam.profileId,
          esessFlag: gradeOutcome?.passed,
        );
      } on Exception catch (error) {
        if (!mounted) {
          return;
        }
        setState(() => _isCompletingAssessment = false);
        _showAssessmentCompletionError(error);
        return;
      }
      if (!mounted) return;
      if (_controller.isGrade && gradeOutcome != null) {
        final resolvedProfileId =
            profileId ?? submittedExam.profileId ?? _controller.exam?.profileId;
        if (gradeOutcome.passed) {
          try {
            await _gradeProgressStore.save(
              resolvedProfileId ?? 0,
              gradeOutcome.progress,
            );
          } catch (_) {
            // Server completion remains authoritative if local persistence fails.
          }
        }
        if (!mounted) return;
        final completion = GradeExamCompletion(
          exam: GeneratedExam(
            examId: submittedExamId ?? _controller.exam?.examId,
            userAiExamId: submittedExam.userAiExamId,
            userExamId: submittedUserExamId,
            profileId: resolvedProfileId,
            createDt: submittedExam.createDt ?? _controller.exam?.createDt,
            modifyDt: submittedExam.modifyDt,
            submittedDt: submittedExam.submittedDt,
            grading: submittedExam.grading,
            title: submittedExam.title,
            shortText: submittedExam.shortText,
            aiReviewShort: submittedExam.aiReviewShort,
            aiReviewLong: submittedExam.aiReviewLong,
            questions: const <ExamQuestion>[],
          ),
          grade: _controller.currentGrade,
          level: _controller.currentLevel,
          outcome: gradeOutcome,
        );
        final onGradeCompleted = widget.onGradeCompleted;
        if (onGradeCompleted != null) {
          onGradeCompleted(completion);
          await _exitController.exit();
        } else {
          navigator.pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => GradeRoadmapScreen(
                profileId: resolvedProfileId ?? 0,
                examService: examService,
                gradeProgressStore: _gradeProgressStore,
                initialCompletion: completion,
              ),
            ),
          );
        }
        return;
      }
      if (submittedUserExamId != null && submittedUserExamId > 0) {
        try {
          final journeyDetail = await examService.getExamDetail(
            submittedUserExamId,
            profileId: profileId ?? submittedExam.profileId,
            userExamId: submittedUserExamId,
            examType: widget.examType,
          );
          if (journeyDetail.practiceWeakTopics.isNotEmpty) {
            practiceWeakTopics = journeyDetail.practiceWeakTopics;
          }
        } catch (_) {
          // The result remains usable with topics returned by submission.
        }
      }
      if (!mounted) return;
    }

    if (_controller.isPractice) {
      navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (resultContext) {
            return PracticeResultScreen(
              grade: finalGrade,
              correctAnswers: correctAnswers,
              totalQuestions: totalQuestions,
              examService: examService,
              profileId: profileId,
              userExamId: submittedUserExamId,
              onViewDetails: submittedExamId == null
                  ? null
                  : () {
                      Navigator.of(resultContext).push(
                        MaterialPageRoute<void>(
                          builder: (_) => RepositoryProvider<ExamService>.value(
                            value: examService,
                            child: ExamReviewScreen(
                              examId: submittedExamId,
                              profileId: profileId ?? submittedExam.profileId,
                              examType: widget.examType,
                              initialExam: submittedExam,
                            ),
                          ),
                        ),
                      );
                    },
              onPracticeAgainGenerated: (generatedExam) {
                Navigator.of(resultContext).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => ExamAttemptScreen(
                      examService: examService,
                      initialExam: generatedExam,
                      examType: examTypePractice,
                      gradeLabel: gradeLabel,
                      profileId: profileId,
                      onResultBack: onResultBack,
                      allowQuestionNavigation: allowQuestionNavigation,
                      showQuestionNavigation: showQuestionNavigation,
                    ),
                  ),
                );
              },
              onBack: onResultBack,
            );
          },
        ),
      );
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (resultContext) {
          return AssessmentPlacementResultScreen(
            grade: finalGrade,
            level: _controller.isGrade ? finalLevel : null,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            examType: widget.examType,
            examService: examService,
            profileId: profileId ?? submittedExam.profileId,
            userExamId: submittedUserExamId,
            previousGrade: _controller.completedSets.isNotEmpty
                ? _controller.completedSets.first.grade
                : (savedGradeProgress?.grade ?? _controller.currentGrade),
            practiceWeakTopics: practiceWeakTopics,
            onViewDetails: reviewDetailId == null
                ? null
                : () {
                    Navigator.of(resultContext).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RepositoryProvider<ExamService>.value(
                          value: examService,
                          child: ExamReviewScreen(
                            examId: submittedUserExamId == null
                                ? submittedExamId
                                : null,
                            userExamId: submittedUserExamId,
                            profileId: profileId ?? submittedExam.profileId,
                            examType: widget.examType,
                            initialExam: submittedUserExamId == null
                                ? submittedExam
                                : null,
                            allowPractice: widget.allowReviewPractice,
                          ),
                        ),
                      ),
                    );
                  },
            onTestAgainGenerated: (generatedExam) {
              Navigator.of(resultContext).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => ExamAttemptScreen(
                    examService: examService,
                    initialExam: generatedExam,
                    examType: widget.examType,
                    gradeLabel: gradeLabel,
                    level: finalLevel,
                    profileId: profileId,
                    onResultBack: onResultBack,
                    allowQuestionNavigation: allowQuestionNavigation,
                    showQuestionNavigation: showQuestionNavigation,
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

  void _showAssessmentCompletionError(Object error) {
    final message = error is ExamException
        ? error.message
        : context.readText(AppKeys.assessmentStatusUpdateFailed);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.getText(AppKeys.assessmentResultTitle)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.getText(AppKeys.close)),
          ),
        ],
      ),
    );
  }

  Future<void> retryErrorAction() {
    return switch (_controller.errorRetryAction) {
      ExamAttemptRetryAction.submit => submitCurrentExam(),
      _ => retryGeneration(),
    };
  }

  Future<void> retryGeneration() async {
    final isInitialGeneration = _controller.exam == null;
    final generated = await _controller.retryGeneration();
    if (!mounted ||
        generated ||
        !isInitialGeneration ||
        _controller.hasRecoverablePaperError) {
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(ExamAttemptResult.generationFailed);
    }
  }

  Future<bool> showUnansweredSubmitDialog() async {
    unawaited(_questionSpeech.stop());
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

  Future<bool> _confirmAttemptExit(BuildContext dialogContext) {
    unawaited(_questionSpeech.stop());
    if (!_controller.isAssessment && !_controller.isGrade) {
      return showAttemptExitDialog(dialogContext);
    }
    return showAssessmentExitDialog(
      dialogContext,
      titleKey: _controller.isGrade
          ? AppKeys.lessonExitTitle
          : AppKeys.assessmentExitTitle,
      onUpdateStatus: (status) {
        if (status == assessmentActiveStatus) {
          return Future<void>.value();
        }
        return _controller.updateStatusForExit(status);
      },
    );
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
          final currentExam = _controller.exam;
          final questions = currentExam?.questions ?? const <ExamQuestion>[];
          final currentQuestion = _controller.currentQuestion;
          final errorMessage = _controller.errorMessage;
          final isGeneratingQuestion = _controller.isGeneratingQuestion;
          final isTransitioningSet = _controller.isTransitioningSet;
          final setTransitionKind = switch (_controller
              .transitioningGradeDelta) {
            int delta when delta < 0 => AssessmentSetTransitionKind.downGrade,
            0 => AssessmentSetTransitionKind.stayGrade,
            1 => AssessmentSetTransitionKind.grow,
            int delta when delta >= 2 => AssessmentSetTransitionKind.trophy,
            _ => null,
          };
          final isSubmittingExam =
              _controller.isSubmittingExam || _isCompletingAssessment;
          final hasActiveAttempt = questions.isNotEmpty;
          final isBusy =
              isGeneratingQuestion || isTransitioningSet || isSubmittingExam;
          final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
          final screen = Scaffold(
            backgroundColor: colors.surface,
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
                                  retryLabel: _controller.needsNewPaper
                                      ? context.getText(
                                          AppKeys.examStartNewPaper,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          )
                        : isSubmittingExam
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
                                'assessment-question-${_controller.displayedQuestionNumber}-$isTransitioningSet',
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
                                              _controller.progressQuestionIndex,
                                          questionNumberOffset: _controller
                                              .progressQuestionNumberOffset,
                                          totalQuestions: questions.length,
                                          answeredQuestionIndexes:
                                              isTransitioningSet
                                              ? const <int>{}
                                              : _controller
                                                    .selectedAnswerLabels
                                                    .keys
                                                    .toSet(),
                                          onQuestionSelected:
                                              widget.allowQuestionNavigation &&
                                                  !_controller.isGrade &&
                                                  !isTransitioningSet
                                              ? goToQuestion
                                              : null,
                                          showQuestionNavigation:
                                              widget.showQuestionNavigation &&
                                              !_controller.isGrade,
                                        ),
                                        const SizedBox(height: 16),
                                        if (setTransitionKind == null &&
                                            isTransitioningSet)
                                          const AssessmentQuestionSkeleton()
                                        else if (setTransitionKind == null &&
                                            currentQuestion != null &&
                                            AssessmentImageMatchCard.supports(
                                              currentQuestion,
                                            )) ...[
                                          AssessmentImageMatchCard(
                                            question: currentQuestion,
                                            grade: _questionGrade,
                                            selectedOptionIds:
                                                _controller.selectedOptionIds,
                                            feedbackCorrect: _controller
                                                .selectedAnswerFeedbackCorrect,
                                            onSelected: selectAnswer,
                                            onReadQuestion: _canReadQuestion
                                                ? () => _readQuestion(
                                                    manual: true,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(height: 24),
                                        ] else if (setTransitionKind ==
                                            null) ...[
                                          AssessmentQuestionCard(
                                            question:
                                                currentQuestion!.questionText,
                                            renderLatex:
                                                currentQuestion.isFraction,
                                            imageUrl: currentQuestion
                                                .questionImageUrl,
                                            grade: _questionGrade,
                                            onReadQuestion: _canReadQuestion
                                                ? () => _readQuestion(
                                                    manual: true,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(height: 32),
                                          if (currentQuestion.isNumericInput)
                                            ExamNumericInput(
                                              key: ValueKey(
                                                'numeric-${currentExam?.examId}-${currentQuestion.questionNumber}',
                                              ),
                                              value: _controller.numericValue,
                                              onChanged:
                                                  _controller.setNumericValue,
                                            )
                                          else ...[
                                            if (currentQuestion
                                                .isMultipleChoice)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: Text(
                                                  context.getText(
                                                    AppKeys.examChooseMultiple,
                                                  ),
                                                ),
                                              ),
                                            AssessmentAnswerGrid(
                                              options: currentQuestion.options,
                                              selectedOptionIds:
                                                  _controller.selectedOptionIds,
                                              showLetters:
                                                  !currentQuestion.isTrueFalse,
                                              renderLatex:
                                                  currentQuestion.isFraction,
                                              selectedAnswerLabel: _controller
                                                  .selectedAnswerLabel,
                                              selectedAnswerFeedbackCorrect:
                                                  _controller
                                                      .selectedAnswerFeedbackCorrect,
                                              onSelected: selectAnswer,
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (setTransitionKind != null)
                                    SliverFillRemaining(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          14,
                                          0,
                                          14,
                                          14 + bottomInset,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                          child: AssessmentSetTransitionLoader(
                                            key: ValueKey(setTransitionKind),
                                            kind: setTransitionKind,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: AssessmentBottomBar(
                                          bottomInset: bottomInset,
                                          canGoBack:
                                              _controller.questionIndex > 0,
                                          allQuestionsAnswered:
                                              _controller
                                                  .allQuestionsAnswered &&
                                              !_controller.isAssessment &&
                                              !_controller.isGrade,
                                          canContinue:
                                              (!_controller.isAssessment &&
                                                  !_controller.isPractice &&
                                                  !_controller.isGrade) ||
                                              _controller.canContinue,
                                          isSubmitting: isSubmittingExam,
                                          isTransitioning: isTransitioningSet,
                                          alwaysShowExit:
                                              _controller.isAssessment,
                                          onBack: goToPreviousQuestion,
                                          onExit: _exitController.requestExit,
                                          onContinue: handleContinue,
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

          return GuardedExitScope<ExamAttemptResult>(
            controller: _exitController,
            shouldConfirm: hasActiveAttempt,
            isExitBlocked: isBusy,
            confirmExit: _confirmAttemptExit,
            child: screen,
          );
        },
      ),
    );
  }
}
