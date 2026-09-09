import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/controllers/exam_review_controller.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_content.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_header.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_loading_content.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_state_panel.dart';

/// Shared review-detail layout used by exam and classroom-exercise entry
/// screens. Source-specific screens provide the detail loader and data model.
class ReviewDetailScreen extends StatefulWidget {
  const ReviewDetailScreen({
    super.key,
    required this.detailId,
    required this.detailLoader,
    this.initialDetail,
    this.allowRetry = true,
    this.cacheKey,
  });

  final int detailId;
  final ExamDetailLoader detailLoader;
  final GeneratedExam? initialDetail;
  final bool allowRetry;
  final Object? cacheKey;

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  late final ExamReviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExamReviewController(
      examId: widget.detailId,
      loadDetail: widget.detailLoader,
      initialExam: widget.initialDetail,
      initialMode: widget.allowRetry
          ? ExamReviewMode.retry
          : ExamReviewMode.result,
      cacheKey: widget.cacheKey,
    );
    _controller.loadExamDetail();
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

  void _selectMode(ExamReviewMode mode) {
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
            ExamReviewHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final exam = _controller.exam;
                  if (exam == null) {
                    return _controller.isLoading
                        ? const ExamReviewLoadingContent()
                        : ExamReviewStatePanel(
                            isLoading: false,
                            message: _controller.errorMessage,
                            onRetry: () =>
                                _controller.loadExamDetail(forceRefresh: true),
                          );
                  }

                  return ExamReviewContent(
                    exam: exam,
                    selectedIndex: _controller.selectedIndex,
                    mode: _controller.mode,
                    allowRetry: widget.allowRetry,
                    isLoading: _controller.isLoading,
                    errorMessage: _controller.errorMessage,
                    onRetry: () =>
                        _controller.loadExamDetail(forceRefresh: true),
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
