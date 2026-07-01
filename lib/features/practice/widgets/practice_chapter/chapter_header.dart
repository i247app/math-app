part of '../../presentation/practice_chapter_screen.dart';

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.chapter, required this.scale});

  final PracticeChapter chapter;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70 * scale,
      child: CustomPaint(
        painter: _ChapterHeaderCurvePainter(scale: scale),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            8 * scale,
            20 * scale,
            12 * scale,
          ),
          child: Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.80),
                shadowColor: Colors.black.withValues(alpha: 0.05),
                elevation: 1,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                  },
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 44 * scale,
                    height: 44 * scale,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: _headerNavy,
                      size: 24 * scale,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  context.formatText(AppKeys.chapterNumber, {
                    'number': chapter.number,
                  }),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _headerNavy,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SizedBox(width: 44 * scale),
            ],
          ),
        ),
      ),
    );
  }
}
