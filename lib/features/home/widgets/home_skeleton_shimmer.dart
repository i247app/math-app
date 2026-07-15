import 'dart:ui';

import 'package:flutter/material.dart';

/// A shimmer effect widget for skeleton loading states.
///
/// Combines the horizontal sweep approach from [TeacherSkeletonShimmer]
/// with the accessibility guard (`MediaQuery.disableAnimationsOf`) from
/// the parent role shimmer. Accepts an [Animation<double>] controller so
/// the caller decides the animation lifecycle.
class HomeSkeletonShimmer extends StatelessWidget {
  const HomeSkeletonShimmer({
    super.key,
    required this.controller,
    required this.child,
  });

  final Animation<double> controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

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
