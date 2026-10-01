import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/controllers/exam_review_controller.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_inline_error.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_mode_tabs.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_practice_banner.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_question_loading_section.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_result_question_list.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_retry_question_view.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_state_panel.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_stats_card.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_weak_topics_card.dart';

class ExamReviewContent extends StatelessWidget {
  const ExamReviewContent({
    super.key,
    required this.exam,
    required this.selectedIndex,
    required this.mode,
    required this.allowRetry,
    this.showTime = true,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onModeSelected,
    required this.onQuestionSelected,
    required this.submittedAnswers,
    required this.retryAnswers,
    required this.onAnswerSelected,
    required this.onPrevious,
    required this.onNext,
    this.onPractice,
    this.isGeneratingPractice = false,
    this.aiReviewShort,
    this.aiTitle,
    this.aiShortText,
    this.onOpenReview,
  });

  final GeneratedExam exam;
  final int selectedIndex;
  final ExamReviewMode mode;
  final bool allowRetry;
  final bool showTime;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<ExamReviewMode> onModeSelected;
  final ValueChanged<int> onQuestionSelected;
  final Map<int, String> submittedAnswers;
  final Map<int, String> retryAnswers;
  final void Function(int questionNumber, String label) onAnswerSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onPractice;
  final bool isGeneratingPractice;
  final String? aiReviewShort;
  final String? aiTitle;
  final String? aiShortText;
  final VoidCallback? onOpenReview;

  @override
  Widget build(BuildContext context) {
    final questions = exam.questions;
    final safeIndex = questions.isEmpty
        ? 0
        : selectedIndex.clamp(0, questions.length - 1);
    final question = questions.isEmpty ? null : questions[safeIndex];
    final hasAiReview = aiReviewShort?.trim().isNotEmpty ?? false;
    final title = aiTitle?.trim() ?? '';
    final shortText = aiShortText?.trim() ?? '';
    final colors = context.themeColors;
    String? gradeLevelText;
    if (exam.grade != null && exam.level != null) {
      final gradeLabel = exam.grade == 0
          ? context.getText(AppKeys.gradeRoadmapKindergarten)
          : context.formatText(AppKeys.gradeRoadmapGrade, {
              'grade': exam.grade,
            });
      gradeLevelText = context.formatText(AppKeys.examReviewGradeLevelBadge, {
        'grade': gradeLabel,
        'level': exam.level,
      });
    }
    final aiTextStyle = GoogleFonts.andika(
      color: Theme.of(context).brightness == Brightness.dark
          ? colors.textPrimary
          : Colors.black,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading) const LinearProgressIndicator(color: AppColors.navy),
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExamReviewInlineError(
                message: errorMessage!,
                onRetry: onRetry,
              ),
            ),
          ],
          if (onPractice != null) ...[
            if (gradeLevelText != null ||
                title.isNotEmpty ||
                shortText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  key: const ValueKey('exam-review-ai-description-box'),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.elevatedSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (gradeLevelText != null)
                        Text(
                          gradeLevelText,
                          key: const ValueKey('exam-review-grade-level-text'),
                          style: aiTextStyle,
                        ),
                      if (gradeLevelText != null &&
                          (title.isNotEmpty || shortText.isNotEmpty))
                        const SizedBox(height: 8),
                      if (title.isNotEmpty)
                        Text(
                          title,
                          key: const ValueKey('exam-review-ai-title'),
                          style: aiTextStyle,
                        ),
                      if (title.isNotEmpty && shortText.isNotEmpty)
                        const SizedBox(height: 8),
                      if (shortText.isNotEmpty)
                        Text(
                          shortText,
                          key: const ValueKey('exam-review-ai-short-text'),
                          style: aiTextStyle,
                        ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExamReviewPracticeBanner(
                isLoading: isGeneratingPractice,
                onTap: onPractice!,
              ),
            ),
          ],
          if (hasAiReview ||
              (onPractice != null &&
                  exam.practiceWeakTopics.any(
                    (topic) => topic.topic.trim().isNotEmpty,
                  )))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExamReviewWeakTopicsCard(
                topics: exam.practiceWeakTopics,
                aiReviewShort: aiReviewShort,
                onOpenReview: onOpenReview,
              ),
            ),
          if (allowRetry) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExamReviewModeTabs(
                selectedMode: mode,
                onSelected: onModeSelected,
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: ExamReviewStatsCard(exam: exam, showTime: showTime),
          ),
          if (isLoading && question == null)
            const ExamReviewQuestionLoadingSection()
          else if (question == null)
            ExamReviewStatePanel(
              isLoading: false,
              message: context.getText(AppKeys.emptyExamQuestions),
              onRetry: onRetry,
            )
          else if (!allowRetry || mode == ExamReviewMode.result)
            ExamReviewResultQuestionList(
              exam: exam,
              selectedAnswers: submittedAnswers,
            )
          else
            ExamReviewRetryQuestionView(
              questions: questions,
              selectedIndex: safeIndex,
              question: question,
              selectedAnswers: retryAnswers,
              onQuestionSelected: onQuestionSelected,
              onAnswerSelected: onAnswerSelected,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
        ],
      ),
    );
  }
}
