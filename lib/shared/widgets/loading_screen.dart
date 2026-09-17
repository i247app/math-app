import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final shortSide = math.min(width, height);
        final mascotSize = math.min(width * 1.12, height * 0.50);
        final logoFontSize = math.min(width * 0.111, height * 0.05);
        final topSpacing = height * 0.119;
        final logoSpacing = height * 0.01;
        final loadingSpacing = height * 0.085;
        final indicatorSize = shortSide * 0.14;

        return Material(
          color: colors.surface,
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
                SizedBox(height: topSpacing),
                SizedBox(
                  width: mascotSize,
                  height: mascotSize,
                  child: Image.asset(
                    'assets/images/numi-mascot-hero.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: logoSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.11),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'NUMINUMI',
                      maxLines: 1,
                      style: context.textStyles.displaySmall?.copyWith(
                        color: colors.brandStrong,
                        fontSize: logoFontSize,
                        fontWeight: FontWeight.w700,
                        height: 0.62,
                        letterSpacing: 0,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: loadingSpacing),
                _SessionLoadingStatus(
                  message: message ?? context.getText(AppKeys.loading),
                  indicatorSize: indicatorSize,
                  fontSize: shortSide * 0.04,
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SessionLoadingStatus extends StatelessWidget {
  const _SessionLoadingStatus({
    required this.message,
    required this.indicatorSize,
    required this.fontSize,
  });

  final String message;
  final double indicatorSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Column(
      children: [
        _OrbitLoadingIndicator(
          size: indicatorSize,
          trackColor: colors.skeleton,
          activeColor: colors.brandStrong,
          dotColor: colors.accentStrong,
        ),
        SizedBox(height: indicatorSize * 0.34),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium?.copyWith(
              color: colors.textSecondary,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: 0,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrbitLoadingIndicator extends StatefulWidget {
  const _OrbitLoadingIndicator({
    required this.size,
    required this.trackColor,
    required this.activeColor,
    required this.dotColor,
  });

  final double size;
  final Color trackColor;
  final Color activeColor;
  final Color dotColor;

  @override
  State<_OrbitLoadingIndicator> createState() => _OrbitLoadingIndicatorState();
}

class _OrbitLoadingIndicatorState extends State<_OrbitLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _OrbitLoadingPainter(
            progress: _controller.value,
            trackColor: widget.trackColor,
            activeColor: widget.activeColor,
            dotColor: widget.dotColor,
          ),
        ),
      ),
    );
  }
}

class _OrbitLoadingPainter extends CustomPainter {
  const _OrbitLoadingPainter({
    required this.progress,
    required this.trackColor,
    required this.activeColor,
    required this.dotColor,
  });

  final double progress;
  final Color trackColor;
  final Color activeColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.38;
    final strokeWidth = size.shortestSide * 0.095;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = activeColor;
    final dotPaint = Paint()..color = dotColor;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      (progress * math.pi * 2) - math.pi / 2,
      math.pi * 1.18,
      false,
      activePaint,
    );

    for (var index = 0; index < 3; index++) {
      final angle = progress * math.pi * 2 + index * math.pi * 2 / 3;
      final pulse = 0.72 + 0.28 * math.sin(progress * math.pi * 2 + index);
      final offset = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(offset, strokeWidth * 0.42 * pulse, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.dotColor != dotColor;
  }
}
