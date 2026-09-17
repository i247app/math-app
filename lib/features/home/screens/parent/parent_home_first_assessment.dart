import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/sections/banner/banner.dart';
import 'package:numi/features/home/widgets/sections/guide_list/guide_list.dart';
import 'package:numi/features/home/widgets/initial_assessment_guide_items.dart';
import 'package:numi/features/home/widgets/sections/promo_actions/promo_actions.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/home/screens/parent/parent_home_tab.dart';

extension ParentHomeFirstAssessmentView on ParentHomeContentState {
  Widget buildFirstAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        homeEntrance(
          mode: ParentHomeEntranceMode.initialAssessment,
          order: 1,
          child: HomeBanner(
            data: HomeBannerData(
              image: const AssetImage(homeInitialAssessmentBannerAsset),
              onTap: openAssessment,
            ),
          ),
        ),
        homeEntrance(
          mode: ParentHomeEntranceMode.initialAssessment,
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
          child: homeEntrance(
            mode: ParentHomeEntranceMode.initialAssessment,
            order: 3,
            markOnEnd: true,
            child: GuideListCard(
              items: initialAssessmentGuideItems(context),
              onItemTap: (itemId) {
                switch (itemId) {
                  case InitialAssessmentGuideItemId.assessment:
                    openAssessment();
                    return;
                  case InitialAssessmentGuideItemId.roadmap:
                    widget.onOpenPracticeTab();
                    return;
                  case InitialAssessmentGuideItemId.classroom:
                    showClassroomMessage();
                    return;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
