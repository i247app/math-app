part of '../../presentation/quiz_review_screen.dart';

class _ReviewStatePanel extends StatelessWidget {
  const _ReviewStatePanel({
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _ReviewCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const CircularProgressIndicator(color: _navy)
              else ...[
                const Icon(Icons.quiz_outlined, color: _navy, size: 42),
                const SizedBox(height: 14),
                Text(
                  message ?? context.getText(AppKeys.quizDetailErrorTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _deepInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onRetry,
                  child: Text(context.getText(AppKeys.retry)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
