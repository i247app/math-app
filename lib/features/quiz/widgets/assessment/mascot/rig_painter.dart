part of '../numi_assessment_mascot_animation.dart';

class _NumiRigPainter extends CustomPainter {
  const _NumiRigPainter({
    required this.atlas,
    required this.thinkingHand,
    required this.thinkingHandShader,
    required this.wingShader,
    required this.leftTorsoShader,
    required this.rightTorsoShader,
    required this.leftGlassesShader,
    required this.rightGlassesShader,
    required this.progress,
  });

  static const _rigSize = Size(1000, 900);
  static const _imageDestination = Rect.fromLTWH(0, 0, 1000, 1000);

  final ui.Image atlas;
  final ui.Image thinkingHand;
  final ui.ImageShader thinkingHandShader;
  final ui.Shader wingShader;
  final ui.Shader leftTorsoShader;
  final ui.Shader rightTorsoShader;
  final ui.Shader leftGlassesShader;
  final ui.Shader rightGlassesShader;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / _rigSize.width,
      size.height / _rigSize.height,
    );
    final offset = Offset(
      (size.width - (_rigSize.width * scale)) / 2,
      (size.height - (_rigSize.height * scale)) / 2,
    );
    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..scale(scale);

    final pose = _RigPose.at(progress);
    _drawShadow(canvas, pose);

    const bodyPivot = Offset(500, 850);
    canvas
      ..save()
      ..translate(bodyPivot.dx, bodyPivot.dy + pose.bodyY)
      ..rotate(pose.bodyAngle)
      ..scale(pose.bodyScaleX, pose.bodyScaleY)
      ..translate(-bodyPivot.dx, -bodyPivot.dy);

    _drawPart(
      canvas,
      mask: Path()..addRect(const Rect.fromLTWH(315, 775, 155, 125)),
      pivot: const Offset(410, 790),
      angle: pose.leftLegAngle,
      translate: Offset(0, pose.legY),
    );
    _drawPart(
      canvas,
      mask: Path()..addRect(const Rect.fromLTWH(530, 775, 155, 125)),
      pivot: const Offset(590, 790),
      angle: pose.rightLegAngle,
      translate: Offset(0, pose.legY),
    );
    _drawPart(
      canvas,
      mask: _wingMask(true),
      pivot: const Offset(275, 600),
      angle: pose.leftWingAngle,
      translate: pose.leftWingOffset,
      opacity: pose.leftWingFront > 0.001 || pose.flightWingBlend > 0.001
          ? 0
          : 1,
    );
    _drawPart(
      canvas,
      mask: _wingMask(false),
      pivot: const Offset(725, 600),
      angle: pose.rightWingAngle,
      translate: pose.rightWingOffset,
      opacity: pose.flightWingBlend > 0.001 ? 0 : 1,
    );
    if (pose.flightWingBlend > 0.001) {
      _drawFlyingWing(
        canvas,
        left: true,
        angle: pose.leftWingAngle,
        bend: pose.flightWingBend,
        translate: pose.leftWingOffset,
        opacity: 1,
      );
      _drawFlyingWing(
        canvas,
        left: false,
        angle: pose.rightWingAngle,
        bend: -pose.flightWingBend,
        translate: pose.rightWingOffset,
        opacity: 1,
      );
    }
    _drawTorso(canvas);
    _drawGlassesBacking(canvas);
    canvas.save();
    // The source artwork already has anti-aliased edges. Anti-aliasing the
    // clipping path a second time creates a pale one-pixel seam between the
    // face and torso on high-density screens.
    canvas.clipPath(_headMask(), doAntiAlias: false);
    canvas.drawImageRect(
      atlas,
      _imageSource,
      _imageDestination,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
    if (pose.leftWingFront > 0.001) {
      _drawThinkingHand(canvas, pose.leftWingFront, pose.handFlex);
    }
    _drawBlink(canvas, pose.leftBlink, pose.rightBlink);

    canvas
      ..restore()
      ..restore();
  }

  void _drawPart(
    Canvas canvas, {
    required Path mask,
    required Offset pivot,
    required double angle,
    Offset translate = Offset.zero,
    double opacity = 1,
  }) {
    canvas
      ..save()
      ..translate(pivot.dx + translate.dx, pivot.dy + translate.dy)
      ..rotate(angle)
      ..translate(-pivot.dx, -pivot.dy)
      ..clipPath(mask)
      ..drawImageRect(
        atlas,
        _imageSource,
        _imageDestination,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity.clamp(0, 1))
          ..filterQuality = FilterQuality.high,
      )
      ..restore();
  }

  Path _wingMask(bool left) {
    if (left) {
      return Path()
        ..moveTo(272, 585)
        ..cubicTo(225, 575, 175, 590, 155, 630)
        ..cubicTo(138, 680, 176, 738, 246, 775)
        ..cubicTo(262, 762, 273, 730, 280, 690)
        ..cubicTo(287, 645, 282, 607, 272, 585)
        ..close();
    }
    return Path()
      ..moveTo(728, 585)
      ..cubicTo(775, 575, 825, 590, 845, 630)
      ..cubicTo(862, 680, 824, 738, 754, 775)
      ..cubicTo(738, 762, 727, 730, 720, 690)
      ..cubicTo(713, 645, 718, 607, 728, 585)
      ..close();
  }

  void _drawFlyingWing(
    Canvas canvas, {
    required bool left,
    required double angle,
    required double bend,
    required Offset translate,
    required double opacity,
  }) {
    const columns = 4;
    const rows = 6;
    final bounds = left
        ? const Rect.fromLTWH(135, 565, 180, 225)
        : const Rect.fromLTWH(685, 565, 180, 225);
    final positions = <Offset>[];
    final indices = <int>[];

    for (var row = 0; row < rows; row++) {
      final v = row / (rows - 1);
      for (var column = 0; column < columns; column++) {
        final u = column / (columns - 1);
        final base = Offset(
          bounds.left + (bounds.width * u),
          bounds.top + (bounds.height * v),
        );
        positions.add(
          _deformWingPoint(base, left, angle, bend, translate, bounds),
        );
      }
    }
    for (var row = 0; row < rows - 1; row++) {
      for (var column = 0; column < columns - 1; column++) {
        final topLeft = (row * columns) + column;
        final topRight = topLeft + 1;
        final bottomLeft = topLeft + columns;
        final bottomRight = bottomLeft + 1;
        indices.addAll([
          topLeft,
          bottomLeft,
          topRight,
          topRight,
          bottomLeft,
          bottomRight,
        ]);
      }
    }

    final vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      indices: indices,
    );
    canvas
      ..saveLayer(
        const Rect.fromLTWH(20, 350, 960, 500),
        Paint()..color = Colors.white.withValues(alpha: opacity.clamp(0, 1)),
      )
      ..clipPath(_deformedWingMask(left, angle, bend, translate, bounds))
      ..drawVertices(
        vertices,
        BlendMode.src,
        Paint()
          ..shader = wingShader
          ..filterQuality = FilterQuality.high,
      )
      ..restore();
    vertices.dispose();
  }

  Offset _deformWingPoint(
    Offset point,
    bool left,
    double angle,
    double bend,
    Offset translate,
    Rect bounds,
  ) {
    final shoulder = left ? const Offset(275, 600) : const Offset(725, 600);
    final middle = left ? const Offset(230, 680) : const Offset(770, 680);
    final along = ((point.dy - bounds.top) / bounds.height).clamp(0.0, 1.0);
    var result = _rotateAround(point, shoulder, angle);
    final movedMiddle = _rotateAround(middle, shoulder, angle);
    final tipWeight = _smoothWeight(0.28, 1, along);
    result = _rotateAround(result, movedMiddle, bend * tipWeight);
    return result + translate;
  }

  Path _deformedWingMask(
    bool left,
    double angle,
    double bend,
    Offset translate,
    Rect bounds,
  ) {
    Offset d(double x, double y) =>
        _deformWingPoint(Offset(x, y), left, angle, bend, translate, bounds);
    final path = Path();
    final start = left ? d(272, 585) : d(728, 585);
    path.moveTo(start.dx, start.dy);
    var first = left ? d(225, 575) : d(775, 575);
    var second = left ? d(175, 590) : d(825, 590);
    var end = left ? d(155, 630) : d(845, 630);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    first = left ? d(138, 680) : d(862, 680);
    second = left ? d(176, 738) : d(824, 738);
    end = left ? d(246, 775) : d(754, 775);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    first = left ? d(262, 762) : d(738, 762);
    second = left ? d(273, 730) : d(727, 730);
    end = left ? d(280, 690) : d(720, 690);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    first = left ? d(287, 645) : d(713, 645);
    second = left ? d(282, 607) : d(718, 607);
    end = left ? d(272, 585) : d(728, 585);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    return path..close();
  }

  Rect get _imageSource =>
      Rect.fromLTWH(0, 0, atlas.width.toDouble(), atlas.height.toDouble());

  Path _headMask() {
    final mask = Path()
      ..addPolygon(const <Offset>[
        Offset(215, 135),
        Offset(500, 105),
        Offset(785, 135),
        Offset(500, 405),
      ], true);
    return mask
      ..addPath(_glassesTriangle(true), Offset.zero)
      ..addPath(_glassesTriangle(false), Offset.zero)
      // The eyes overlap the lower glasses edges in the source artwork. Keep
      // their complete circles without widening either orange triangle.
      ..addOval(
        Rect.fromCenter(
          center: const Offset(306, 414),
          width: 215,
          height: 215,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: const Offset(694, 414),
          width: 215,
          height: 215,
        ),
      )
      // The beak extends below the glasses as its own diamond.
      ..addPolygon(const <Offset>[
        Offset(500, 405),
        Offset(570, 485),
        Offset(500, 590),
        Offset(430, 485),
      ], true);
  }

  Path _torsoMask() => Path()
    ..moveTo(195, 555)
    ..cubicTo(185, 600, 215, 690, 295, 748)
    ..cubicTo(350, 788, 425, 805, 500, 805)
    ..cubicTo(575, 805, 650, 788, 705, 748)
    ..cubicTo(785, 690, 815, 600, 805, 555)
    // A shallow shoulder apron continues beneath the full lower edge of the
    // glasses. It only fills the overlap area; the visible belly remains the
    // narrower rounded shape above.
    ..lineTo(860, 520)
    ..cubicTo(730, 500, 610, 420, 500, 390)
    ..cubicTo(390, 420, 270, 500, 140, 520)
    ..lineTo(195, 555)
    ..close();

  void _drawTorso(Canvas canvas) {
    final torso = _torsoMask();
    final left = Path.combine(
      PathOperation.intersect,
      torso,
      Path()..addRect(const Rect.fromLTWH(0, 0, 500, 900)),
    );
    final right = Path.combine(
      PathOperation.intersect,
      torso,
      Path()..addRect(const Rect.fromLTWH(500, 0, 500, 900)),
    );
    canvas
      ..drawPath(left, Paint()..shader = leftTorsoShader)
      ..drawPath(right, Paint()..shader = rightTorsoShader);
  }

  void _drawGlassesBacking(Canvas canvas) {
    canvas
      ..drawPath(_glassesTriangle(true), Paint()..shader = leftGlassesShader)
      ..drawPath(_glassesTriangle(false), Paint()..shader = rightGlassesShader);
  }

  Path _glassesTriangle(bool left) => Path()
    ..addPolygon(
      left
          ? const <Offset>[Offset(94, 554), Offset(216, 135), Offset(500, 405)]
          : const <Offset>[
              Offset(500, 405),
              Offset(784, 135),
              Offset(906, 554),
            ],
      true,
    );

  void _drawThinkingHand(Canvas canvas, double progress, double flex) {
    const columns = 5;
    const rows = 6;
    const source = Rect.fromLTWH(195, 570, 250, 240);
    const destination = Rect.fromLTWH(139, 458, 250, 240);
    final positions = <Offset>[];
    final textureCoordinates = <Offset>[];
    final indices = <int>[];

    for (var row = 0; row < rows; row++) {
      final v = row / (rows - 1);
      for (var column = 0; column < columns; column++) {
        final u = column / (columns - 1);
        positions.add(
          _deformHandPoint(
            Offset(
              destination.left + (destination.width * u),
              destination.top + (destination.height * v),
            ),
            progress,
            flex,
          ),
        );
        textureCoordinates.add(
          Offset(
            source.left + (source.width * u),
            source.top + (source.height * v),
          ),
        );
      }
    }
    for (var row = 0; row < rows - 1; row++) {
      for (var column = 0; column < columns - 1; column++) {
        final topLeft = (row * columns) + column;
        final topRight = topLeft + 1;
        final bottomLeft = topLeft + columns;
        final bottomRight = bottomLeft + 1;
        indices.addAll([
          topLeft,
          bottomLeft,
          topRight,
          topRight,
          bottomLeft,
          bottomRight,
        ]);
      }
    }

    final vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: textureCoordinates,
      indices: indices,
    );
    canvas
      ..saveLayer(
        const Rect.fromLTWH(70, 370, 390, 390),
        Paint()
          ..color = Colors.white.withValues(
            alpha: _smoothWeight(0, 0.1, progress),
          ),
      )
      ..clipPath(_deformedHandMask(progress, flex))
      ..drawVertices(
        vertices,
        BlendMode.src,
        Paint()
          ..shader = thinkingHandShader
          ..filterQuality = FilterQuality.high,
      )
      ..restore();
    vertices.dispose();
  }

  Offset _deformHandPoint(Offset point, double progress, double flex) {
    const shoulder = Offset(215, 650);
    const elbow = Offset(235, 560);
    const wrist = Offset(318, 485);
    final rest = 1 - progress;
    final shoulderAngle = (-0.72 * rest) + (0.05 * flex);
    final elbowAngle = (-0.46 * rest) + (0.2 * flex);
    final wristAngle = (0.34 * rest) - (0.28 * flex);
    final along = ((650 - point.dy) / 210).clamp(0.0, 1.0);

    var result = _rotateAround(point, shoulder, shoulderAngle);
    final movedElbow = _rotateAround(elbow, shoulder, shoulderAngle);
    final elbowWeight = _smoothWeight(0.24, 0.68, along);
    result = _rotateAround(result, movedElbow, elbowAngle * elbowWeight);
    var movedWrist = _rotateAround(wrist, shoulder, shoulderAngle);
    movedWrist = _rotateAround(movedWrist, movedElbow, elbowAngle);
    final wristWeight = _smoothWeight(0.62, 1, along);
    result = _rotateAround(result, movedWrist, wristAngle * wristWeight);
    return result + Offset(-32 * rest, 42 * rest);
  }

  Path _deformedHandMask(double progress, double flex) {
    Offset d(double x, double y) =>
        _deformHandPoint(Offset(x + 24, y + 38), progress, flex);
    final path = Path();
    var point = d(325, 428);
    path.moveTo(point.dx, point.dy);
    var first = d(350, 432);
    var second = d(365, 450);
    var end = d(346, 490);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    first = d(334, 515);
    second = d(310, 538);
    end = d(300, 550);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    first = d(327, 551);
    second = d(335, 570);
    end = d(315, 604);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    first = d(292, 642);
    second = d(251, 658);
    end = d(205, 646);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    first = d(153, 634);
    second = d(124, 595);
    end = d(125, 542);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    first = d(126, 500);
    second = d(151, 464);
    end = d(201, 446);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    first = d(244, 432);
    second = d(285, 438);
    end = d(325, 428);
    path.cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
    return path..close();
  }

  Offset _rotateAround(Offset point, Offset pivot, double angle) {
    final delta = point - pivot;
    final cosine = math.cos(angle);
    final sine = math.sin(angle);
    return pivot +
        Offset(
          (delta.dx * cosine) - (delta.dy * sine),
          (delta.dx * sine) + (delta.dy * cosine),
        );
  }

  double _smoothWeight(double start, double end, double value) {
    final x = ((value - start) / (end - start)).clamp(0.0, 1.0);
    return x * x * (3 - (2 * x));
  }

  void _drawShadow(Canvas canvas, _RigPose pose) {
    final squash = 1 - ((-pose.bodyY / 26).clamp(0, 1) * 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(500, 865),
        width: 350 * squash,
        height: 34 * squash,
      ),
      Paint()
        ..color = const Color(0x22002424)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11),
    );
  }

  void _drawBlink(Canvas canvas, double leftBlink, double rightBlink) {
    if (leftBlink <= 0.01 && rightBlink <= 0.01) return;
    const centers = <Offset>[Offset(306, 414), Offset(694, 414)];
    final blinks = <double>[leftBlink, rightBlink];
    final lidPaint = Paint()..color = const Color(0xFFFF572F);
    final linePaint = Paint()
      ..color = const Color(0xFF4B2E26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < centers.length; index++) {
      final center = centers[index];
      final blink = blinks[index];
      if (blink <= 0.01) continue;
      final eye = Rect.fromCenter(center: center, width: 205, height: 205);
      final cover = eye.height * 0.52 * blink;
      canvas.save();
      canvas.clipPath(_glassesTriangle(index == 0), doAntiAlias: false);
      canvas
        ..save()
        ..clipPath(Path()..addOval(eye))
        ..drawRect(
          Rect.fromLTRB(eye.left, eye.top, eye.right, eye.top + cover),
          lidPaint,
        )
        ..drawRect(
          Rect.fromLTRB(eye.left, eye.bottom - cover, eye.right, eye.bottom),
          lidPaint,
        )
        ..restore();
      if (blink > 0.78) {
        canvas.drawArc(
          Rect.fromCenter(
            center: center + const Offset(0, 12),
            width: 94,
            height: 55,
          ),
          math.pi * 0.12,
          math.pi * 0.76,
          false,
          linePaint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _NumiRigPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.atlas != atlas ||
      oldDelegate.thinkingHand != thinkingHand;
}
