import 'package:flutter/material.dart';

class NumiBrandMascot extends StatelessWidget {
  const NumiBrandMascot({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/model2.png',
          width: size,
          height: size * 0.86,
          fit: BoxFit.contain,
        ),
        Transform.translate(
          offset: Offset(0, -size * 0.04),
          child: _NumiLogo(width: size * 0.68),
        ),
      ],
    );
  }
}

class _NumiLogo extends StatelessWidget {
  const _NumiLogo({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final fontSize = width * 0.34;

    return SizedBox(
      width: width,
      height: width * 0.68,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            child: _OutlinedLogoText(
              text: 'Numi',
              fontSize: fontSize,
              fill: const Color(0xFFD82683),
            ),
          ),
          Positioned(
            top: width * 0.25,
            child: _OutlinedLogoText(
              text: 'Numi',
              fontSize: fontSize,
              fill: const Color(0xFFFFD428),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedLogoText extends StatelessWidget {
  const _OutlinedLogoText({
    required this.text,
    required this.fontSize,
    required this.fill,
  });

  final String text;
  final double fontSize;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    final strokeStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 0.88,
      letterSpacing: 0,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = fontSize * 0.14
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF074B91),
    );
    final fillStyle = TextStyle(
      color: fill,
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 0.88,
      letterSpacing: 0,
    );

    return Stack(
      children: [
        Text(text, style: strokeStyle),
        Text(text, style: fillStyle),
      ],
    );
  }
}
