import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_line.dart';

class ParentHomeLoadingCard extends StatefulWidget {
  const ParentHomeLoadingCard({super.key});

  @override
  State<ParentHomeLoadingCard> createState() => _ParentHomeLoadingCardState();
}

class _ParentHomeLoadingCardState extends State<ParentHomeLoadingCard>
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSkeletonBlock(
                height: 225,
                radius: 30,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonLine(width: 148, height: 30, color: color),
                      const SizedBox(height: 14),
                      AppSkeletonLine(width: 210, height: 34, color: color),
                      const Spacer(),
                      AppSkeletonLine(width: 132, height: 14, color: color),
                      const SizedBox(height: 12),
                      AppSkeletonBlock(
                        width: 150,
                        height: 44,
                        radius: 22,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppSkeletonBlock(
                      height: 160,
                      radius: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppSkeletonBlock(
                      height: 160,
                      radius: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppSkeletonBlock(
                height: 178,
                radius: 17,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (var index = 0; index < 3; index++) ...[
                        Row(
                          children: [
                            AppSkeletonBlock(
                              width: 32,
                              height: 32,
                              radius: 10,
                              color: color,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppSkeletonLine(
                                    width: index == 0 ? 120 : 150,
                                    height: 14,
                                    color: color,
                                  ),
                                  const SizedBox(height: 7),
                                  AppSkeletonLine(
                                    width: double.infinity,
                                    height: 10,
                                    color: color,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (index != 2) const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
