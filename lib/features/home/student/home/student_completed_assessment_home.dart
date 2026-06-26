part of '../../home_screen.dart';

extension _StudentCompletedAssessmentHomeView on _StudentHomeContentState {
  Widget _buildStudentCompletedAssessmentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _studentHomeEntrance(
          order: 0,
          child: _HomeImageAction(
            asset: _parentHomeAfterReviewBanner,
            height: 214,
            onTap: widget.onOpenReviewTab,
          ),
        ),
        const SizedBox(height: 8),
        _studentHomeEntrance(
          order: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _HomeImageAction(
                      asset: _parentHomeRace,
                      height: 83,
                      onTap: widget.onOpenReviewTab,
                    ),
                    const SizedBox(height: 7),
                    _HomeImageAction(
                      asset: _parentHomeShop,
                      height: 83,
                      onTap: widget.onOpenReviewTab,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HomeImageAction(
                  asset: _parentHomeClassroom,
                  height: 173,
                  onTap: widget.onOpenClassroomTab,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in _completedAssessments.take(2).indexed) ...[
          _studentHomeEntrance(
            order: 2 + entry.$1,
            markOnEnd: entry.$1 == 1 ||
                entry.$1 == _completedAssessments.take(2).length - 1,
            child: _HomeAssessmentResultCard(
              quiz: entry.$2,
              onTap: () => _openStudentAssessmentResult(entry.$2),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
