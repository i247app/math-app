part of 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

class _QuizReviewQuestionBadge extends StatelessWidget {
  const _QuizReviewQuestionBadge({
    required this.number,
    required this.color,
    required this.textColor,
  });

  final int number;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.formatText(AppKeys.questionNumber, {'number': number}),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
