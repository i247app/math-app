import 'package:material_ui/material_ui.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

import 'home_progress_chart_skeleton.dart';

import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class HomeContentSkeleton extends StatelessWidget {
  const HomeContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AppSkeletonLoader(
        builder: (context, color) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AppSkeletonBlock(
                width: 52,
                height: 48,
                radius: 8,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            AppSkeletonBlock(height: 40, radius: 20, color: color),
            const SizedBox(height: 18),
            HomeProgressChartSkeleton(color: color),
            const SizedBox(height: 24),
            Row(
              children: [
                for (var i = 0; i < 2; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: AppSkeletonBlock(
                      height:
                          126 +
                          (MediaQuery.textScalerOf(context).scale(18) / 18 - 1)
                                  .clamp(0, double.infinity) *
                              48,
                      radius: 18,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
