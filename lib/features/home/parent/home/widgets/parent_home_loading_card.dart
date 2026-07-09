import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_shimmer.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_block.dart';
import 'package:numi/features/home/shared/widgets/home_skeleton_line.dart';

class ParentHomeLoadingCard extends StatefulWidget {
  const ParentHomeLoadingCard();

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
        final pulseValue =
            0.5 - 0.5 * math.cos(math.pi * 2 * _controller.value);
        final color = Color.lerp(
          const Color(0xFFF1F3F3),
          const Color(0xFFE1E8E7),
          pulseValue,
        )!;

        return HomeSkeletonShimmer(
          controller: _controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeSkeletonBlock(
                height: 225,
                radius: 30,
                color: color,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeSkeletonLine(width: 148, height: 30, color: color),
                      const SizedBox(height: 14),
                      HomeSkeletonLine(width: 210, height: 34, color: color),
                      const Spacer(),
                      HomeSkeletonLine(width: 132, height: 14, color: color),
                      const SizedBox(height: 12),
                      HomeSkeletonBlock(
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
                    child: HomeSkeletonBlock(
                      height: 160,
                      radius: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: HomeSkeletonBlock(
                      height: 160,
                      radius: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HomeSkeletonBlock(
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
                            HomeSkeletonBlock(
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
                                  HomeSkeletonLine(
                                    width: index == 0 ? 120 : 150,
                                    height: 14,
                                    color: color,
                                  ),
                                  const SizedBox(height: 7),
                                  HomeSkeletonLine(
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