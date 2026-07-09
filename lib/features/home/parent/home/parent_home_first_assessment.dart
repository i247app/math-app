import 'package:flutter/material.dart';
import 'package:numi_flutter/features/home/widgets/home_image_action.dart';
import 'package:numi_flutter/features/home/widgets/home_initial_assessment_banner.dart';
import 'package:numi_flutter/features/home/widgets/home_start_guide_card.dart';
import 'package:numi_flutter/features/home/widgets/home_visual_constants.dart';
import 'package:numi_flutter/features/home/parent/home/parent_home_tab.dart';

extension ParentHomeFirstAssessmentView on ParentHomeContentState {
  Widget buildFirstAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        initialAssessmentFadeIn(
          order: 1,
          child: HomeInitialAssessmentBanner(onTap: openAssessment),
        ),
        const SizedBox(height: 8),
        initialAssessmentFadeIn(
          order: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HomeImageAction(
                  asset: parentHomeAfterReviewBannerAsset,
                  height: 160,
                  alignment: Alignment.centerLeft,
                  onTap: widget.args.onOpenPracticeTab,
                ),
              ),
              const SizedBox(width: 10),
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
        const SizedBox(height: 12),
        initialAssessmentFadeIn(
          order: 3,
          markOnEnd: true,
          child: HomeStartGuideCard(
            onAssessmentTap: openAssessment,
            onRoadmapTap: widget.args.onOpenPracticeTab,
            onClassroomTap: showClassroomMessage,
          ),
        ),
      ],
    );
  }
}
