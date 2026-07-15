import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/application/quiz_review_controller.dart';
import 'package:numi/features/quiz/data/cache/quiz_cache.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_content.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_header.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_loading_content.dart';
import 'package:numi/features/quiz/widgets/quiz_review/quiz_review_state_panel.dart';

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
            QuizReviewHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final quiz = _controller.quiz;
                  if (quiz == null) {
                    return _controller.isLoading
                        ? const QuizReviewLoadingContent()
                        : QuizReviewStatePanel(
                            isLoading: false,
                            message: _controller.errorMessage,
                            onRetry: () =>
                                _controller.loadQuizDetail(forceRefresh: true),
                          );
                  }

                  return QuizReviewContent(
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
