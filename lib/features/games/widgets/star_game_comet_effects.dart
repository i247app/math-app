import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:numi/features/games/widgets/star_game_art.dart';

class StarGameCometEffects extends StatelessWidget {
  const StarGameCometEffects({
    super.key,
    required this.elapsed,
    required this.number,
    required this.answer,
    required this.slot,
    required this.star,
    required this.streak,
    required this.perfect,
  });

  static const launchAt = 70.0;
  static const fillAt = 285.0;
  static const lightAt = 485.0;

  final double elapsed;
  final int number;
  final Offset answer;
  final Offset slot;
  final Offset star;
  final bool streak;
  final bool perfect;

  static double progress(double elapsed, double start, double end) =>
      ((elapsed - start) / (end - start)).clamp(0.0, 1.0);

  static double pressScale(double elapsed) =>
      1 -
      .14 * math.sin(math.pi * progress(elapsed, 0, 86)) +
      .10 * math.sin(math.pi * progress(elapsed, 86, 180));

  @override
  Widget build(BuildContext context) {
    final flight = progress(elapsed, launchAt, fillAt);
    final center = _flightPoint(answer, slot, flight, const Offset(0, -29));
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _CometPainter(
                  elapsed,
                  answer,
                  slot,
                  star,
                  streak,
                  perfect,
                ),
              ),
              if (elapsed >= launchAt && elapsed < fillAt)
                Positioned(
                  key: const ValueKey('star-game-flying-number'),
                  left: center.dx - 32,
                  top: center.dy - 24,
                  width: 64,
                  height: 48,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Color(0xFFFFF2BA),
                        fontFamily: starGameNumberFont,
                        fontSize: starGameAnswerFontSize,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: Color(0xCC283359), blurRadius: 7),
                          Shadow(color: starGameGold, blurRadius: 17),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CometPainter extends CustomPainter {
  const _CometPainter(
    this.elapsed,
    this.answer,
    this.slot,
    this.star,
    this.streak,
    this.perfect,
  );

  final double elapsed;
  final Offset answer;
  final Offset slot;
  final Offset star;
  final bool streak;
  final bool perfect;

  double _progress(double start, double end) =>
      StarGameCometEffects.progress(elapsed, start, end);

  @override
  void paint(Canvas canvas, Size size) {
    const launch = StarGameCometEffects.launchAt;
    const fill = StarGameCometEffects.fillAt;
    const light = StarGameCometEffects.lightAt;
    if (perfect && elapsed >= light) _paintCloudLight(canvas, size);
    if (streak && elapsed >= light) _paintEdgeGlints(canvas, size);

    if (elapsed < 220) {
      _burst(canvas, answer, _progress(0, 220), 46, 5, origin: 13);
    }
    if (elapsed >= launch && elapsed < fill) {
      _trail(
        canvas,
        answer,
        slot,
        _progress(launch, fill),
        const Offset(0, -29),
        5.2,
      );
    }
    if (elapsed >= fill && elapsed < fill + 185) {
      _burst(canvas, slot, _progress(fill, fill + 185), 40, 4, origin: 14);
    }
    if (elapsed >= fill + 10 && elapsed < light) {
      const bend = Offset(26, 0);
      final progress = _progress(fill + 10, light);
      _trail(canvas, slot, star, progress, bend, 4);
      final head = _flightPoint(slot, star, progress, bend);
      _glow(canvas, head, 13, .9);
      _spark(canvas, head, 6, const Color(0xFFFFF9DD));
    }
    if (elapsed >= light && elapsed < light + 175) {
      _burst(canvas, star, _progress(light, light + 175), 32, 5, origin: 4);
    }
  }

  void _paintCloudLight(Canvas canvas, Size size) {
    final flash = math.sin(math.pi * _progress(485, 980));
    for (final x in [0.0, size.width]) {
      final center = Offset(x, size.height * .97);
      final radius = size.shortestSide * .48;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFE09C).withValues(alpha: .42 * flash),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  void _paintEdgeGlints(Canvas canvas, Size size) {
    for (var i = 0; i < 12; i++) {
      final amount = _progress(485 + (i % 4) * 24, 840 + (i % 4) * 15);
      final alpha = math.sin(math.pi * amount);
      final x = (.045 + (i % 3) * .045) * size.width;
      final point = Offset(
        i.isEven ? x : size.width - x,
        (.12 + (i ~/ 2) * .062) * size.height - amount * 17,
      );
      _glow(canvas, point, 8, alpha * .52);
      _spark(
        canvas,
        point,
        (i % 3 + 2.0) * alpha,
        starGameGold.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_CometPainter oldDelegate) =>
      elapsed != oldDelegate.elapsed ||
      answer != oldDelegate.answer ||
      slot != oldDelegate.slot ||
      star != oldDelegate.star ||
      streak != oldDelegate.streak ||
      perfect != oldDelegate.perfect;
}

Offset _flightPoint(Offset from, Offset to, double t, Offset bend) {
  final progress = Curves.easeInOutCubic.transform(t);
  return Offset.lerp(from, to, progress)! + bend * math.sin(math.pi * progress);
}

void _trail(
  Canvas canvas,
  Offset from,
  Offset to,
  double progress,
  Offset bend,
  double width,
) {
  var head = _flightPoint(from, to, progress, bend);
  for (var i = 0; i < 12; i++) {
    final strength = 1 - i / 12;
    final tail = _flightPoint(
      from,
      to,
      math.max(0.0, progress - (i + 1) * .025),
      bend,
    );
    canvas.drawLine(
      head,
      tail,
      Paint()
        ..color = starGameGold.withValues(alpha: strength * .82)
        ..strokeWidth = width * strength
        ..strokeCap = StrokeCap.round,
    );
    if (i < 5) {
      canvas.drawLine(
        head,
        tail,
        Paint()
          ..color = const Color(0xFFFFF6CD).withValues(alpha: strength * .9)
          ..strokeWidth = width * strength * .44
          ..strokeCap = StrokeCap.round,
      );
    }
    head = tail;
  }
}

void _burst(
  Canvas canvas,
  Offset center,
  double progress,
  double radius,
  int particles, {
  required double origin,
}) {
  final fade = 1 - progress;
  final spread = origin + radius * Curves.easeOutCubic.transform(progress);
  _glow(canvas, center, spread * .7, fade * .60);
  canvas.drawCircle(
    center,
    spread,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * fade
      ..color = const Color(0xFFFFEAB2).withValues(alpha: .74 * fade),
  );
  for (var i = 0; i < particles; i++) {
    final point =
        center +
        Offset.fromDirection(i * 2 * math.pi / particles + .28, spread);
    _spark(
      canvas,
      point,
      (i.isEven ? 4.8 : 3.1) * fade,
      starGameGold.withValues(alpha: fade),
    );
  }
}

void _glow(Canvas canvas, Offset center, double radius, double opacity) {
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..shader = RadialGradient(
        colors: [
          starGameGold.withValues(alpha: opacity),
          starGameGold.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );
}

void _spark(Canvas canvas, Offset center, double radius, Color color) {
  final path = Path()..moveTo(center.dx, center.dy - radius);
  for (var i = 1; i < 8; i++) {
    final point =
        center +
        Offset.fromDirection(
          i * math.pi / 4 - math.pi / 2,
          radius * (i.isEven ? 1 : .24),
        );
    path.lineTo(point.dx, point.dy);
  }
  canvas.drawPath(path..close(), Paint()..color = color);
}
