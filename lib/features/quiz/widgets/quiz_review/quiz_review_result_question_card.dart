part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewResultQuestionCard extends StatelessWidget {
  const _QuizReviewResultQuestionCard({
    required this.question,
    required this.selectedLabel,
  });

  final QuizQuestion question;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    final correctLabel = _quizReviewCorrectAnswerLabel(question);
    final isCorrect = selectedLabel != null && selectedLabel == correctLabel;
    final accent = isCorrect ? quizReviewTeal : quizReviewRed;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _QuizReviewQuestionBadge(
                          number: question.questionNumber,
                          color: isCorrect
                              ? quizReviewTealSoft
                              : const Color(0xFFFFD9DC),
                          textColor: isCorrect ? quizReviewTeal : quizReviewRed,
                        ),
                        const Spacer(),
                        _QuizReviewQuestionStatus(isCorrect: isCorrect),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      question.questionName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: quizReviewDeepInk,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _QuizReviewAnswerList(
                      question: question,
                      selectedLabel: selectedLabel,
                      showCorrectAnswer: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
