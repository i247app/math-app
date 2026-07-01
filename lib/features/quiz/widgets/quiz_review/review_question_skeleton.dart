part of '../../presentation/quiz_review_screen.dart';

class _ReviewQuestionSkeleton extends StatelessWidget {
  const _ReviewQuestionSkeleton({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SkeletonBlock(progress: progress, height: 146, borderRadius: 14),
        const SizedBox(height: 23),
        for (var index = 0; index < 4; index++) ...[
          _SkeletonBlock(progress: progress, height: 59, borderRadius: 12),
          if (index != 3) const SizedBox(height: 10),
        ],
        const SizedBox(height: 13),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _SkeletonBlock(
                  progress: progress,
                  height: 40,
                  borderRadius: 9,
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: _SkeletonBlock(
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
