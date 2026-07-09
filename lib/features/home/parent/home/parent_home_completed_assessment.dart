part of '../../home_screen.dart';

extension _ParentHomeCompletedAssessmentView on _ParentHomeContentState {
  Widget _buildCompletedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _completedAssessmentFadeIn(
          order: 1,
          child: HomeImageAction(
            asset: parentHomeAfterReviewBannerAsset,
            height: 214,
            onTap: widget.args.onOpenPracticeTab,
          ),
        ),
        const SizedBox(height: 8),
        _completedAssessmentFadeIn(
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
                      onTap: widget.args.onOpenPracticeTab,
                    ),
                    const SizedBox(height: 7),
                    HomeImageAction(
                      asset: parentHomeShopAsset,
                      height: 83,
                      onTap: widget.args.onOpenPracticeTab,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HomeImageAction(
                  asset: parentHomeClassroomAsset,
                  height: 173,
                  onTap: _showClassroomMessage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in _completedAssessments.take(2).indexed) ...[
          _completedAssessmentFadeIn(
            order: 3 + entry.$1,
            markOnEnd:
                entry.$1 == 1 ||
                entry.$1 == _completedAssessments.take(2).length - 1,
            child: _AssessmentResultListItemCard(
              quiz: entry.$2,
              scale: widget.args.scale,
              onTap: () => _openParentAssessmentResult(entry.$2),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
