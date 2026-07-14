import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/cache/quiz_cache.dart';
import 'package:numi/features/quiz/controllers/quiz_review_controller.dart';
import 'package:numi/features/quiz/quiz_api.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/layouts/page_header.dart';

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
part 'quiz_review_entry_screen.dart';

/// Shared review-detail layout used by quiz and classroom-exercise entry
/// screens. Source-specific screens provide the detail loader and data model.
class ReviewDetailScreen extends StatefulWidget {
  const ReviewDetailScreen({
    super.key,
    required this.detailId,
    required this.detailLoader,
    this.initialDetail,
    this.allowRetry = true,
    this.cacheId,
  });

  final int detailId;
  final QuizDetailLoader detailLoader;
  final GeneratedQuiz? initialDetail;
  final bool allowRetry;
  final int? cacheId;

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  late final QuizReviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuizReviewController(
      quizId: widget.detailId,
      loadDetail: widget.detailLoader,
      initialQuiz: widget.initialDetail,
      initialMode: widget.allowRetry
          ? QuizReviewMode.retry
          : QuizReviewMode.result,
      cacheId: widget.cacheId,
    );
    _controller.loadQuizDetail();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectQuestion(int index) {
    if (_controller.selectQuestion(index)) {
      HapticFeedback.selectionClick();
    }
  }

  void _selectMode(QuizReviewMode mode) {
    if (_controller.selectMode(mode)) {
      HapticFeedback.selectionClick();
    }
  }

  void _selectAnswer(int questionNumber, String label) {
    HapticFeedback.selectionClick();
    _controller.selectAnswer(questionNumber, label);
  }

  void _goToPreviousQuestion() {
    if (_controller.goToPreviousQuestion()) {
      HapticFeedback.selectionClick();
    }
  }

  void _goToNextQuestion() {
    if (_controller.goToNextQuestion()) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _QuizReviewHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final quiz = _controller.quiz;
                  if (quiz == null) {
                    return _controller.isLoading
                        ? const _QuizReviewLoadingContent()
                        : _QuizReviewStatePanel(
                            isLoading: false,
                            message: _controller.errorMessage,
                            onRetry: () =>
                                _controller.loadQuizDetail(forceRefresh: true),
                          );
                  }

                  return _QuizReviewContent(
                    quiz: quiz,
                    selectedIndex: _controller.selectedIndex,
                    mode: _controller.mode,
                    allowRetry: widget.allowRetry,
                    isLoading: _controller.isLoading,
                    errorMessage: _controller.errorMessage,
                    onRetry: () =>
                        _controller.loadQuizDetail(forceRefresh: true),
                    onModeSelected: _selectMode,
                    onQuestionSelected: _selectQuestion,
                    submittedAnswers: _controller.submittedAnswers,
                    retryAnswers: _controller.retryAnswers,
                    onAnswerSelected: _selectAnswer,
                    onPrevious: _goToPreviousQuestion,
                    onNext: _goToNextQuestion,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
