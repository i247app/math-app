import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/features/quiz/cache/quiz_cache.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';

part '../widgets/quiz_review/quiz_review_header.dart';
part '../widgets/quiz_review/quiz_review_content.dart';
part '../widgets/quiz_review/quiz_review_mode_tabs.dart';
part '../widgets/quiz_review/quiz_review_mode_tab_button.dart';
part '../widgets/quiz_review/quiz_review_stats_card.dart';
part '../widgets/quiz_review/quiz_review_stat_item.dart';
part '../widgets/quiz_review/quiz_review_question_selector.dart';
part '../widgets/quiz_review/quiz_review_centered_text.dart';
part '../widgets/quiz_review/quiz_review_question_card.dart';
part '../widgets/quiz_review/quiz_review_retry_question_view.dart';
part '../widgets/quiz_review/quiz_review_result_question_list.dart';
part '../widgets/quiz_review/quiz_review_result_question_card.dart';
part '../widgets/quiz_review/quiz_review_question_badge.dart';
part '../widgets/quiz_review/quiz_review_question_status.dart';
part '../widgets/quiz_review/quiz_review_question_navigation_bar.dart';
part '../widgets/quiz_review/quiz_review_nav_button.dart';
part '../widgets/quiz_review/quiz_review_answer_list.dart';
part '../widgets/quiz_review/quiz_review_answer_tile.dart';
part '../widgets/quiz_review/quiz_review_card.dart';
part '../widgets/quiz_review/quiz_review_loading_content.dart';
part '../widgets/quiz_review/quiz_review_loading_content_state.dart';
part '../widgets/quiz_review/quiz_review_question_loading_section.dart';
part '../widgets/quiz_review/quiz_review_question_loading_section_state.dart';
part '../widgets/quiz_review/quiz_review_question_skeleton.dart';
part '../widgets/quiz_review/quiz_review_skeleton_block.dart';
part '../widgets/quiz_review/quiz_review_inline_error.dart';
part '../widgets/quiz_review/quiz_review_state_panel.dart';
part '../widgets/quiz_review/quiz_review_selected_answer_label.dart';
part '../widgets/quiz_review/quiz_review_correct_answer_label.dart';
part '../widgets/quiz_review/quiz_review_computed_correct_count.dart';
part '../widgets/quiz_review/quiz_review_time_label.dart';
part '../widgets/quiz_review/quiz_review_question_font_size.dart';
part '../widgets/quiz_review/quiz_review_two_digits.dart';

const _reviewBackground = Color(0xFFEEF9FB);
const _teal = Color(0xFF007A78);
const _tealSoft = Color(0xFFC8FBF1);
const _tealLight = Color(0xFFEFFFFC);
const _navy = Color(0xFF063A7B);
const _green = Color(0xFF12B8A7);
const _red = Color(0xFFD71920);
const _redSoft = Color(0xFFFFF5F6);
const _orange = Color(0xFFFF6A1A);
const _deepInk = Color(0xFF1F2B2B);
const _cardBorder = Color(0xFFDCE8EA);
const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

enum _QuizReviewMode { retry, result }

class QuizReviewScreen extends StatefulWidget {
  const QuizReviewScreen({super.key, required this.quizId, this.initialQuiz});

  final int quizId;
  final GeneratedQuiz? initialQuiz;

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  late final QuizService _quizService = _useFakeQuizApi
      ? const FakeQuizApi()
      : QuizApi();

  GeneratedQuiz? _quiz;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  int _loadRequestId = 0;
  _QuizReviewMode _mode = _QuizReviewMode.retry;
  final Map<int, String> _submittedAnswers = <int, String>{};
  final Map<int, String> _retryAnswers = <int, String>{};

  @override
  void initState() {
    super.initState();
    _quiz = widget.initialQuiz;
    _seedSubmittedAnswers(widget.initialQuiz);
    if (widget.initialQuiz != null) {
      QuizCache.seedDetail(widget.initialQuiz!, fallbackQuizId: widget.quizId);
    }
    _loadQuizDetail();
  }

  Future<void> _loadQuizDetail({bool forceRefresh = false}) async {
    final requestId = ++_loadRequestId;
    final cachedQuiz = QuizCache.peekDetail(widget.quizId);
    if (cachedQuiz != null && _quiz == null) {
      _quiz = cachedQuiz;
      _seedSubmittedAnswers(cachedQuiz);
    }

    final hasVisibleQuiz = _quiz != null;
    setState(() {
      _isLoading = !hasVisibleQuiz;
      _errorMessage = null;
    });

    final shouldRefresh =
        forceRefresh || !QuizCache.isDetailFresh(widget.quizId);
    if (!shouldRefresh) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final quiz = await QuizCache.loadDetail(
        service: _quizService,
        quizId: widget.quizId,
        forceRefresh: forceRefresh || hasVisibleQuiz,
      );
      if (!mounted || requestId != _loadRequestId) {
        return;
      }

      setState(() {
        _quiz = quiz;
        _seedSubmittedAnswers(quiz);
        _isLoading = false;
        if (_selectedIndex >= quiz.questions.length) {
          _selectedIndex = 0;
        }
      });
    } on QuizException catch (error) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }

      setState(() {
        _errorMessage = AppStrings.current(AppKeys.quizDetailLoadFailed);
        _isLoading = false;
      });
    }
  }

  void _selectQuestion(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _selectMode(_QuizReviewMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _mode = mode);
  }

  void _selectAnswer(int questionNumber, String label) {
    HapticFeedback.selectionClick();
    setState(() {
      _retryAnswers[questionNumber] = label.trim().toUpperCase();
    });
  }

  void _goToPreviousQuestion() {
    if (_selectedIndex <= 0) {
      return;
    }
    _selectQuestion(_selectedIndex - 1);
  }

  void _goToNextQuestion() {
    final lastIndex = (_quiz?.questions.length ?? 0) - 1;
    if (_selectedIndex >= lastIndex) {
      return;
    }
    _selectQuestion(_selectedIndex + 1);
  }

  void _seedSubmittedAnswers(GeneratedQuiz? quiz) {
    if (quiz == null) {
      return;
    }
    _submittedAnswers.clear();
    if (quiz.answers.isEmpty) {
      return;
    }
    for (final answer in quiz.answers) {
      final label = answer.label.trim().toUpperCase();
      if (label.isNotEmpty) {
        _submittedAnswers[answer.questionNumber] = label;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;

    return Scaffold(
      backgroundColor: _reviewBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _QuizReviewHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: quiz == null
                  ? _isLoading
                        ? const _QuizReviewLoadingContent(
                            showHeaderSkeleton: false,
                          )
                        : _QuizReviewStatePanel(
                            isLoading: false,
                            message: _errorMessage,
                            onRetry: () => _loadQuizDetail(forceRefresh: true),
                          )
                  : _QuizReviewContent(
                      quiz: quiz,
                      selectedIndex: _selectedIndex,
                      mode: _mode,
                      isLoading: _isLoading,
                      errorMessage: _errorMessage,
                      onRetry: () => _loadQuizDetail(forceRefresh: true),
                      onModeSelected: _selectMode,
                      onQuestionSelected: _selectQuestion,
                      submittedAnswers: _submittedAnswers,
                      retryAnswers: _retryAnswers,
                      onAnswerSelected: _selectAnswer,
                      onPrevious: _goToPreviousQuestion,
                      onNext: _goToNextQuestion,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
