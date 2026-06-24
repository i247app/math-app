part of '../home_screen.dart';

extension _ParentHomeCompletedAssessmentView on _ParentHomeContentState {
  Widget _buildCompletedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _modeTwoFadeIn(
          order: 1,
          child: _ParentImageAction(
            asset: _parentHomeAfterReviewBanner,
            height: 214,
            onTap: widget.args.onOpenReviewTab,
          ),
        ),
        const SizedBox(height: 8),
        _modeTwoFadeIn(
          order: 2,
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
                      height: 83,
                      onTap: widget.args.onOpenReviewTab,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ParentImageAction(
                  asset: _parentHomeClassroom,
                  height: 173,
                  onTap: _showClassroomMessage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in _completedAssessments.take(2).indexed) ...[
          _modeTwoFadeIn(
            order: 3 + entry.$1,
            markOnEnd: entry.$1 == 1 ||
                entry.$1 == _completedAssessments.take(2).length - 1,
            child: _ParentAssessmentResultCard(
              quiz: entry.$2,
              onTap: () => _openQuizReview(entry.$2),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
