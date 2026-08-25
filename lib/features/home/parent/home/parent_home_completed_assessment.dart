import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/sections/assessment_list/assessment_list.dart';
import 'package:numi/features/home/widgets/sections/banner/banner.dart';
import 'package:numi/features/home/widgets/sections/promo_actions/promo_actions.dart';
import 'package:numi/features/home/widgets/home_game_preview_artwork.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';

extension ParentHomeCompletedAssessmentView on ParentHomeContentState {
  Widget buildCompletedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        homeEntrance(
          mode: ParentHomeEntranceMode.completedAssessment,
          order: 1,
          child: HomeBanner(
            data: HomeBannerData(
              image: const AssetImage(parentHomeAfterReviewBannerAsset),
              onTap: widget.onOpenPracticeTab,
            ),
          ),
        ),
        homeEntrance(
          mode: ParentHomeEntranceMode.completedAssessment,
          order: 2,
          child: PromoActionsSection(
            children: [
              PromoActionGroup(
                direction: Axis.vertical,
                spacing: 7,
                children: [
                  PromoActionCard(
                    data: PromoActionData(
                      child: const HomeGamePreviewArtwork(
                        assetPath: parentHomeNumiFarmAsset,
                        title: 'NUMI FARM',
                        alignment: Alignment(0, 0.12),
                      ),
                      semanticLabel: 'Numi Farm',
                      onTap: widget.onOpenPracticeTab,
                    ),
                  ),
                  PromoActionCard(
                    data: PromoActionData(
                      child: const HomeGamePreviewArtwork(
                        assetPath: parentHomeMonsterRescueAsset,
                        title: 'ELECTRIC RESCUE',
                        alignment: Alignment(0, 0.08),
                      ),
                      semanticLabel: 'Electric Rescue',
                      onTap: widget.onOpenPracticeTab,
                    ),
                  ),
                ],
              ),
              PromoActionCard(
                data: PromoActionData(
                  image: const AssetImage(parentHomeClassroomAsset),
                  onTap: showClassroomMessage,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: AssessmentListSection(
            assessments: completedAssessments,
            onAssessmentTap: openParentAssessmentResult,
            itemWrapper: (child, index, itemCount) => homeEntrance(
              mode: ParentHomeEntranceMode.completedAssessment,
              order: 3 + index,
              markOnEnd: index == itemCount - 1,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
