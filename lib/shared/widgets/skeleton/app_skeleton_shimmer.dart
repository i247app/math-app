import 'dart:ui';

import 'package:flutter/material.dart';

/// A shimmer effect widget for skeleton loading states.
///
/// Combines the horizontal sweep approach from [TeacherSkeletonShimmer]
/// with the accessibility guard (`MediaQuery.disableAnimationsOf`) from
/// the parent role shimmer. Accepts an [Animation<double>] controller so
/// the caller decides the animation lifecycle.
class AppSkeletonShimmer extends StatelessWidget {
  const AppSkeletonShimmer({
    super.key,
    required this.controller,
    required this.child,
    this.shimmerWidthFactor = 1.35,
    this.edgeColor = const Color(0x00FFFFFF),
    this.highlightColor = const Color(0x9EFFFFFF),
  });

  final Animation<double> controller;
  final Widget child;
  final double shimmerWidthFactor;
  final Color edgeColor;
  final Color highlightColor;

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
            final shimmerWidth = bounds.width * shimmerWidthFactor;
            final start = -shimmerWidth;
            final end = bounds.width;
            final dx = lerpDouble(start, end, controller.value)!;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [edgeColor, highlightColor, edgeColor],
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
