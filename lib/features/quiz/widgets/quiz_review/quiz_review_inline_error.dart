part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewInlineError extends StatelessWidget {
  const _QuizReviewInlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _QuizReviewCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: _red, fontWeight: FontWeight.w800),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}
