import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  static const _designWidth = 273.0;
  static const _designHeight = 613.0;
  static const _teal = Color(0xFF11847C);
  static const _brandInk = Color(0xFF24594E);
  static const _headlineInk = Color(0xFF2D3748);
  static const _scanColor = Color(0xFF9DC4C1);
  static const _shapeColor = Color(0xFF8A735E);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthScale = constraints.maxWidth / _designWidth;
        final heightScale = constraints.maxHeight / _designHeight;
        final sizeScale = math.min(widthScale, heightScale);

        double x(double value) => value * widthScale;
        double y(double value) => value * heightScale;
        double s(double value) => value * sizeScale;

        return SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(child: _WelcomeBackground()),
              Positioned(
                left: x(194),
                top: y(148),
                child: _TriangleDecoration(size: s(42)),
              ),
              Positioned(
                left: x(55),
                top: y(300),
                child: Transform.rotate(
                  angle: -0.18,
                  child: _StarDecoration(size: s(62)),
                ),
              ),
              Positioned(
                left: x(-66),
                bottom: y(-26),
                child: _BottomRing(size: s(160), strokeWidth: s(20)),
              ),
              Positioned(
                right: x(-26),
                bottom: y(-42),
                child: _BottomCircle(size: s(142)),
              ),
              Positioned(
                left: x(34),
                top: y(60),
                child: _ScanCubeMark(size: s(40)),
              ),
              Positioned(
                left: (constraints.maxWidth - s(148)) / 2,
                top: y(142),
                child: _Mascot(size: s(148)),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: y(279),
                child: Text(
                  'numinumi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _brandInk,
                    fontFamily: 'Nunito',
                    fontSize: s(30),
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: y(348),
                child: _WelcomeHeadline(fontSize: s(24)),
              ),
              Positioned(
                left: x(46),
                top: y(407),
                child: _PlusBadge(size: s(42)),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: y(415),
                child: _Subtitle(fontSize: s(12.5)),
              ),
              Positioned(
                left: x(38),
                right: x(38),
                top: y(502),
                child: _StartButton(onPressed: onStart, height: s(48)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WelcomeBackground extends StatelessWidget {
  const _WelcomeBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD5F1F6),
            Color(0xFFD8F7F0),
            Color(0xFFC3EFEB),
          ],
          stops: [0, 0.5, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
    );
  }
}

class _ScanCubeMark extends StatelessWidget {
  const _ScanCubeMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _ScanCornersPainter()),
          ),
          SizedBox(
            width: size / 2,
            height: size / 2,
            child: const CustomPaint(painter: _CubePainter()),
          ),
        ],
      ),
    );
  }
}

class _Mascot extends StatelessWidget {
  const _Mascot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const Image(
        image: AssetImage('assets/images/welcome_numi_character.png'),
        fit: BoxFit.cover,
      ),
    );
  }
}

class _WelcomeHeadline extends StatelessWidget {
  const _WelcomeHeadline({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: WelcomeScreen._headlineInk,
          fontFamily: 'Nunito',
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: 0,
        ),
        children: [
          TextSpan(text: context.getText(AppKeys.welcomeTitlePrefix)),
          TextSpan(
            text: context.getText(AppKeys.welcomeTitleN),
            style: const TextStyle(color: WelcomeScreen._teal),
          ),
        ],
      ),
    );
  }
}

class _PlusBadge extends StatelessWidget {
  const _PlusBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _PlusPainter()),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: WelcomeScreen._headlineInk.withValues(alpha: 0.72),
      fontFamily: 'Nunito',
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.16,
      letterSpacing: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            context.getText(AppKeys.welcomeSubtitlePrefix),
            maxLines: 1,
            style: style,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            context.getText(AppKeys.welcomeSubtitle),
            maxLines: 1,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed, required this.height});

  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WelcomeScreen._teal,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D11847C),
              blurRadius: 10,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          child: Text(
            context.getText(AppKeys.start),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontSize: height * 0.32,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _TriangleDecoration extends StatelessWidget {
  const _TriangleDecoration({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TrianglePainter(
          color: WelcomeScreen._shapeColor.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _StarDecoration extends StatelessWidget {
  const _StarDecoration({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(
          color: WelcomeScreen._shapeColor.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}

class _BottomRing extends StatelessWidget {
  const _BottomRing({required this.size, required this.strokeWidth});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: WelcomeScreen._shapeColor.withValues(alpha: 0.08),
          width: strokeWidth,
        ),
      ),
    );
  }
}

class _BottomCircle extends StatelessWidget {
  const _BottomCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: WelcomeScreen._shapeColor.withValues(alpha: 0.08),
      ),
    );
  }
}

class _ScanCornersPainter extends CustomPainter {
  const _ScanCornersPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WelcomeScreen._scanColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    void drawCorner(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }

    drawCorner(const [Offset(12, 0), Offset(0, 0), Offset(0, 12)]);
    drawCorner(const [Offset(44, 0), Offset(56, 0), Offset(56, 12)]);
    drawCorner(const [Offset(0, 44), Offset(0, 56), Offset(12, 56)]);
    drawCorner(const [Offset(56, 44), Offset(56, 56), Offset(44, 56)]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CubePainter extends CustomPainter {
  const _CubePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WelcomeScreen._scanColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.92
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.scale(size.width / 28, size.height / 28);

    final outline = Path()
      ..moveTo(24.5, 18.77)
      ..lineTo(24.5, 9.23)
      ..lineTo(14, 2.0)
      ..lineTo(3.5, 9.23)
      ..lineTo(3.5, 18.77)
      ..lineTo(14, 26)
      ..close();
    canvas.drawPath(outline, paint);

    final topFold = Path()
      ..moveTo(3.82, 8.12)
      ..lineTo(14, 14.01)
      ..lineTo(24.18, 8.12);
    canvas.drawPath(topFold, paint);
    canvas.drawLine(const Offset(14, 25.76), const Offset(14, 14), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlusPainter extends CustomPainter {
  const _PlusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = WelcomeScreen._scanColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final plusPaint = Paint()
      ..color = WelcomeScreen._scanColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width - 4) / 2,
      borderPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 16),
      Offset(size.width / 2, size.height - 16),
      plusPaint,
    );
    canvas.drawLine(
      Offset(16, size.height / 2),
      Offset(size.width - 16, size.height / 2),
      plusPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeJoin = StrokeJoin.miter;
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.12)
      ..lineTo(size.width * 0.92, size.height * 0.86)
      ..lineTo(size.width * 0.08, size.height * 0.86)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2;
    final inner = outer * 0.42;
    final path = Path();

    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
