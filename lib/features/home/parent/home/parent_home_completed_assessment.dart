import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_image_action.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';

extension ParentHomeCompletedAssessmentView on ParentHomeContentState {
  Widget buildCompletedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        completedAssessmentFadeIn(
          order: 1,
          child: HomeImageAction(
            asset: parentHomeAfterReviewBannerAsset,
            height: 214,
            onTap: widget.onOpenPracticeTab,
          ),
        ),
        const SizedBox(height: 8),
        completedAssessmentFadeIn(
          order: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    HomeImageAction(
                      asset: parentHomeRaceAsset,
                      height: 83,
                      onTap: widget.onOpenPracticeTab,
                    ),
                    const SizedBox(height: 7),
                    HomeImageAction(
                      asset: parentHomeShopAsset,
                      height: 83,
                      onTap: widget.onOpenPracticeTab,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HomeImageAction(
                  asset: parentHomeClassroomAsset,
                  height: 173,
                  onTap: showClassroomMessage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in completedAssessments.take(2).indexed) ...[
          completedAssessmentFadeIn(
            order: 3 + entry.$1,
            markOnEnd:
                entry.$1 == 1 ||
                entry.$1 == completedAssessments.take(2).length - 1,
            child: AssessmentResultListItemCard(
              quiz: entry.$2,
              scale: widget.scale,
              onTap: () => openParentAssessmentResult(entry.$2),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
