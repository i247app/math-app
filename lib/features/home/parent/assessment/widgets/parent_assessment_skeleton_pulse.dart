part of '../../../home_screen.dart';

class _ParentAssessmentSkeletonPulse extends StatefulWidget {
  const _ParentAssessmentSkeletonPulse({required this.builder});

  final Widget Function(BuildContext context, Color color) builder;

  @override
  State<_ParentAssessmentSkeletonPulse> createState() =>
      _ParentAssessmentSkeletonPulseState();
}

class _ParentAssessmentSkeletonPulseState
    extends State<_ParentAssessmentSkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(
        context,
        Color.lerp(
          const Color(0xFFF0F4F3),
          const Color(0xFFDCE7E5),
          _controller.value,
        )!,
      ),
    );
  }
}
