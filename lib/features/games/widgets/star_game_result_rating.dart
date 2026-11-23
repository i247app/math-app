import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

const _firstArrival = 100;
const _arrivalInterval = 350;
const _flightTime = 260;

int _startAt(int slot) => _firstArrival + slot * _arrivalInterval;

int _impactTime(int slot) => slot == 2 ? 440 : 270;

class StarGameResultRating extends StatelessWidget {
  const StarGameResultRating({super.key, required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.formatText(AppKeys.gamesStars, {'count': stars}),
    excludeSemantics: true,
    child: IgnorePointer(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 344),
        child: SizedBox(
          width: double.infinity,
          height: 119,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final size = math.min(width * .36, 108.0);
              final offset = size * .88;
              final slots = [
                (
                  center: Offset(width / 2 - offset, height * .56),
                  size: size * .73,
                ),
                (
                  center: Offset(width / 2 + offset, height * .56),
                  size: size * .73,
                ),
                (center: Offset(width / 2, height * .49), size: size),
              ];

              if (stars == 0 || MediaQuery.disableAnimationsOf(context)) {
                return _buildRating(slots, double.infinity);
              }
              final last = stars - 1;
              final end = _startAt(last) + _flightTime + _impactTime(last);
              return TweenAnimationBuilder<double>(
                key: ValueKey(stars),
                tween: Tween(begin: 0, end: end.toDouble()),
                duration: Duration(milliseconds: end),
                builder: (context, elapsed, _) => _buildRating(slots, elapsed),
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _buildRating(
    List<({Offset center, double size})> slots,
    double elapsed,
  ) {
    final centerImpact = (elapsed - _startAt(2) - _flightTime) / _impactTime(2);
    final shake = stars == 3 && centerImpact >= 0 && centerImpact < 1
        ? math.sin(centerImpact * math.pi * 6) *
              math.pow(1 - centerImpact, 3) *
              5
        : 0.0;
    return Transform.translate(
      offset: Offset(0, shake),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < slots.length; index++)
            Positioned.fromRect(
              key: ValueKey('star-game-result-slot-$index'),
              rect: Rect.fromCenter(
                center: slots[index].center,
                width: slots[index].size,
                height: slots[index].size,
              ),
              child: const CustomPaint(
                painter: _RewardStarPainter(earned: false),
              ),
            ),
          for (var index = 0; index < stars; index++)
            if (elapsed >= _startAt(index)) ...[
              ?_impact(
                slots[index],
                index,
                elapsed - _startAt(index) - _flightTime,
              ),
              _reward(slots[index], index, elapsed - _startAt(index)),
            ],
        ],
      ),
    );
  }

  Widget? _impact(
    ({Offset center, double size}) slot,
    int index,
    double elapsed,
  ) {
    final progress = elapsed / _impactTime(index);
    if (progress < 0 || progress >= 1) return null;
    final spread = slot.size * (index == 2 ? 1.78 : 1.56);
    return Positioned.fromRect(
      rect: Rect.fromCenter(center: slot.center, width: spread, height: spread),
      child: CustomPaint(
        painter: _ImpactPainter(progress: progress, finale: index == 2),
      ),
    );
  }

  Widget _reward(
    ({Offset center, double size}) slot,
    int index,
    double elapsed,
  ) {
    final flight = (elapsed / _flightTime).clamp(0.0, 1.0);
    final impact = ((elapsed - _flightTime) / _impactTime(index)).clamp(
      0.0,
      1.0,
    );
    final remaining = 1 - Curves.easeInCubic.transform(flight);
    final fromSide = switch (index) {
      0 => 1.0,
      1 => -1.0,
      _ => 0.0,
    };
    final center =
        slot.center +
        Offset(fromSide * slot.size * .55, -slot.size * .56) * remaining;
    final approach = 1 + remaining * (index == 2 ? 1.62 : 1.25);
    final bounce = math.sin(4 * math.pi * impact) * (1 - impact) * (1 - impact);
    final force = index == 2 ? .31 : .19;
    final tilt = remaining * (index == 2 ? .43 : fromSide * .62);

    return Positioned.fromRect(
      key: ValueKey('star-game-result-reward-$index'),
      rect: Rect.fromCenter(
        center: center,
        width: slot.size,
        height: slot.size,
      ),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, .0028)
          ..rotateY(tilt)
          ..rotateZ(tilt * .46),
        child: Transform.scale(
          scaleX: approach * (1 + bounce * force * .56),
          scaleY: approach * (1 - bounce * force),
          child: Opacity(
            opacity: (flight * 6).clamp(0.0, 1.0),
            child: const CustomPaint(painter: _RewardStarPainter(earned: true)),
          ),
        ),
      ),
    );
  }
}

class _RewardStarPainter extends CustomPainter {
  const _RewardStarPainter({required this.earned});

  final bool earned;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .46;
    final rim = _starVertices(center, radius);
    final outline = _roundedStar(rim);
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (!earned) {
      canvas.drawPath(
        outline.shift(Offset(0, radius * .075)),
        Paint()..color = const Color(0xFF0D1230),
      );
      canvas.drawPath(outline, Paint()..color = const Color(0xFF121B3F));
      canvas.drawPath(
        outline,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * .062
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8293C5), Color(0xFF394873)],
          ).createShader(rect),
      );
      canvas.drawPath(
        _roundedStar(_starVertices(center, radius * .85)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF34436C),
      );
      return;
    }

    canvas.drawShadow(outline, const Color(0xB0FF9D29), radius * .21, true);
    canvas.drawPath(
      outline.shift(Offset(0, radius * .09)),
      Paint()..color = const Color(0xFFE08C27),
    );
    const facets = [
      Color(0xFFFFE59A),
      Color(0xFFFFF3BE),
      Color(0xFFFFD76B),
      Color(0xFFFFB438),
      Color(0xFFF4A136),
      Color(0xFFFFC64B),
      Color(0xFFFFDA74),
      Color(0xFFFFEBAA),
      Color(0xFFFFD061),
      Color(0xFFFFF1BA),
    ];
    canvas.save();
    canvas.clipPath(outline);
    canvas.drawPath(outline, Paint()..color = const Color(0xFFFFBF4D));
    final ridge = center + Offset(-radius * .06, -radius * .08);
    for (var i = 0; i < rim.length; i++) {
      final first = rim[i];
      final second = rim[(i + 1) % rim.length];
      canvas.drawPath(
        Path()
          ..moveTo(ridge.dx, ridge.dy)
          ..lineTo(first.dx, first.dy)
          ..lineTo(second.dx, second.dy)
          ..close(),
        Paint()..color = facets[i],
      );
    }
    canvas.drawPath(
      _roundedStar(_starVertices(center, radius * .88)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * .032
        ..color = const Color(0x7AFFF5CB),
    );
    canvas.restore();
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * .058
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDE5), Color(0xFFFFE59D), Color(0xFFF09A31)],
        ).createShader(rect),
    );
    final shine = center + Offset(-radius * .35, -radius * .38);
    _drawGlint(canvas, shine, radius * .16, const Color(0xFFFFFCE0));
    canvas.drawCircle(
      shine + Offset(-radius * .21, radius * .13),
      radius * .035,
      Paint()..color = const Color(0xAFFFFDDF),
    );
  }

  @override
  bool shouldRepaint(_RewardStarPainter oldDelegate) =>
      earned != oldDelegate.earned;
}

class _ImpactPainter extends CustomPainter {
  const _ImpactPainter({required this.progress, required this.finale});

  final double progress;
  final bool finale;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final reach = size.shortestSide / 2;
    final fade = 1 - progress;
    final spread = Curves.easeOutCubic.transform(progress);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * fade
      ..color = const Color(0xFFFFD180).withValues(alpha: .65 * fade);
    canvas.drawCircle(center, reach * (.40 + .58 * spread), ring);
    if (finale) {
      canvas.drawCircle(center, reach * (.31 + .49 * spread), ring);
    }

    final rays = finale ? 13 : 8;
    for (var index = 0; index < rays; index++) {
      final angle = 2 * math.pi * index / rays + .19;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final distance = reach * (.42 + (.42 + index % 3 * .055) * spread);
      final point = center + direction * distance;
      final color =
          (index.isEven ? const Color(0xFFFFF9D2) : const Color(0xFFFFB94D))
              .withValues(alpha: fade);
      _drawGlint(canvas, point, (index.isEven ? 5 : 3.2) * fade, color);
    }
  }

  @override
  bool shouldRepaint(_ImpactPainter oldDelegate) =>
      progress != oldDelegate.progress || finale != oldDelegate.finale;
}

List<Offset> _starVertices(Offset center, double radius) => [
  for (var i = 0; i < 10; i++)
    center +
        Offset.fromDirection(
          i * math.pi / 5 - math.pi / 2,
          i.isEven ? radius : radius * .53,
        ),
];

Path _roundedStar(List<Offset> vertices) {
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

void _drawGlint(Canvas canvas, Offset center, double radius, Color color) {
  final path = Path()..moveTo(center.dx, center.dy - radius);
  for (var i = 1; i < 8; i++) {
    final point =
        center +
        Offset.fromDirection(
          i * math.pi / 4 - math.pi / 2,
          radius * (i.isEven ? 1 : .26),
        );
    path.lineTo(point.dx, point.dy);
  }
  canvas.drawPath(path..close(), Paint()..color = color);
}
