part of '../../presentation/quiz_review_screen.dart';

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({
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
  final _ReviewMode mode;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<_ReviewMode> onModeSelected;
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
          if (isLoading) const LinearProgressIndicator(color: _navy),
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            _InlineError(message: errorMessage!, onRetry: onRetry),
            const SizedBox(height: 10),
          ],
          _ModeTabs(selectedMode: mode, onSelected: onModeSelected),
          const SizedBox(height: 12),
          _StatsCard(quiz: quiz),
          const SizedBox(height: 11),
          if (isLoading && question == null)
            const _ReviewQuestionLoadingSection()
          else if (question == null)
            _ReviewStatePanel(
              isLoading: false,
              message: context.getText(AppKeys.emptyQuizQuestions),
              onRetry: onRetry,
            )
          else if (mode == _ReviewMode.result)
            _ResultQuestionList(quiz: quiz, selectedAnswers: submittedAnswers)
          else
            _RetryQuestionView(
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
