part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewContent extends StatelessWidget {
  const _QuizReviewContent({
    required this.quiz,
    required this.selectedIndex,
    required this.mode,
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
  });

  final GeneratedQuiz quiz;
  final int selectedIndex;
  final QuizReviewMode mode;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<QuizReviewMode> onModeSelected;
  final ValueChanged<int> onQuestionSelected;
  final Map<int, String> submittedAnswers;
  final Map<int, String> retryAnswers;
  final void Function(int questionNumber, String label) onAnswerSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final questions = quiz.questions;
    final safeIndex = questions.isEmpty
        ? 0
        : selectedIndex.clamp(0, questions.length - 1);
    final question = questions.isEmpty ? null : questions[safeIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading) const LinearProgressIndicator(color: AppColors.navy),
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            _QuizReviewInlineError(message: errorMessage!, onRetry: onRetry),
            const SizedBox(height: 10),
          ],
          _QuizReviewModeTabs(selectedMode: mode, onSelected: onModeSelected),
          const SizedBox(height: 12),
          _QuizReviewStatsCard(quiz: quiz),
          const SizedBox(height: 11),
          if (isLoading && question == null)
            const _QuizReviewQuestionLoadingSection()
          else if (question == null)
            _QuizReviewStatePanel(
              isLoading: false,
              message: context.getText(AppKeys.emptyQuizQuestions),
              onRetry: onRetry,
            )
          else if (mode == QuizReviewMode.result)
            _QuizReviewResultQuestionList(
              quiz: quiz,
              selectedAnswers: submittedAnswers,
            )
          else
            _QuizReviewRetryQuestionView(
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
