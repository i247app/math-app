import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';

/// Mirrors the chart's padding, header metrics, spacing and plot height.
class HomeProgressChartSkeleton extends StatelessWidget {
  const HomeProgressChartSkeleton({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => AppSkeletonBlock(
    radius: 28,
    color: color,
    outlined: true,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0,
            child: AssessmentProgressionChartHeader(
              gradeTitle: context.getText(AppKeys.homeChartLevel),
              activityTitle: context.getText(AppKeys.homeChartActivity),
            ),
          ),
          const SizedBox(height: 18),
          const SizedBox(height: 150),
        ],
      ),
    ),
  );
}
