part of '../../presentation/quiz_review_screen.dart';

class _ReviewQuestionLoadingSectionState
    extends State<_ReviewQuestionLoadingSection>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.progress == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1300),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return _ReviewQuestionSkeleton(progress: widget.progress ?? 0);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return _ReviewQuestionSkeleton(progress: controller.value);
      },
    );
  }
}
