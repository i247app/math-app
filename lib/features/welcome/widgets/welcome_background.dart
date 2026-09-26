import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class WelcomeBackground extends StatelessWidget {
  const WelcomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _WelcomeWavesPainter(
          background: context.themeColors.pageBackground,
          wave: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF4AA6A0)
              : const Color(0xFF8BC8C8),
        ),
      ),
    );
  }
}

class _WelcomeWavesPainter extends CustomPainter {
  const _WelcomeWavesPainter({required this.background, required this.wave});

  final Color background;
  final Color wave;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    for (final layer in const [
      (top: 0.625, depth: 0.14, alpha: 0.055),
      (top: 0.705, depth: 0.10, alpha: 0.085),
      (top: 0.785, depth: 0.07, alpha: 0.07),
      (top: 0.845, depth: 0.04, alpha: 0.06),
    ]) {
      final path = Path()
        ..moveTo(0, h * layer.top)
        ..cubicTo(
          w * 0.20,
          h * (layer.top + 0.015),
          w * 0.32,
          h * (layer.top + layer.depth),
          w * 0.51,
          h * (layer.top + layer.depth * 0.67),
        )
        ..cubicTo(
          w * 0.72,
          h * (layer.top + layer.depth * 0.76),
          w * 0.83,
          h * (layer.top - 0.01),
          w,
          h * (layer.top - 0.005),
        )
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              wave.withValues(alpha: layer.alpha),
              wave.withValues(alpha: layer.alpha * 0.6),
            ],
          ).createShader(Rect.fromLTRB(0, h * layer.top, w, h)),
      );
    }
  }

  @override
  bool shouldRepaint(_WelcomeWavesPainter oldDelegate) =>
      background != oldDelegate.background || wave != oldDelegate.wave;
}
