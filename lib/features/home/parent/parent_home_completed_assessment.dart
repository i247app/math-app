part of '../home_screen.dart';

extension _ParentHomeCompletedAssessmentView on _ParentHomeContentState {
  Widget _buildCompletedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _modeTwoFadeIn(
          child: _ParentImageAction(
            asset: _parentHomeAfterReviewBanner,
            height: 214,
            onTap: widget.args.onOpenReviewTab,
          ),
        ),
        const SizedBox(height: 8),
        _modeTwoFadeIn(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _ParentImageAction(
                      asset: _parentHomeRace,
                      height: 83,
                      onTap: widget.args.onOpenReviewTab,
                    ),
                    const SizedBox(height: 7),
                    _ParentImageAction(
                      asset: _parentHomeShop,
                      height: 72,
                      onTap: widget.args.onOpenReviewTab,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ParentImageAction(
                  asset: _parentHomeClassroom,
                  height: 162,
                  onTap: _showClassroomMessage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final quiz in _completedAssessments.take(2)) ...[
          _modeTwoFadeIn(
            child: _ParentAssessmentResultCard(
              quiz: quiz,
              onTap: () => _openQuizReview(quiz),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
