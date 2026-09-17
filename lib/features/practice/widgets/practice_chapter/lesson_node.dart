part of '../../screens/practice_chapter_screen.dart';

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    super.key,
    required this.lesson,
    required this.index,
    required this.chapter,
    required this.onCompletedTap,
    this.onLessonTap,
    required this.scale,
  });

  final PracticeLesson lesson;
  final int index;
  final PracticeChapter chapter;
  final ValueChanged<PracticeLesson> onCompletedTap;
  final ValueChanged<PracticeLesson>? onLessonTap;
  final double scale;

  bool get _completed => index < chapter.completedLessons;

  bool get _current {
    if (chapter.isLocked) {
      return false;
    }
    if (chapter.completedLessons >= chapter.lessons.length) {
      return index == chapter.lessons.length - 1;
    }
    return index == chapter.completedLessons;
  }

  bool get _locked {
    if (chapter.isLocked) {
      return true;
    }
    if (chapter.completedLessons >= chapter.lessons.length) {
      return false;
    }
    return index > chapter.completedLessons;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220 * scale,
      height: 150 * scale,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          if (_current)
            Positioned(
              top: 0,
              child: _CurrentLessonBubble(title: lesson.title, scale: scale),
            ),
          Positioned(
            top: 64 * scale,
            child: GestureDetector(
              onTap: () {
                if (!_locked && onLessonTap != null) {
                  onLessonTap!(lesson);
                  return;
                }
                if (_completed) {
                  onCompletedTap(lesson);
                  return;
                }
                HapticFeedback.selectionClick();
              },
              child: _LevelButton(
                completed: _completed,
                current: _current,
                locked: _locked,
                scale: scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
