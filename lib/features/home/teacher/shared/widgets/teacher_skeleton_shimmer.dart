part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherSkeletonShimmer extends StatelessWidget {
  const _TeacherSkeletonShimmer({
    required this.controller,
    required this.child,
  });

  final Animation<double> controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final shimmerWidth = bounds.width * 1.35;
            final start = -shimmerWidth;
            final end = bounds.width;
            final dx = lerpDouble(start, end, controller.value)!;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.62),
                Colors.white.withValues(alpha: 0),
              ],
              stops: const [0.28, 0.50, 0.72],
            ).createShader(Rect.fromLTWH(dx, 0, shimmerWidth, bounds.height));
          },
          child: child,
        );
      },
      child: child,
    );
  }
}
