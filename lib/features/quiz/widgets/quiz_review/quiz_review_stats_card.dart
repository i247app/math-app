part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewStatsCard extends StatelessWidget {
  const _QuizReviewStatsCard({required this.quiz});

  final GeneratedQuiz quiz;

  @override
  Widget build(BuildContext context) {
    final total = quiz.grading?.totalQuestions ?? quiz.questions.length;
    final correct =
        quiz.grading?.correctNumber ?? _quizReviewComputedCorrectCount(quiz);
    final wrong = total > correct ? total - correct : 0;
    final time = _quizReviewTimeLabel(quiz);

    return _QuizReviewCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QuizReviewStatItem(
            icon: Icons.quiz_outlined,
            iconColor: quizReviewTeal,
            iconBackground: const Color(0xFFDDF1FF),
            valueColor: quizReviewTeal,
            value: '$total',
            label: context.getText(AppKeys.totalQuestions),
          ),
          _QuizReviewStatItem(
            icon: Icons.check_circle_outline_rounded,
            iconColor: quizReviewTeal,
            iconBackground: quizReviewTealSoft,
            valueColor: quizReviewTeal,
            value: '$correct',
            label: context.getText(AppKeys.correct),
          ),
          _QuizReviewStatItem(
            icon: Icons.cancel_outlined,
            iconColor: quizReviewRed,
            iconBackground: const Color(0xFFFFDCDD),
            valueColor: quizReviewRed,
            value: '$wrong',
            label: context.getText(AppKeys.incorrect),
          ),
          _QuizReviewStatItem(
            icon: Icons.schedule_rounded,
            iconColor: quizReviewOrange,
            iconBackground: const Color(0xFFFFEAD6),
            valueColor: quizReviewOrange,
            value: time,
            label: context.getText(AppKeys.time),
          ),
        ],
      ),
    );
  }
}
