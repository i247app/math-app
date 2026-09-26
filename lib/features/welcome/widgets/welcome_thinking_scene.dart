import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class WelcomeThinkingScene extends StatelessWidget {
  const WelcomeThinkingScene({super.key, required this.onTry});

  final VoidCallback onTry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cloudColor = isDark
        ? context.themeColors.accent
        : const Color(0xFFF28B30);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 360,
        height: 300,
        child: Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: CustomPaint(
                  painter: _ThoughtBubblePainter(
                    outline: cloudColor,
                    fill: context.themeColors.pageBackground,
                    shadow: context.themeColors.shadow,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 150,
              top: 42,
              width: 164,
              height: 90,
              child: TextButton(
                key: const ValueKey('welcome-assessment-action'),
                onPressed: onTry,
                style: TextButton.styleFrom(
                  foregroundColor: cloudColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: Text(
                  context.getText(AppKeys.welcomeTryIt),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // Keep both lines within the fixed cloud illustration.
                  textScaler: MediaQuery.textScalerOf(
                    context,
                  ).clamp(maxScaleFactor: 1.1),
                  style: const TextStyle(
                    fontFamily: 'NunitoVariable',
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 25,
              top: 133,
              width: 155,
              height: 163,
              child: Image.asset(
                'assets/images/welcome-thinking-owl.png',
                key: const ValueKey('welcome-thinking-mascot'),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThoughtBubblePainter extends CustomPainter {
  const _ThoughtBubblePainter({
    required this.outline,
    required this.fill,
    required this.shadow,
  });

  final Color outline;
  final Color fill;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final cloud = Path()
      ..moveTo(174, 51)
      ..cubicTo(180, 20, 214, 7, 236, 32)
      ..cubicTo(256, 17, 282, 28, 288, 51)
      ..cubicTo(327, 52, 335, 114, 286, 122)
      ..cubicTo(282, 149, 259, 163, 231, 146)
      ..cubicTo(207, 162, 178, 150, 172, 122)
      ..cubicTo(129, 122, 134, 57, 174, 51)
      ..close();

    canvas.drawPath(
      cloud.shift(const Offset(0, 12)),
      Paint()
        ..color = shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(cloud, Paint()..color = fill);
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(cloud, stroke);
    canvas.drawOval(const Rect.fromLTWH(173, 163, 26, 24), stroke);
    canvas.drawOval(const Rect.fromLTWH(158, 194, 19, 18), stroke);
  }

  @override
  bool shouldRepaint(_ThoughtBubblePainter oldDelegate) =>
      outline != oldDelegate.outline ||
      fill != oldDelegate.fill ||
      shadow != oldDelegate.shadow;
}
