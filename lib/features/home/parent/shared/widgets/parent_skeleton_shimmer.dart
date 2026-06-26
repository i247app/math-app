part of '../../../home_screen.dart';

class _ParentSkeletonShimmer extends StatelessWidget {
  const _ParentSkeletonShimmer({
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final width = bounds.width;
        final shimmerWidth = width * 0.42;
        final start = -shimmerWidth + (width + shimmerWidth * 2) * progress;

        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Colors.transparent,
            Color(0x99FFFFFF),
            Colors.transparent,
          ],
          stops: const [0.18, 0.50, 0.82],
          transform: _ParentShimmerTransform(start),
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
