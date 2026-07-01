part of '../../presentation/practice_chapter_screen.dart';

class _CurrentLessonBubble extends StatelessWidget {
  const _CurrentLessonBubble({required this.title, required this.scale});

  final String title;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: 48 * scale,
            maxWidth: 190 * scale,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 10 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13 * scale),
            border: Border.all(
              color: const Color(0xFFE2E6E9),
              width: 2 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: _pathBlue,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
        CustomPaint(
          size: Size(16 * scale, 9 * scale),
          painter: const _BubbleArrowPainter(),
        ),
      ],
    );
  }
}
