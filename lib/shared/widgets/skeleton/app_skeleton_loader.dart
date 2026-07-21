import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';

class AppSkeletonLoader extends StatefulWidget {
  const AppSkeletonLoader({super.key, required this.builder});

  final Widget Function(BuildContext context, Color color) builder;

  @override
  State<AppSkeletonLoader> createState() => _AppSkeletonLoaderState();
}

class _AppSkeletonLoaderState extends State<AppSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final colors = context.themeColors;
        final pulseValue =
            0.5 - 0.5 * math.cos(math.pi * 2 * _controller.value);
        final color = Color.lerp(colors.skeleton, colors.border, pulseValue)!;

        return AppSkeletonShimmer(
          controller: _controller,
          child: widget.builder(context, color),
        );
      },
    );
  }
}
