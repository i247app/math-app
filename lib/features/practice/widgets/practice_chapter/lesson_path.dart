part of '../../screens/practice_chapter_screen.dart';

class _LessonPath extends StatelessWidget {
  const _LessonPath({
    required this.chapter,
    required this.lessonKeys,
    required this.scrollController,
    required this.mascotAnimation,
    required this.currentIndex,
    required this.onLayoutReady,
    required this.onCompletedLessonTap,
    this.onLessonTap,
    required this.bottomPadding,
    required this.scale,
  });

  final PracticeChapter chapter;
  final List<GlobalKey> lessonKeys;
  final ScrollController scrollController;
  final Animation<double> mascotAnimation;
  final int currentIndex;
  final VoidCallback onLayoutReady;
  final ValueChanged<PracticeLesson> onCompletedLessonTap;
  final ValueChanged<PracticeLesson>? onLessonTap;
  final double bottomPadding;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final contentHeight = math.max(
      720.0 * scale,
      (chapter.lessons.length * 138 + 190) * scale,
    );

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      reverse: true,
      padding: EdgeInsets.only(bottom: bottomPadding + 34 * scale),
      child: SizedBox(
        height: contentHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final points = _nodePoints(
              width,
              contentHeight,
              chapter.lessons.length,
            );
            final mascotIndex = math.min(
              currentIndex + 2,
              chapter.lessons.length - 1,
            );
            final mascotPoint = points[mascotIndex];
            final mascotOnLeft = mascotPoint.dx > width * 0.55;
            final mascotLeft = mascotOnLeft
                ? mascotPoint.dx - 142 * scale
                : mascotPoint.dx + 38 * scale;
            final mascotTop = mascotPoint.dy - 48 * scale;
            onLayoutReady();

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: mascotLeft.clamp(8 * scale, width - 100 * scale),
                  top: mascotTop.clamp(24 * scale, contentHeight - 130 * scale),
                  child: _NumiMascot(animation: mascotAnimation, scale: scale),
                ),
                for (var index = 0; index < chapter.lessons.length; index++)
                  Positioned(
                    left: points[index].dx - 110 * scale,
                    top: points[index].dy - 103 * scale,
                    child: _LessonNode(
                      key: lessonKeys[index],
                      lesson: chapter.lessons[index],
                      index: index,
                      chapter: chapter,
                      onCompletedTap: onCompletedLessonTap,
                      onLessonTap: onLessonTap,
                      scale: scale,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
