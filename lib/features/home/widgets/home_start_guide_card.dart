import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/widgets/home_guide_item.dart';

class HomeStartGuideCard extends StatelessWidget {
  const HomeStartGuideCard({
    super.key,
    required this.onAssessmentTap,
    required this.onRoadmapTap,
    required this.onClassroomTap,
  });

  final VoidCallback onAssessmentTap;
  final VoidCallback onRoadmapTap;
  final VoidCallback onClassroomTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        spacing: 10,
        children: [
          HomeGuideItem(
            icon: Icons.fact_check_rounded,
            color: colors.brandStrong,
            title: context.getText(AppKeys.parentAssessmentTitle),
            subtitle: context.getText(AppKeys.parentAssessmentSubtitle),
            onTap: onAssessmentTap,
          ),
          HomeGuideItem(
            icon: Icons.sports_esports_rounded,
            color: colors.accent,
            title: context.getText(AppKeys.parentRoadmapTitle),
            subtitle: context.getText(AppKeys.parentRoadmapSubtitle),
            onTap: onRoadmapTap,
          ),
          HomeGuideItem(
            icon: Icons.meeting_room_rounded,
            color: colors.info,
            title: context.getText(AppKeys.parentJoinRoomTitle),
            subtitle: context.getText(AppKeys.parentJoinRoomSubtitle),
            onTap: onClassroomTap,
          ),
        ],
      ),
    );
  }
}
