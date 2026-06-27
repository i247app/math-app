import 'package:flutter/material.dart';

import 'package:numi_flutter/features/settings/settings_style.dart';

class LanguageHeaderCurvePainter extends CustomPainter {
  const LanguageHeaderCurvePainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = settingsLanguageBackground;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final linePaint = Paint()
      ..color = settingsLanguageHeaderLine.withValues(alpha: 0.78)
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
    return oldDelegate.scale != scale;
  }
}
