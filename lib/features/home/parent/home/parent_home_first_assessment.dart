import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_image_action.dart';
import 'package:numi/features/home/widgets/home_initial_assessment_banner.dart';
import 'package:numi/features/home/widgets/home_start_guide_card.dart';
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
          child: HomeInitialAssessmentBanner(onTap: openAssessment),
        ),
        initialAssessmentFadeIn(
          order: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Expanded(
                child: HomeImageAction(
                  asset: parentHomeAfterReviewBannerAsset,
                  height: 160,
                  alignment: Alignment.centerLeft,
                  onTap: widget.onOpenPracticeTab,
                ),
              ),
              Expanded(
                child: HomeImageAction(
                  asset: parentHomeClassroomAsset,
                  height: 160,
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
