part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassroomNumberBadge extends StatelessWidget {
  const _TeacherClassroomNumberBadge({
    required this.scale,
    required this.number,
    required this.palette,
  });

  final double scale;
  final String number;
  final _TeacherClassroomNumberPalette palette;

  TextStyle get _numberStyle => TextStyle(
        fontSize: 50 * scale,
        fontWeight: FontWeight.w900,
        height: 1,
      );

  @override
  Widget build(BuildContext context) {
    final radius = 16 * scale;
    return Container(
      width: 76 * scale,
      height: 76 * scale,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.45, -0.5),
                  radius: 1.05,
                  colors: [
                    Colors.white.withValues(alpha: 0.85),
                    palette.background,
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(3.5 * scale, 5.5 * scale),
            child: Text(
              number,
              style: _numberStyle.copyWith(color: palette.shadow),
            ),
          ),
          Transform.translate(
            offset: Offset(0, 3 * scale),
            child: Text(
              number,
              style: _numberStyle.copyWith(
                color: palette.depth,
                shadows: [
                  Shadow(
                    color: palette.shadow,
                    offset: Offset(2 * scale, 2.6 * scale),
                    blurRadius: 2 * scale,
                  ),
                ],
              ),
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.top, palette.bottom],
              stops: const [0.12, 0.88],
            ).createShader(bounds),
            child: Text(
              number,
              style: _numberStyle.copyWith(color: Colors.white),
            ),
          ),
          Positioned(
            top: 17 * scale,
            left: 26 * scale,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 13 * scale,
                height: 5 * scale,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
