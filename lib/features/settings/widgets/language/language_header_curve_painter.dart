import 'package:flutter/material.dart';

class LanguageHeaderCurvePainter extends CustomPainter {
  const LanguageHeaderCurvePainter({
    required this.backgroundColor,
    required this.lineColor,
  });

  final Color backgroundColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final path = Path()
      ..moveTo(0, size.height - 12)
      ..quadraticBezierTo(
        size.width / 2,
        size.height - 4,
        size.width,
        size.height - 12,
      );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant LanguageHeaderCurvePainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.lineColor != lineColor;
  }
}
