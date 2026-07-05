part of '../../home_screen.dart';

extension _ParentHomeFirstAssessmentView on _ParentHomeContentState {
  Widget _buildFirstAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _initialAssessmentFadeIn(
          order: 1,
          child: HomeInitialAssessmentBanner(onTap: _openAssessment),
        ),
        const SizedBox(height: 8),
        _initialAssessmentFadeIn(
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
                  onTap: _showClassroomMessage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _initialAssessmentFadeIn(
          order: 3,
          markOnEnd: true,
          child: HomeStartGuideCard(
            onAssessmentTap: _openAssessment,
            onRoadmapTap: widget.args.onOpenPracticeTab,
            onClassroomTap: _showClassroomMessage,
          ),
        ),
      ],
    );
  }
}
