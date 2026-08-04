import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_assessment_banner.dart';
import 'package:numi/features/home/widgets/promo_actions/promo_actions.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';

extension ParentHomeCompletedAssessmentView on ParentHomeContentState {
  Widget buildCompletedState() {
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
          child: PromoActionsSection(
            children: [
              PromoActionGroup(
                direction: Axis.vertical,
                spacing: 7,
                children: [
                  PromoActionCard(
                    data: PromoActionData(
                      image: const AssetImage(parentHomeRaceAsset),
                      onTap: widget.onOpenPracticeTab,
                    ),
                  ),
                  PromoActionCard(
                    data: PromoActionData(
                      image: const AssetImage(parentHomeShopAsset),
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
