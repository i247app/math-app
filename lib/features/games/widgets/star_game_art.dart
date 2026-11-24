import 'dart:math';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:numi/features/games/models/star_game.dart';

const starGameInk = Color(0xFF101839);
const starGamePanel = Color(0xFF202B56);
const starGameLine = Color(0xFF394879);
const starGameMuted = Color(0xFFC1CAE5);
const starGameGold = Color(0xFFFFD879);
const starGameNumberFont = 'StarGameNumbers';
const starGameAnswerFontSize = 38.0;

Color starGameAccent(StarGameLevel level) => switch (level) {
  StarGameLevel.kite => starGameGold,
  StarGameLevel.whale => const Color(0xFF82E0F1),
  StarGameLevel.turtle => const Color(0xFF96E6B9),
  StarGameLevel.fox => const Color(0xFFDCBCFF),
  StarGameLevel.firebird => const Color(0xFFFFAC93),
  StarGameLevel.dragon => const Color(0xFFFBAADC),
};

class StarGameSky extends StatelessWidget {
  const StarGameSky({
    super.key,
    required this.child,
    this.backdrop = const StarGameBackdrop(),
  });

  final Widget child;
  final Widget backdrop;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Stack(fit: StackFit.expand, children: [backdrop, child]),
  );
}

class StarGamePlayBackdrop extends StatelessWidget {
  const StarGamePlayBackdrop({super.key});

  static const assetPath = 'assets/images/star-game-golden-moon-hill.png';

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final artwork = Image.asset(
        assetPath,
        fit: BoxFit.fill,
        excludeFromSemantics: true,
        errorBuilder: (context, error, stackTrace) => const StarGameBackdrop(),
      );
      final width = min(constraints.maxWidth, constraints.maxHeight * .54);
      if (width == constraints.maxWidth) return artwork;

      // Keep the moon and foreground in view on wider screens.
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E3DAC),
              Color(0xFF2471E2),
              Color(0xFF42B5F9),
              Color(0xFF0E4897),
            ],
            stops: [0, .50, .90, 1],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0, .09, .91, 1],
              ).createShader(bounds),
              child: artwork,
            ),
          ),
        ),
      );
    },
  );
}

class StarGameBackdrop extends StatelessWidget {
  const StarGameBackdrop({super.key, this.banner = false});

  final bool banner;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _SkyPainter(banner: banner)),
  );
}

class _SkyPainter extends CustomPainter {
  const _SkyPainter({required this.banner});

  final bool banner;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10132F), Color(0xFF162452), Color(0xFF213B78)],
          stops: [0, .6, 1],
        ).createShader(rect),
    );

    final moon = banner
        ? Offset(size.width * .78, size.height * .43)
        : Offset(size.width * .84, size.height * .20);
    final radius = banner
        ? min(size.shortestSide * .22, 32.0)
        : min(size.shortestSide * .10, 52.0);
    final moonColor = banner
        ? const Color(0xFFFFD98F)
        : const Color(0xFFD2BCFF);
    canvas.drawCircle(
      moon,
      radius * 2.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (banner ? moonColor : const Color(0xFFBC9DFF)).withValues(
              alpha: .26,
            ),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: moon, radius: radius * 2.5)),
    );
    canvas.saveLayer(
      Rect.fromCircle(center: moon, radius: radius + 1),
      Paint(),
    );
    canvas.drawCircle(moon, radius, Paint()..color = moonColor);
    canvas.drawCircle(
      moon + Offset(radius * .46, -radius * .26),
      radius * .94,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();

    final random = Random(724);
    final starCount = banner ? 49 : 83;
    for (var i = 0; i < starCount; i++) {
      final star = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * .94,
      );
      final opacity = .18 + random.nextDouble() * .42;
      final color = i % 8 == 0 ? starGameGold : const Color(0xFFD5DDFF);
      if (i % 8 == 0) {
        canvas.drawPath(
          _spark(star, 3 + random.nextDouble() * 3),
          Paint()..color = color.withValues(alpha: opacity),
        );
      } else {
        canvas.drawCircle(
          star,
          .5 + random.nextDouble(),
          Paint()..color = color.withValues(alpha: opacity),
        );
      }
    }

    canvas.save();
    canvas.scale(size.width, size.height);
    canvas.drawPath(
      Path()
        ..moveTo(0, .91)
        ..cubicTo(.23, .84, .39, .88, .62, .92)
        ..cubicTo(.76, .94, .91, .91, 1, .86)
        ..lineTo(1, 1)
        ..lineTo(0, 1)
        ..close(),
      Paint()..color = const Color(0xFF1B3064),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, .96)
        ..cubicTo(.22, .93, .43, .98, .63, .96)
        ..quadraticBezierTo(.86, .93, 1, .95)
        ..lineTo(1, 1)
        ..lineTo(0, 1)
        ..close(),
      Paint()..color = const Color(0xFF141E46),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkyPainter oldDelegate) => banner != oldDelegate.banner;
}

class StarGameConstellation extends StatelessWidget {
  const StarGameConstellation({
    super.key,
    required this.level,
    required this.lit,
    this.preview = false,
    this.animateNewest = true,
    this.newestLinkProgress = 1,
    this.sweepProgress,
    this.celebrationGlow = 0,
  });

  final StarGameLevel level;
  final int lit;
  final bool preview;
  final bool animateNewest;
  final double newestLinkProgress;
  final double? sweepProgress;
  final double celebrationGlow;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: TweenAnimationBuilder<double>(
      key: ValueKey((level, lit, preview)),
      duration:
          preview || !animateNewest || MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 390),
      tween: Tween(begin: lit > 0 ? 0 : 1, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, animation, _) => CustomPaint(
        painter: _ConstellationPainter(
          level,
          lit,
          preview,
          animation,
          newestLinkProgress,
          sweepProgress,
          celebrationGlow,
        ),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter(
    this.level,
    this.lit,
    this.preview,
    this.animation,
    this.newestLinkProgress,
    this.sweepProgress,
    this.celebrationGlow,
  );

  final StarGameLevel level;
  final int lit;
  final bool preview;
  final double animation;
  final double newestLinkProgress;
  final double? sweepProgress;
  final double celebrationGlow;

  double _glow(int index) {
    final sweep = sweepProgress;
    if (sweep == null) return celebrationGlow;
    final wave = sweep * (lit + 2) - 1;
    return max(
      celebrationGlow,
      (1 - (index - wave).abs() / 1.5).clamp(0.0, 1.0),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final (_, paths) = _constellations[level.index];
    final points = starGameConstellationPoints(level, size);
    final accent = starGameAccent(level);
    final height = min(size.height, size.width / 1.45);

    for (final path in paths) {
      for (var i = 1; i < path.length; i++) {
        final first = path[i - 1];
        final second = path[i];
        final newest = max(first, second);
        final on = first < lit && second < lit;
        if (!on || (newest == lit - 1 && newestLinkProgress < 1)) {
          canvas.drawLine(
            points[first],
            points[second],
            Paint()
              ..strokeWidth = 1.15
              ..strokeCap = StrokeCap.round
              ..color = accent.withValues(alpha: preview ? .42 : .29),
          );
        }
        if (!on) continue;
        final other = newest == first ? second : first;
        final end = newest == lit - 1
            ? Offset.lerp(points[newest], points[other], newestLinkProgress)!
            : points[other];
        final glow = _glow(newest);
        if (glow > 0) {
          canvas.drawLine(
            points[newest],
            end,
            Paint()
              ..strokeWidth = 6 + 3 * glow
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
              ..color = starGameGold.withValues(alpha: glow * .66),
          );
        }
        canvas.drawLine(
          points[newest],
          end,
          Paint()
            ..strokeWidth = 1.7 + glow
            ..strokeCap = StrokeCap.round
            ..color = Color.lerp(
              accent,
              Colors.white,
              glow * .75,
            )!.withValues(alpha: .78 + glow * .22),
        );
      }
    }

    final radius = (height * .034).clamp(2.2, 6.0);
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      if (i >= lit) {
        canvas.drawCircle(
          point,
          radius * .54,
          Paint()..color = accent.withValues(alpha: preview ? .75 : .47),
        );
        continue;
      }
      final progress = i == lit - 1 ? animation : 1.0;
      final glow = _glow(i);
      final spark = Offset.lerp(
        Offset(size.width * .5, size.height - radius),
        point,
        progress,
      )!;
      final halo = radius * (2.4 + 3 * (1 - progress) + 2 * glow);
      canvas.drawCircle(
        spark,
        halo,
        Paint()
          ..shader = RadialGradient(
            colors: [
              accent.withValues(alpha: (.62 + .28 * glow) * progress),
              accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: spark, radius: halo)),
      );
      canvas.drawPath(
        _spark(spark, radius * (.74 + .51 * progress + .38 * glow)),
        Paint()..color = Color.lerp(accent, Colors.white, .55)!,
      );
    }
  }

  @override
  bool shouldRepaint(_ConstellationPainter oldDelegate) =>
      level != oldDelegate.level ||
      lit != oldDelegate.lit ||
      preview != oldDelegate.preview ||
      animation != oldDelegate.animation ||
      newestLinkProgress != oldDelegate.newestLinkProgress ||
      sweepProgress != oldDelegate.sweepProgress ||
      celebrationGlow != oldDelegate.celebrationGlow;
}

List<Offset> starGameConstellationPoints(StarGameLevel level, Size size) {
  final (points, _) = _constellations[level.index];
  final width = min(size.width, size.height * 1.45);
  final height = min(size.height, size.width / 1.45);
  final origin = Offset((size.width - width) / 2, (size.height - height) / 2);
  return [for (final (x, y) in points) origin + Offset(x * width, y * height)];
}

List<Offset> starGameStarVertices(Offset center, double radius) => [
  for (var i = 0; i < 10; i++)
    center +
        Offset.fromDirection(
          i * pi / 5 - pi / 2,
          i.isEven ? radius : radius * .53,
        ),
];

Path starGameRoundedStar(List<Offset> vertices) {
  final first = Offset.lerp(vertices.last, vertices.first, .86)!;
  final path = Path()..moveTo(first.dx, first.dy);
  for (var i = 0; i < vertices.length; i++) {
    final tip = vertices[i];
    final next = vertices[(i + 1) % vertices.length];
    final exit = Offset.lerp(tip, next, .14)!;
    final approach = Offset.lerp(tip, next, .86)!;
    path
      ..quadraticBezierTo(tip.dx, tip.dy, exit.dx, exit.dy)
      ..lineTo(approach.dx, approach.dy);
  }
  return path..close();
}

void paintStarGameGlint(
  Canvas canvas,
  Offset center,
  double radius,
  Color color,
) {
  final path = Path()..moveTo(center.dx, center.dy - radius);
  for (var i = 1; i < 8; i++) {
    final point =
        center +
        Offset.fromDirection(
          i * pi / 4 - pi / 2,
          radius * (i.isEven ? 1 : .26),
        );
    path.lineTo(point.dx, point.dy);
  }
  canvas.drawPath(path..close(), Paint()..color = color);
}

Path _spark(Offset point, double radius) => Path()
  ..moveTo(point.dx, point.dy - radius)
  ..quadraticBezierTo(
    point.dx + radius * .23,
    point.dy - radius * .19,
    point.dx + radius,
    point.dy,
  )
  ..quadraticBezierTo(
    point.dx + radius * .23,
    point.dy + radius * .19,
    point.dx,
    point.dy + radius,
  )
  ..quadraticBezierTo(
    point.dx - radius * .23,
    point.dy + radius * .19,
    point.dx - radius,
    point.dy,
  )
  ..quadraticBezierTo(
    point.dx - radius * .23,
    point.dy - radius * .19,
    point.dx,
    point.dy - radius,
  )
  ..close();

typedef _Constellation = (List<(double, double)>, List<List<int>>);

const _constellations = <_Constellation>[
  (
    [
      (.48, .08),
      (.70, .27),
      (.52, .54),
      (.28, .34),
      (.47, .33),
      (.46, .66),
      (.52, .76),
      (.42, .84),
      (.34, .81),
      (.32, .93),
    ],
    [
      [0, 1, 2, 3, 0, 4, 2, 5, 6, 7, 8, 9],
      [3, 4, 1],
    ],
  ),
  (
    [
      (.13, .47),
      (.21, .31),
      (.37, .28),
      (.57, .42),
      (.72, .47),
      (.88, .25),
      (.84, .60),
      (.70, .57),
      (.49, .69),
      (.23, .68),
    ],
    [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
      [4, 7],
    ],
  ),
  (
    [
      (.26, .42),
      (.38, .24),
      (.57, .24),
      (.71, .40),
      (.86, .40),
      (.90, .54),
      (.74, .59),
      (.61, .76),
      (.38, .75),
      (.20, .59),
    ],
    [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
      [3, 6, 9],
      [1, 8],
      [2, 7],
    ],
  ),
  (
    [
      (.16, .18),
      (.36, .39),
      (.50, .31),
      (.64, .39),
      (.84, .18),
      (.76, .57),
      (.63, .71),
      (.50, .87),
      (.36, .71),
      (.24, .57),
    ],
    [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
      [9, 1, 7, 3, 5],
    ],
  ),
  (
    [
      (.08, .21),
      (.24, .47),
      (.42, .54),
      (.51, .33),
      (.60, .50),
      (.75, .41),
      (.91, .16),
      (.73, .64),
      (.55, .73),
      (.48, .91),
    ],
    [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [2, 8, 4],
    ],
  ),
  (
    [
      (.13, .58),
      (.27, .71),
      (.42, .54),
      (.40, .32),
      (.56, .21),
      (.70, .33),
      (.66, .55),
      (.78, .60),
      (.89, .44),
      (.90, .25),
    ],
    [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [2, 6],
      [5, 9],
    ],
  ),
];
