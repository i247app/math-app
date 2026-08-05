import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_line.dart';

class ParentChildOverviewSkeleton extends StatefulWidget {
  const ParentChildOverviewSkeleton({super.key});

  @override
  State<ParentChildOverviewSkeleton> createState() =>
      _ParentChildOverviewSkeletonState();
}

class _ParentChildOverviewSkeletonState
    extends State<ParentChildOverviewSkeleton>
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
        final pulseColor = Color.lerp(
          colors.skeleton,
          colors.border,
          _controller.value,
        )!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSkeletonBlock(
              height: 104,
              radius: 14,
              color: colors.elevatedSurface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    AppSkeletonLine(width: 104, height: 16, color: pulseColor),
                    AppSkeletonLine(width: 176, height: 24, color: pulseColor),
                    AppSkeletonLine(width: 128, height: 14, color: pulseColor),
                  ],
                ),
              ),
            ),
            for (var index = 0; index < 3; index++)
              Padding(
                padding: EdgeInsets.only(top: index == 0 ? 12 : 14),
                child: _ParentOverviewSectionSkeleton(color: pulseColor),
              ),
          ],
        );
      },
    );
  }
}

class _ParentOverviewSectionSkeleton extends StatelessWidget {
  const _ParentOverviewSectionSkeleton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBlock(
      radius: 22,
      color: color,
      outlined: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            AppSkeletonLine(width: 156, height: 20, color: color),
            const SizedBox(height: 2),
            _ParentOverviewListRowSkeleton(color: color),
            Divider(height: 20, indent: 62, color: color),
            _ParentOverviewListRowSkeleton(color: color),
          ],
        ),
      ),
    );
  }
}

class _ParentOverviewListRowSkeleton extends StatelessWidget {
  const _ParentOverviewListRowSkeleton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 14,
      children: [
        AppSkeletonBlock(width: 48, height: 48, radius: 12, color: color),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              AppSkeletonLine(width: 126, height: 11, color: color),
              AppSkeletonLine(width: double.infinity, height: 15, color: color),
            ],
          ),
        ),
      ],
    );
  }
}
