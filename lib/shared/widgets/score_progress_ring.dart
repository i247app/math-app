import 'dart:math' as math;

import 'package:flutter/material.dart';

class ScoreProgressRing extends StatelessWidget {
  const ScoreProgressRing({
    super.key,
    required this.progress,
    required this.color,
    required this.size,
    required this.strokeWidth,
    required this.child,
    this.trackColor,
  });

  final double progress;
  final Color color;
  final Color? trackColor;
  final double size;
  final double strokeWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScoreProgressRingPainter(
          progress: progress.clamp(0, 1).toDouble(),
          color: color,
          trackColor: trackColor ?? color.withValues(alpha: 0.20),
          strokeWidth: strokeWidth,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _ScoreProgressRingPainter extends CustomPainter {
  const _ScoreProgressRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) {
      return;
    }

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (progress >= 0.999) {
      canvas.drawCircle(
        center,
        radius,
        progressPaint..strokeCap = StrokeCap.butt,
      );
      return;
    }

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
