import 'package:material_ui/material_ui.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

import 'home_progress_chart_skeleton.dart';

/// Keeps the grade ribbon and chart space stable while progress is refreshed.
class HomeProgressSkeleton extends StatelessWidget {
  const HomeProgressSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
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
        ],
      ),
    ),
  );
}
