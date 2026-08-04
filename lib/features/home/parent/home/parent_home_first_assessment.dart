import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_assessment_banner.dart';
import 'package:numi/features/home/widgets/home_start_guide_card.dart';
import 'package:numi/features/home/widgets/promo_actions/promo_actions.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';

extension ParentHomeFirstAssessmentView on ParentHomeContentState {
  Widget buildFirstAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        initialAssessmentFadeIn(
          order: 1,
          child: HomeAssessmentBanner(
            asset: homeInitialAssessmentBannerAsset,
            onTap: openAssessment,
          ),
        ),
        initialAssessmentFadeIn(
          order: 2,
          child: PromoActionsSection(
            children: [
              PromoActionCard(
                data: PromoActionData(
                  image: const AssetImage(parentHomeAfterReviewBannerAsset),
                  alignment: Alignment.centerLeft,
                  onTap: widget.onOpenPracticeTab,
                ),
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
          child: initialAssessmentFadeIn(
            order: 3,
            markOnEnd: true,
            child: HomeStartGuideCard(
              onAssessmentTap: openAssessment,
              onRoadmapTap: widget.onOpenPracticeTab,
              onClassroomTap: showClassroomMessage,
            ),
          ),
        ),
      ],
    );
  }
}
