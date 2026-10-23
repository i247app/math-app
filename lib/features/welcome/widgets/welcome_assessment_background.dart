import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

/// Transparent cutouts and native waves styled independently for each theme.
class WelcomeAssessmentBackground extends StatelessWidget {
  const WelcomeAssessmentBackground({super.key});

  static const canvasSize = Size(552, 1280);
  static const planetSurfaceY = 948.0;

  static Iterable<String> get decorationAssets =>
      _decorations.map((decoration) => decoration.asset);

  static const _decorations = <_Decoration>[
    _Decoration('saturn', Rect.fromLTWH(0, 0, 166, 148), darkOpacity: 0.78),
    _Decoration(
      'purple-planet',
      Rect.fromLTWH(437, 96, 115, 108),
      darkOpacity: 0.78,
    ),
    _Decoration(
      'cyan-planet',
      Rect.fromLTWH(449, 434, 103, 204),
      darkOpacity: 0.74,
    ),
    _Decoration('left-star', Rect.fromLTWH(18, 238, 65, 66)),
    _Decoration('right-star', Rect.fromLTWH(432, 359, 65, 62)),
    _Decoration('top-dot', Rect.fromLTWH(438, 51, 25, 25), darkOpacity: 0.65),
    _Decoration(
      'upper-left-dot',
      Rect.fromLTWH(72, 171, 22, 22),
      darkOpacity: 0.65,
    ),
    _Decoration(
      'right-dot',
      Rect.fromLTWH(487, 286, 20, 20),
      darkOpacity: 0.65,
    ),
    _Decoration(
      'middle-left-dot',
      Rect.fromLTWH(65, 402, 23, 24),
      darkOpacity: 0.65,
    ),
    _Decoration(
      'lower-left-dot',
      Rect.fromLTWH(27, 623, 24, 24),
      darkOpacity: 0.65,
    ),
    _Decoration('ground', Rect.fromLTWH(0, 932, 552, 348)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.themeColors;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox.fromSize(
            size: canvasSize,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    key: const ValueKey('welcome-intro-sky'),
                    color: isDark ? colors.pageBackground : Colors.white,
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    key: const ValueKey('welcome-intro-waves'),
                    painter: _WavesPainter(
                      color: isDark
                          ? colors.brandStrong
                          : const Color(0xFFBCECF6),
                      isDark: isDark,
                    ),
                  ),
                ),
                for (final decoration in _decorations)
                  Positioned.fromRect(
                    rect: decoration.bounds,
                    child: Opacity(
                      key: ValueKey('welcome-intro-${decoration.name}'),
                      opacity: isDark ? decoration.darkOpacity : 1,
                      child: _DecorationSprite(
                        decoration: decoration,
                        isDark: isDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Decoration {
  const _Decoration(this.name, this.bounds, {this.darkOpacity = 0.92});

  final String name;
  final Rect bounds;
  final double darkOpacity;

  String get asset => 'assets/images/assessment_intro/assessment-$name.png';
}

class _DecorationSprite extends StatelessWidget {
  const _DecorationSprite({required this.decoration, required this.isDark});

  final _Decoration decoration;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isGround = decoration.name == 'ground';
    Widget sprite = Image.asset(
      decoration.asset,
      width: decoration.bounds.width,
      height: decoration.bounds.height,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    );
    if (isGround) {
      sprite = ClipPath(clipper: const _GroundClipper(), child: sprite);
      if (isDark) {
        sprite = ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0xFF6B9099),
            BlendMode.modulate,
          ),
          child: sprite,
        );
      }
    } else if (decoration.name == 'cyan-planet') {
      sprite = ClipPath(clipper: const _RightPlanetClipper(), child: sprite);
    }
    return sprite;
  }
}

/// Trim extraction fringes along the curved horizon without tinting the sky.
class _GroundClipper extends CustomClipper<Path> {
  const _GroundClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 84)
    ..cubicTo(size.width * 0.26, -12, size.width * 0.74, -12, size.width, 84)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_GroundClipper oldClipper) => false;
}

class _RightPlanetClipper extends CustomClipper<Path> {
  const _RightPlanetClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 8)
    ..cubicTo(size.width * 0.35, 17, 8, 55, 8, 102)
    ..cubicTo(8, 155, size.width * 0.36, 192, size.width, 198)
    ..close();

  @override
  bool shouldReclip(_RightPlanetClipper oldClipper) => false;
}

class _WavesPainter extends CustomPainter {
  const _WavesPainter({required this.color, required this.isDark});

  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < 2; index++) {
      final top = 784.0 + index * 76;
      final path = Path()
        ..moveTo(0, top)
        ..cubicTo(130, top + 4, 233, top + 107, 276, 1080)
        ..cubicTo(328, top + 125, 410, top + 55, size.width, top + 40)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(
            alpha: isDark ? 0.04 + index * 0.04 : 0.22 + index * 0.14,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_WavesPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isDark != isDark;
}
