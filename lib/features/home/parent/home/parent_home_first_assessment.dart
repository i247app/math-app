part of '../../home_screen.dart';

extension _ParentHomeFirstAssessmentView on _ParentHomeContentState {
  Widget _buildFirstAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _modeOneFadeIn(
          order: 1,
          child: _HomeInitialAssessmentBanner(onTap: _openAssessment),
        ),
        const SizedBox(height: 8),
        _modeOneFadeIn(
          order: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ParentImageAction(
                  asset: _parentHomeAfterReviewBanner,
                  height: 160,
                  alignment: Alignment.centerLeft,
                  onTap: widget.args.onOpenReviewTab,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ParentImageAction(
                  asset: _parentHomeClassroom,
                  height: 160,
                  onTap: _showClassroomMessage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _modeOneFadeIn(
          order: 3,
          markOnEnd: true,
          child: _ParentStartGuideCard(
            onAssessmentTap: _openAssessment,
            onRoadmapTap: widget.args.onOpenReviewTab,
            onClassroomTap: _showClassroomMessage,
          ),
        ),
      ],
    );
  }
}
