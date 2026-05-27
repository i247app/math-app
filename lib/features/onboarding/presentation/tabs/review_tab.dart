import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/practice_catalog.dart';
import '../screens/practice_chapter_screen.dart';

const _reviewInk = Color(0xFF14213D);
const _reviewMuted = Color(0xFF77859A);
const _progressGreen = Color(0xFF48B457);
const _reviewBackground = Color(0xFFEEF9FB);
const _headerNavy = Color(0xFF063A7B);
const _headerLine = Color(0xFFDE8C4B);

class ReviewTab extends StatelessWidget {
  const ReviewTab({
    super.key,
    required this.bottomPadding,
    required this.scale,
  });

  final double bottomPadding;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final totalLessons = gradeOnePracticeChapters.fold<int>(
      0,
      (sum, chapter) => sum + chapter.lessonCount,
    );
    final completedLessons = gradeOnePracticeChapters.fold<int>(
      0,
      (sum, chapter) => sum + chapter.completedLessons,
    );

    return ColoredBox(
      color: _reviewBackground,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReviewHeader(scale: scale),
            SizedBox(height: 18 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: '📝',
                          value: '$totalLessons',
                          label: 'Bài tập',
                          scale: scale,
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: _StatTile(
                          icon: '🔥',
                          value: '365',
                          label: 'Ngày',
                          scale: scale,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 26 * scale),
                  for (final chapter in gradeOnePracticeChapters) ...[
                    _ChapterCard(
                      chapter: chapter,
                      completedLessons: completedLessons,
                      totalLessons: totalLessons,
                      scale: scale,
                    ),
                    SizedBox(height: 18 * scale),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70 * scale,
      child: CustomPaint(
        painter: _ReviewHeaderCurvePainter(scale: scale),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            8 * scale,
            20 * scale,
            12 * scale,
          ),
          child: Row(
            children: [
              SizedBox(width: 44 * scale),
              Expanded(
                child: Text(
                  'Lộ Trình Học Tập',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _headerNavy,
                    fontFamily: 'Nunito',
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

class _ReviewHeaderCurvePainter extends CustomPainter {
  const _ReviewHeaderCurvePainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = _reviewBackground;
    canvas.drawRect(Offset.zero & size, background);

    final line = Paint()
      ..color = _headerLine.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 * scale;
    final path = Path()
      ..moveTo(0, size.height - 6 * scale)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 6 * scale,
        size.width,
        size.height - 6 * scale,
      );
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _ReviewHeaderCurvePainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.scale,
  });

  final String icon;
  final String value;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78 * scale,
      padding: EdgeInsets.symmetric(horizontal: 18 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46 * scale,
            height: 46 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2FF),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: TextStyle(fontSize: 26 * scale, height: 1),
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _reviewInk,
                    fontFamily: 'Nunito',
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _reviewMuted,
                    fontFamily: 'Nunito',
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.completedLessons,
    required this.totalLessons,
    required this.scale,
  });

  final PracticeChapter chapter;
  final int completedLessons;
  final int totalLessons;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = _chapterColors(chapter.number);
    final locked = chapter.isLocked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PracticeChapterScreen(chapter: chapter),
            ),
          );
        },
        borderRadius: BorderRadius.circular(28 * scale),
        child: Ink(
          height: 226 * scale,
          padding: EdgeInsets.all(24 * scale),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(28 * scale),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.13),
                blurRadius: 22 * scale,
                offset: Offset(0, 10 * scale),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Badge(icon: chapter.icon, scale: scale),
              SizedBox(height: 22 * scale),
              Text(
                'Chương ${chapter.number} • ${chapter.lessonCount} bài học',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _reviewMuted,
                  fontFamily: 'Nunito',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 8 * scale),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    chapter.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _reviewInk,
                      fontFamily: 'Nunito',
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16 * scale),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10 * scale,
                  value: locked ? 0 : chapter.progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.56),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    locked
                        ? Colors.white.withValues(alpha: 0.50)
                        : _progressGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.scale});

  final String icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58 * scale,
      height: 58 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        icon,
        style: TextStyle(fontSize: 28 * scale, height: 1),
      ),
    );
  }
}

class _ChapterCardColors {
  const _ChapterCardColors({
    required this.background,
    required this.shadow,
  });

  final Color background;
  final Color shadow;
}

_ChapterCardColors _chapterColors(int number) {
  return switch (number) {
    1 => const _ChapterCardColors(
        background: Color(0xFFBFEFF4),
        shadow: Color(0xFF62C7D2),
      ),
    2 => const _ChapterCardColors(
        background: Color(0xFFD9F1DD),
        shadow: Color(0xFF8DD39C),
      ),
    3 => const _ChapterCardColors(
        background: Color(0xFFEADDF7),
        shadow: Color(0xFFBDA1DA),
      ),
    _ => const _ChapterCardColors(
        background: Color(0xFFFFF0B9),
        shadow: Color(0xFFE8C85A),
      ),
  };
}
