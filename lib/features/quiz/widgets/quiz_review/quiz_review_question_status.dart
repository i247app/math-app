part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewQuestionStatus extends StatelessWidget {
  const _QuizReviewQuestionStatus({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? _teal : _red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCorrect ? Icons.verified_outlined : Icons.error_outline_rounded,
          color: color,
          size: 17,
        ),
        const SizedBox(width: 4),
        Text(
          context
              .getText(
                isCorrect ? AppKeys.correctStatus : AppKeys.incorrectStatus,
              )
              .toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
