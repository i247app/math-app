import 'package:material_ui/material_ui.dart';
import 'package:numi/features/games/widgets/star_game_art.dart';

enum StarGameAnswerTone {
  sapphire(
    Color(0xFFFFD680),
    Color(0xFF915719),
    Color(0xFF2349C7),
    Color(0xFF7FD7FF),
    Color(0xFF0A174C),
  ),
  correct(
    Color(0xFFA4F3C6),
    Color(0xFF22684A),
    Color(0xFF167E64),
    Color(0xFF8DF9C9),
    Color(0xFF103B37),
  ),
  wrong(
    Color(0xFFFFADC5),
    Color(0xFF813858),
    Color(0xFF8B376B),
    Color(0xFFF89FC9),
    Color(0xFF391932),
  );

  const StarGameAnswerTone(
    this.rim,
    this.rimShade,
    this.glass,
    this.highlight,
    this.core,
  );

  final Color rim;
  final Color rimShade;
  final Color glass;
  final Color highlight;
  final Color core;
}

class StarGameAnswerGem extends CustomPainter {
  const StarGameAnswerGem({required this.tone, required this.charge});

  final StarGameAnswerTone tone;
  final double charge;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset(0, -.008 * size.height));
    final radius = size.shortestSide * .48;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final outline = starGameRoundedStar(starGameStarVertices(center, radius));
    final glassRim = starGameStarVertices(center, radius * .89);
    final innerRim = starGameStarVertices(center, radius * .61);
    final glass = starGameRoundedStar(glassRim);
    final core = starGameRoundedStar(innerRim);
    final brightRim = Color.lerp(tone.rim, Colors.white, .60 + charge * .25)!;

    canvas.drawPath(
      outline.shift(Offset(0, radius * .10)),
      Paint()
        ..color = const Color(0x99121B39)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.3),
    );
    if (charge > 0) {
      canvas.drawPath(
        outline,
        Paint()
          ..color = tone.rim.withValues(alpha: charge * .65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * .17
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    canvas.drawPath(
      outline.shift(Offset(0, radius * .065)),
      Paint()..color = tone.rimShade,
    );
    canvas.drawPath(
      outline,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [brightRim, tone.rim, tone.rimShade, tone.rim],
          stops: const [0, .38, .69, 1],
        ).createShader(bounds),
    );

    canvas.save();
    canvas.clipPath(glass);
    canvas.drawPath(glass, Paint()..color = tone.glass);
    const reflections = [.72, .94, .52, .16, .46, .21, .60, .78, .34, .57];
    for (var index = 0; index < glassRim.length; index++) {
      final next = (index + 1) % glassRim.length;
      final reflection = reflections[index];
      final face = Path()
        ..moveTo(glassRim[index].dx, glassRim[index].dy)
        ..lineTo(glassRim[next].dx, glassRim[next].dy)
        ..lineTo(innerRim[next].dx, innerRim[next].dy)
        ..lineTo(innerRim[index].dx, innerRim[index].dy)
        ..close();
      canvas.drawPath(
        face,
        Paint()..color = Color.lerp(tone.glass, tone.highlight, reflection)!,
      );
      final bevel = Path()
        ..moveTo(glassRim[index].dx, glassRim[index].dy)
        ..lineTo(innerRim[next].dx, innerRim[next].dy)
        ..lineTo(innerRim[index].dx, innerRim[index].dy)
        ..close();
      canvas.drawPath(
        bevel,
        Paint()
          ..color = Color.lerp(tone.glass, tone.core, .65 - reflection * .36)!,
      );
    }
    canvas.drawPath(
      core,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color.lerp(tone.core, tone.glass, .35)!, tone.core],
        ).createShader(core.getBounds()),
    );
    canvas.restore();
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * .035
        ..color = tone.rimShade.withValues(alpha: .84),
    );
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * .045
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [brightRim, tone.rim, tone.rimShade],
        ).createShader(bounds),
    );

    final glint = Offset.lerp(glassRim[1], glassRim[2], .56)!;
    final shineRadius = radius * (.17 + charge * .12);
    canvas.drawCircle(
      glint,
      shineRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            brightRim.withValues(alpha: .78),
            brightRim.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: glint, radius: shineRadius)),
    );
    paintStarGameGlint(
      canvas,
      glint,
      radius * (.077 + .07 * charge),
      brightRim,
    );
  }

  @override
  bool shouldRepaint(StarGameAnswerGem oldDelegate) =>
      tone != oldDelegate.tone || charge != oldDelegate.charge;
}
