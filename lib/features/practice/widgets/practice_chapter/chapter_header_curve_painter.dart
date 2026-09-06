part of '../../screens/practice_chapter_screen.dart';

class _ChapterHeaderCurvePainter extends CustomPainter {
  const _ChapterHeaderCurvePainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = _pathBackground;
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
  bool shouldRepaint(covariant _ChapterHeaderCurvePainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}
