import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

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

class ScoreDisplayRing extends StatelessWidget {
  const ScoreDisplayRing({
    super.key,
    required this.scoreText,
    required this.progress,
    required this.ringColor,
    required this.scoreColor,
    this.trackColor,
    this.fillColor,
    this.totalColor,
    this.labelColor,
    this.glowColor,
  });

  final String scoreText;
  final double progress;
  final Color ringColor;
  final Color scoreColor;
  final Color? trackColor;
  final Color? fillColor;
  final Color? totalColor;
  final Color? labelColor;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final slashIndex = scoreText.indexOf('/');
    final scoreValue = slashIndex == -1
        ? scoreText
        : scoreText.substring(0, slashIndex);
    final scoreTotal = slashIndex == -1
        ? '/10'
        : scoreText.substring(slashIndex);
    final resolvedGlowColor = glowColor ?? colors.infoSurface;

    return Center(
      child: SizedBox(
        width: 192,
        height: 168,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 192,
                height: 160,
                decoration: BoxDecoration(
                  color: resolvedGlowColor.withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: resolvedGlowColor.withValues(alpha: 0.70),
                      blurRadius: 32,
                    ),
                  ],
                ),
              ),
            ),
            if (fillColor != null)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: fillColor,
                  shape: BoxShape.circle,
                ),
              ),
            ScoreProgressRing(
              progress: progress,
              color: ringColor,
              trackColor: trackColor,
              size: 150,
              strokeWidth: 9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 3,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: scoreValue,
                          style: context.textStyles.displayLarge?.copyWith(
                            color: scoreColor,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            height: 40 / 48,
                            letterSpacing: -0.9,
                          ),
                        ),
                        TextSpan(
                          text: scoreTotal,
                          style: context.textStyles.displayLarge?.copyWith(
                            color: totalColor ?? colors.textPrimary,
                            fontSize: FontSize.displayLarge,
                            fontWeight: FontWeight.w800,
                            height: 40 / 36,
                            letterSpacing: -0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    context.getText(AppKeys.scoreUpper),
                    style: context.textStyles.labelSmall?.copyWith(
                      color: labelColor ?? colors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 15 / 10,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
