import 'package:flutter/material.dart';

class LoginSceneBackground extends StatelessWidget {
  const LoginSceneBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEFFBFC),
      child: Stack(
        children: [
          const Positioned(
            left: -30,
            top: 128,
            child: _Cloud(width: 148, opacity: 0.76),
          ),
          const Positioned(
            right: -20,
            top: 246,
            child: _Cloud(width: 128, opacity: 0.62),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginHillPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({
    required this.width,
    required this.opacity,
  });

  final double width;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(width, width * 0.44),
        painter: _CloudPainter(),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    final fillPaint = Paint()..color = const Color(0xFFEAF8FB);
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.7)
      ..cubicTo(
        size.width * 0.04,
        size.height * 0.35,
        size.width * 0.27,
        size.height * 0.3,
        size.width * 0.35,
        size.height * 0.45,
      )
      ..cubicTo(
        size.width * 0.46,
        size.height * 0.04,
        size.width * 0.76,
        size.height * 0.16,
        size.width * 0.74,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width,
        size.height * 0.48,
        size.width,
        size.height * 0.86,
        size.width * 0.78,
        size.height * 0.86,
      )
      ..lineTo(size.width * 0.16, size.height * 0.86)
      ..cubicTo(0, size.height * 0.86, 0, size.height * 0.72, size.width * 0.05,
          size.height * 0.7)
      ..close();

    canvas.drawPath(path.shift(const Offset(0, 14)), shadowPaint);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginHillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF43B352);
    final path = Path()
      ..moveTo(0, size.height * 0.94)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.98,
        size.width * 0.52,
        size.height * 0.87,
        size.width * 0.76,
        size.height * 0.89,
      )
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.9,
        size.width,
        size.height * 0.93,
        size.width,
        size.height * 0.94,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
