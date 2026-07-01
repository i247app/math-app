part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewLoadingContentState extends State<_QuizReviewLoadingContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showHeaderSkeleton) ...[
                _QuizReviewSkeletonBlock(
                  progress: progress,
                  height: 44,
                  borderRadius: 12,
                ),
                const SizedBox(height: 12),
                _QuizReviewSkeletonBlock(
                  progress: progress,
                  height: 94,
                  borderRadius: 14,
                ),
                const SizedBox(height: 24),
              ],
              _QuizReviewQuestionLoadingSection(progress: progress),
            ],
          ),
        );
      },
    );
  }
}
