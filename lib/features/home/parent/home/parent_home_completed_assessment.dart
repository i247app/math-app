import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_assessment_banner.dart';
import 'package:numi/features/home/widgets/home_image_action.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';

extension ParentHomeCompletedAssessmentView on ParentHomeContentState {
  Widget buildCompletedState() {
    const promoActionGap = 7.0;
    const stackedPromoActionHeight =
        (parentHomePromoActionHeight - promoActionGap) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        completedAssessmentFadeIn(
          order: 1,
          child: HomeAssessmentBanner(
            asset: parentHomeAfterReviewBannerAsset,
            onTap: widget.onOpenPracticeTab,
          ),
        ),
        completedAssessmentFadeIn(
          order: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Expanded(
                child: Column(
                  spacing: promoActionGap,
                  children: [
                    HomeImageAction(
                      asset: parentHomeRaceAsset,
                      height: stackedPromoActionHeight,
                      onTap: widget.onOpenPracticeTab,
                    ),
                    HomeImageAction(
                      asset: parentHomeShopAsset,
                      height: stackedPromoActionHeight,
                      onTap: widget.onOpenPracticeTab,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: HomeImageAction(
                  asset: parentHomeClassroomAsset,
                  height: parentHomePromoActionHeight,
                  onTap: showClassroomMessage,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            spacing: 8,
            children: [
              for (final entry in completedAssessments.take(2).indexed)
                completedAssessmentFadeIn(
                  order: 3 + entry.$1,
                  markOnEnd:
                      entry.$1 == 1 ||
                      entry.$1 == completedAssessments.take(2).length - 1,
                  child: AssessmentResultListItemCard(
                    quiz: entry.$2,
                    onTap: () => openParentAssessmentResult(entry.$2),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
