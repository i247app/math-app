import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentDashedCirclePainter extends CustomPainter {
  const ParentDashedCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE6B5A7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final radius = (math.min(size.width, size.height) - paint.strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
    const dashAngle = 0.22;
    const gapAngle = 0.20;
    for (double start = 0; start < math.pi * 2; start += dashAngle + gapAngle) {
      canvas.drawArc(rect, start, dashAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}