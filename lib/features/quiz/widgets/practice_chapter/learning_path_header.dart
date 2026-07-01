part of '../../presentation/practice_chapter_screen.dart';

class _LearningPathHeader extends StatelessWidget {
  const _LearningPathHeader({
    required this.chapter,
    required this.lesson,
    required this.scale,
    this.onBack,
    this.showChapterLabel = true,
  });

  final PracticeChapter chapter;
  final PracticeLesson lesson;
  final double scale;
  final VoidCallback? onBack;
  final bool showChapterLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        12 * scale,
        18 * scale,
        10 * scale,
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: 104 * scale),
        decoration: BoxDecoration(
          color: _headerTeal,
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: [
            BoxShadow(color: _headerTealShadow, offset: Offset(0, 6 * scale)),
          ],
        ),
        child: Row(
          children: [
            if (onBack != null)
              Padding(
                padding: EdgeInsets.only(left: 12 * scale),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.94),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onBack!();
                    },
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 42 * scale,
                      height: 42 * scale,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: _headerTeal,
                        size: 24 * scale,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  (onBack == null ? 22 : 12) * scale,
                  16 * scale,
                  14 * scale,
                  16 * scale,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showChapterLabel) ...[
                      Text(
                        context.formatText(AppKeys.learningPathChapterLesson, {
                          'chapter': chapter.number,
                          'lesson': lesson.number,
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                    ],
                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: Colors.white,
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 72 * scale,
              constraints: BoxConstraints(minHeight: 104 * scale),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: _headerTealShadow.withValues(alpha: 0.7),
                    width: 2 * scale,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.format_list_numbered_rounded,
                color: Colors.white,
                size: 32 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
