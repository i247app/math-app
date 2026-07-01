part of '../../presentation/practice_chapter_screen.dart';

class _BubbleArrowPainter extends CustomPainter {
  const _BubbleArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) => false;
}
