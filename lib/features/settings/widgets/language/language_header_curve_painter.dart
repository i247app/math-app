import 'package:flutter/material.dart';

class LanguageHeaderCurvePainter extends CustomPainter {
  const LanguageHeaderCurvePainter({
    required this.scale,
    required this.backgroundColor,
    required this.lineColor,
  });

  final double scale;
  final Color backgroundColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 * scale;

    final path = Path()
      ..moveTo(0, size.height - 12 * scale)
      ..quadraticBezierTo(
        size.width / 2,
        size.height - 4 * scale,
        size.width,
        size.height - 12 * scale,
      );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant LanguageHeaderCurvePainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.lineColor != lineColor;
  }
}
