part of '../../screens/practice_chapter_screen.dart';

class _CompletedLessonDialog extends StatelessWidget {
  const _CompletedLessonDialog({required this.lesson});

  final PracticeLesson lesson;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width - 40, 390.0);
    final scale = width / PracticeChapterScreen._designWidth;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20 * scale),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(22 * scale),
        decoration: BoxDecoration(
          color: _reviewGreen,
          borderRadius: BorderRadius.circular(24 * scale),
          boxShadow: [
            BoxShadow(color: _reviewGreenShadow, offset: Offset(0, 7 * scale)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              lesson.title,
              style: GoogleFonts.andika(
                color: Colors.white,
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            SizedBox(height: 10 * scale),
            Text(
              context.getText(AppKeys.improveMathTypePrompt),
              style: GoogleFonts.andika(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            SizedBox(height: 22 * scale),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14 * scale),
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(14 * scale),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15 * scale),
                  child: Text(
                    context.getText(AppKeys.reviewLessonAction).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.andika(
                      color: _reviewGreen,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
