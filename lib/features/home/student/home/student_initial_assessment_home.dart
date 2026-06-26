part of '../../home_screen.dart';

extension _StudentInitialAssessmentHomeView on _StudentHomeContentState {
  Widget _buildStudentInitialAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _studentHomeEntrance(
          order: 0,
          child: _HomeInitialAssessmentBanner(
            onTap: () => _openGradeSelection(quizPurposeAssessment),
          ),
        ),
        const SizedBox(height: 8),
        _studentHomeEntrance(
          order: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HomeImageAction(
                  asset: _parentHomeAfterReviewBanner,
                  height: 160,
                  alignment: Alignment.centerLeft,
                  onTap: widget.onOpenReviewTab,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HomeImageAction(
                  asset: _parentHomeClassroom,
                  height: 160,
                  onTap: widget.activeRole == ProfileRole.student
                      ? widget.onOpenClassroomTab
                      : _handleParentClassroomEntry,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _studentHomeEntrance(
          order: 2,
          markOnEnd: true,
          child: _HomeStartGuideCard(
            onAssessmentTap: () => _openGradeSelection(quizPurposeAssessment),
            onRoadmapTap: widget.onOpenReviewTab,
            onClassroomTap: widget.onOpenClassroomTab,
          ),
        ),
      ],
    );
  }
}
