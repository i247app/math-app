import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/controllers/review_detail_controller.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/assessment_result/test_again_loader.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_content.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_computed_correct_count.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_header.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_loading_content.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_state_panel.dart';
import 'package:numi/features/exam/screens/ai_review_screen.dart';

typedef ReviewDetailPracticeStarter = Future<void> Function(GeneratedExam exam);

/// Shared review-detail layout used by exam and classroom-exercise entry
/// screens. Source-specific screens provide the detail loader and data model.
class ReviewDetailScreen extends StatefulWidget {
  const ReviewDetailScreen({
    super.key,
    required this.detailId,
    required this.detailLoader,
    this.headerTitle,
    this.initialDetail,
    this.allowRetry = true,
    this.showTime = true,
    this.cacheKey,
    this.onPractice,
    this.onGenerateAiReview,
  });

  final int detailId;
  final ExamDetailLoader detailLoader;
  final String? headerTitle;
  final GeneratedExam? initialDetail;
  final bool allowRetry;
  final bool showTime;
  final Object? cacheKey;
  final ReviewDetailPracticeStarter? onPractice;
  final Future<ExamStats?> Function(GeneratedExam? exam)? onGenerateAiReview;

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  late final ReviewDetailController _controller;
  bool _isGeneratingPractice = false;
  bool _isAiReviewOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = ReviewDetailController(
      detailId: widget.detailId,
      loadDetail: widget.detailLoader,
      initialExam: widget.initialDetail,
      initialMode: widget.allowRetry
          ? ExamReviewMode.retry
          : ExamReviewMode.result,
      cacheKey: widget.cacheKey,
    );
    unawaited(_controller.loadDetail());
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

  String? _resolveAiReviewSummary(GeneratedExam exam) {
    final total = exam.grading?.totalQuestions ?? exam.questions.length;
    final correct =
        exam.grading?.correctNumber ?? examReviewComputedCorrectCount(exam);
    if (total > 0 && correct == total) {
      return context.getText(AppKeys.examReviewPerfectScoreMessage);
    }
    return exam.aiReviewShort;
  }

  Future<void> _openAiReview(GeneratedExam exam) async {
    if (_isAiReviewOpen) return;
    _isAiReviewOpen = true;
    final longText = exam.aiReviewLong?.trim() ?? '';
    final hasExistingReview =
        longText.isNotEmpty && (exam.aiReviewShort?.trim().isNotEmpty ?? false);
    final shortText = _resolveAiReviewSummary(exam)?.trim() ?? '';
    final topics = exam.practiceWeakTopics
        .map((topic) => topic.topic.trim())
        .where((topic) => topic.isNotEmpty)
        .join(', ');
    final reviewText = longText.isNotEmpty
        ? longText
        : shortText.isNotEmpty
        ? shortText
        : topics;
    final generateAiReview = widget.onGenerateAiReview;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => AiReviewScreen(
            reviewText: reviewText,
            aiReviewLoader: generateAiReview == null || hasExistingReview
                ? null
                : () async {
                    final review = await generateAiReview(exam);
                    final generatedLong = review?.aiReviewLong?.trim() ?? '';
                    final generatedShort = review?.aiReviewShort?.trim() ?? '';
                    return generatedLong.isNotEmpty
                        ? generatedLong
                        : generatedShort.isNotEmpty
                        ? generatedShort
                        : reviewText;
                  },
          ),
        ),
      );
      if (mounted) {
        await _controller.loadDetail(forceRefresh: true);
      }
    } finally {
      _isAiReviewOpen = false;
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

  Future<void> _startPractice(GeneratedExam exam) async {
    final onPractice = widget.onPractice;
    if (onPractice == null || _isGeneratingPractice) {
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isGeneratingPractice = true);
    try {
      await onPractice(exam);
    } on ExamException catch (error) {
      _showPracticeError(error.message);
    } catch (_) {
      _showPracticeError(AppStrings.current(AppKeys.testAgainCreateFailed));
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPractice = false);
      }
    }
  }

  void _showPracticeError(String message) {
    if (!mounted) {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.getText(AppKeys.testAgainDialogTitle)),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: _isGeneratingPractice
            ? const AssessmentTestAgainLoader()
            : Column(
                children: [
                  ExamReviewHeader(
                    title: widget.headerTitle,
                    onBack: () => Navigator.of(context).pop(),
                  ),
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
                                  onRetry: () => _controller.loadDetail(
                                    forceRefresh: true,
                                  ),
                                );
                        }

                        return ExamReviewContent(
                          exam: exam,
                          selectedIndex: _controller.selectedIndex,
                          mode: _controller.mode,
                          allowRetry: widget.allowRetry,
                          showTime: widget.showTime,
                          isLoading: _controller.isLoading,
                          errorMessage: _controller.errorMessage,
                          onRetry: () =>
                              _controller.loadDetail(forceRefresh: true),
                          onModeSelected: _selectMode,
                          onQuestionSelected: _selectQuestion,
                          submittedAnswers: _controller.submittedAnswers,
                          retryAnswers: _controller.retryAnswers,
                          onAnswerSelected: _selectAnswer,
                          onPrevious: _goToPreviousQuestion,
                          onNext: _goToNextQuestion,
                          onPractice: widget.onPractice == null
                              ? null
                              : () => _startPractice(exam),
                          isGeneratingPractice: _isGeneratingPractice,
                          aiReviewShort: _resolveAiReviewSummary(exam),
                          aiTitle: exam.aiTitle,
                          aiShortText: exam.aiShortText,
                          onOpenAiReview: () => _openAiReview(exam),
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
