part of 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

class _QuizReviewQuestionCard extends StatelessWidget {
  const _QuizReviewQuestionCard({required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 146,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
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
                color: colors.textPrimary,
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
