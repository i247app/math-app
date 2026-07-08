part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewQuestionCard extends StatelessWidget {
  const _QuizReviewQuestionCard({required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 146,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: _QuizReviewQuestionBadge(
              number: question.questionNumber,
              color: AppColors.aquaMist,
              textColor: AppColors.teal600,
            ),
          ),
          Center(
            child: Text(
              question.questionName,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF3C4B4C),
                fontSize: _quizReviewQuestionFontSize(question.questionName),
                fontWeight: FontWeight.w900,
                height: 1.08,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
