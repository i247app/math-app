part of 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

class _QuizReviewQuestionSkeleton extends StatelessWidget {
  const _QuizReviewQuestionSkeleton({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuizReviewSkeletonBlock(
          progress: progress,
          height: 146,
          borderRadius: 14,
        ),
        const SizedBox(height: 23),
        for (var index = 0; index < 4; index++) ...[
          _QuizReviewSkeletonBlock(
            progress: progress,
            height: 59,
            borderRadius: 12,
          ),
          if (index != 3) const SizedBox(height: 10),
        ],
        const SizedBox(height: 13),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _QuizReviewSkeletonBlock(
                  progress: progress,
                  height: 40,
                  borderRadius: 9,
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: _QuizReviewSkeletonBlock(
                  progress: progress,
                  height: 40,
                  borderRadius: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
