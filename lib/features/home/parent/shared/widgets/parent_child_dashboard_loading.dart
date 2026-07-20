import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_line.dart';

class ParentChildDashboardLoading extends StatefulWidget {
  const ParentChildDashboardLoading({super.key});

  @override
  State<ParentChildDashboardLoading> createState() =>
      _ParentChildDashboardLoadingState();
}

class _ParentChildDashboardLoadingState
    extends State<ParentChildDashboardLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
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
      builder: (context, _) {
        final colors = context.themeColors;
        final color = Color.lerp(
          colors.skeleton,
          colors.border,
          _controller.value,
        )!;
        return Column(
          children: [
            Row(
              spacing: 12,
              children: List.generate(
                2,
                (_) => Expanded(
                  child: AppSkeletonBlock(
                    height: 121,
                    radius: 18,
                    color: color,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 22,
                      ),
                      child: Column(
                        spacing: 12,
                        children: [
                          AppSkeletonLine(width: 70, height: 12, color: color),
                          AppSkeletonLine(width: 88, height: 28, color: color),
                          AppSkeletonLine(width: 96, height: 10, color: color),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            for (var index = 0; index < 2; index++) ...[
              Padding(
                padding: EdgeInsets.only(top: index == 0 ? 14 : 0, bottom: 10),
                child: AppSkeletonBlock(
                  height: 98,
                  radius: 18,
                  color: color,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      spacing: 14,
                      children: [
                        AppSkeletonBlock(
                          width: 50,
                          height: 50,
                          radius: 25,
                          color: color,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSkeletonLine(
                                width: 94,
                                height: 10,
                                color: color,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: AppSkeletonLine(
                                  width: double.infinity,
                                  height: 16,
                                  color: color,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: AppSkeletonLine(
                                  width: 120,
                                  height: 10,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            for (var index = 0; index < 2; index++) ...[
              Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                child: AppSkeletonBlock(
                  height: 190,
                  radius: 22,
                  color: color,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          spacing: 12,
                          children: [
                            AppSkeletonBlock(
                              width: 48,
                              height: 48,
                              radius: 13,
                              color: color,
                            ),
                            Expanded(
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppSkeletonLine(
                                    width: 135,
                                    height: 15,
                                    color: color,
                                  ),
                                  AppSkeletonLine(
                                    width: 70,
                                    height: 9,
                                    color: color,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: AppSkeletonBlock(radius: 13, color: color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
