import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/widgets/sections/guide_list/guide_list.dart';

abstract final class InitialAssessmentGuideItemId {
  static const assessment = 'assessment';
  static const roadmap = 'roadmap';
  static const classroom = 'classroom';
}

List<GuideItemData> initialAssessmentGuideItems(BuildContext context) {
  final colors = context.themeColors;
  return [
    GuideItemData(
      id: InitialAssessmentGuideItemId.assessment,
      icon: Icons.fact_check_rounded,
      color: colors.brandStrong,
      title: context.getText(AppKeys.parentAssessmentTitle),
      description: context.getText(AppKeys.parentAssessmentSubtitle),
    ),
    GuideItemData(
      id: InitialAssessmentGuideItemId.roadmap,
      icon: Icons.sports_esports_rounded,
      color: colors.accent,
      title: context.getText(AppKeys.parentRoadmapTitle),
      description: context.getText(AppKeys.parentRoadmapSubtitle),
    ),
    GuideItemData(
      id: InitialAssessmentGuideItemId.classroom,
      icon: Icons.meeting_room_rounded,
      color: colors.info,
      title: context.getText(AppKeys.parentJoinRoomTitle),
      description: context.getText(AppKeys.parentJoinRoomSubtitle),
    ),
  ];
}
