import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

/// Native Flutter cutout rig for Numi's assessment-generation sequence.
///
/// The painter masks independent body, wing, and leg layers directly from the
/// original brand asset. Flutter moves those exact pixels on every display
/// tick, avoiding both paid runtimes and frame swapping.
class NumiAssessmentMascotAnimation extends StatefulWidget {
  const NumiAssessmentMascotAnimation({super.key});

  @override
  State<NumiAssessmentMascotAnimation> createState() =>
      _NumiAssessmentMascotAnimationState();
}

class _NumiAssessmentMascotAnimationState
    extends State<NumiAssessmentMascotAnimation>
    with SingleTickerProviderStateMixin {
  static const _cycleDuration = Duration(milliseconds: 4000);
  static const _sourceAsset = 'assets/images/numi-mascot.png';
  static const _thinkingHandAsset = 'assets/images/no-profile-mascot.png';

  late final AnimationController _controller;
  ui.Image? _atlas;
  ui.Image? _thinkingHand;
  ui.ImageShader? _thinkingHandShader;
  ui.Shader? _wingShader;
  ui.Shader? _leftTorsoShader;
  ui.Shader? _rightTorsoShader;
  ui.Shader? _leftGlassesShader;
  ui.Shader? _rightGlassesShader;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycleDuration)
      ..repeat();
    _loadImages();
  }

  Future<ui.Image> _decodeAsset(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  Future<void> _loadImages() async {
    final images = await Future.wait([
      _decodeAsset(_sourceAsset),
      _decodeAsset(_thinkingHandAsset),
    ]);
    if (!mounted) {
      for (final image in images) {
        image.dispose();
      }
      return;
    }
    setState(() {
      _atlas = images[0];
      _thinkingHand = images[1];
      _thinkingHandShader = ui.ImageShader(
        images[1],
        TileMode.clamp,
        TileMode.clamp,
        Matrix4.identity().storage,
      );
      _wingShader = ui.Gradient.linear(
        const Offset(0, 565),
        const Offset(0, 790),
        const [Color(0xFF16B8B7), Color(0xFF007D84)],
        const [0, 1],
      );
      _leftTorsoShader = ui.Gradient.linear(
        const Offset(500, 510),
        const Offset(155, 790),
        const [Color(0xFF0AAEB0), Color(0xFF00868D)],
        const [0, 1],
      );
      _rightTorsoShader = ui.Gradient.linear(
        const Offset(500, 510),
        const Offset(845, 790),
        const [Color(0xFF00969C), Color(0xFF006E78)],
        const [0, 1],
      );
      _leftGlassesShader = ui.Gradient.linear(
        const Offset(210, 140),
        const Offset(500, 550),
        const [Color(0xFFFF6A31), Color(0xFFFF4D22)],
        const [0, 1],
      );
      _rightGlassesShader = ui.Gradient.linear(
        const Offset(790, 140),
        const Offset(500, 550),
        const [Color(0xFFFF6A31), Color(0xFFFF4D22)],
        const [0, 1],
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0.68;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _thinkingHandShader?.dispose();
    _wingShader?.dispose();
    _leftTorsoShader?.dispose();
    _rightTorsoShader?.dispose();
    _leftGlassesShader?.dispose();
    _rightGlassesShader?.dispose();
    _atlas?.dispose();
    _thinkingHand?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Numi',
      image: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: 310,
          height: 290,
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final sequence = _MascotSequence.at(_controller.value);
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned.fill(
                      key: const ValueKey('numi-rig-canvas'),
                      top: 42,
                      child:
                          _atlas == null ||
                              _thinkingHand == null ||
                              _thinkingHandShader == null ||
                              _wingShader == null ||
                              _leftTorsoShader == null ||
                              _rightTorsoShader == null ||
                              _leftGlassesShader == null ||
                              _rightGlassesShader == null
                          ? Image.asset(
                              'assets/images/numi-mascot.png',
                              key: const ValueKey('numi-rig-loading-fallback'),
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            )
                          : CustomPaint(
                              painter: _NumiRigPainter(
                                atlas: _atlas!,
                                thinkingHand: _thinkingHand!,
                                thinkingHandShader: _thinkingHandShader!,
                                wingShader: _wingShader!,
                                leftTorsoShader: _leftTorsoShader!,
                                rightTorsoShader: _rightTorsoShader!,
                                leftGlassesShader: _leftGlassesShader!,
                                rightGlassesShader: _rightGlassesShader!,
                                progress: _controller.value,
                              ),
                            ),
                    ),
                    _StageDecoration(sequence: sequence),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

enum _MascotStage { neutral, wondering, thinking, idea, ready }

class _MascotSequence {
  const _MascotSequence(this.stage, this.progress);

  final _MascotStage stage;
  final double progress;

  static _MascotSequence at(double value) {
    const stops = <double>[0, 0.15, 0.36, 0.58, 0.79, 1];
    final stageIndex = value < stops[1]
        ? 0
        : value < stops[2]
        ? 1
        : value < stops[3]
        ? 2
        : value < stops[4]
        ? 3
        : 4;
    final start = stops[stageIndex];
    final end = stops[stageIndex + 1];
    return _MascotSequence(
      _MascotStage.values[stageIndex],
      ((value - start) / (end - start)).clamp(0, 1),
    );
  }
}

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

class _RigPose {
  const _RigPose({
    required this.bodyY,
    required this.bodyAngle,
    required this.bodyScaleX,
    required this.bodyScaleY,
    required this.leftWingAngle,
    required this.rightWingAngle,
    required this.leftWingOffset,
    required this.rightWingOffset,
    required this.leftWingFront,
    required this.handFlex,
    required this.flightWingBlend,
    required this.flightWingBend,
    required this.leftLegAngle,
    required this.rightLegAngle,
    required this.legY,
    required this.leftBlink,
    required this.rightBlink,
  });

  final double bodyY;
  final double bodyAngle;
  final double bodyScaleX;
  final double bodyScaleY;
  final double leftWingAngle;
  final double rightWingAngle;
  final Offset leftWingOffset;
  final Offset rightWingOffset;
  final double leftWingFront;
  final double handFlex;
  final double flightWingBlend;
  final double flightWingBend;
  final double leftLegAngle;
  final double rightLegAngle;
  final double legY;
  final double leftBlink;
  final double rightBlink;

  static _RigPose at(double t) {
    final breath = (math.sin(t * math.pi * 4) + 1) / 2;
    final wondering = _envelope(t, 0.14, 0.19, 0.31, 0.37);
    final thinking = _envelope(t, 0.34, 0.4, 0.53, 0.6);
    final idea = _envelope(t, 0.56, 0.62, 0.74, 0.81);
    final ready = _smoothStep(0.78, 0.83, t) * (1 - _smoothStep(0.97, 1, t));
    final readyProgress = ((t - 0.78) / 0.22).clamp(0.0, 1.0);
    final flight = math.sin(readyProgress * math.pi) * ready;
    final flap = math.sin(readyProgress * math.pi * 6);
    final normalBlink = math.max(
      _pulse(t, 0.075, 0.088, 0.105),
      _pulse(t, 0.275, 0.288, 0.305),
    );
    final ideaWink = _envelope(t, 0.61, 0.635, 0.705, 0.74);
    final thinkingPhase = ((t - 0.34) / 0.26).clamp(0.0, 1.0);
    final handFlex =
        (math.sin(thinking * math.pi) * 0.22) +
        (math.sin(thinkingPhase * math.pi * 4) * 0.035 * thinking);

    return _RigPose(
      bodyY:
          (-2 * breath) -
          (4 * thinking) -
          (10 * idea) -
          (110 * flight) +
          (3 * flap * ready),
      bodyAngle:
          (-0.08 * wondering) -
          (0.025 * thinking) +
          (0.025 * idea) +
          (0.035 * flap * ready),
      bodyScaleX: 1 + (0.012 * breath) + (0.035 * idea) + (0.045 * flight),
      bodyScaleY: 1 + (0.018 * breath) + (0.03 * idea) + (0.06 * flight),
      leftWingAngle:
          (0.1 * wondering) +
          (1.12 * thinking) +
          (0.34 * idea) +
          ((0.42 + (0.72 * flap)) * ready),
      rightWingAngle:
          (-0.04 * wondering) -
          (0.08 * thinking) -
          (0.34 * idea) -
          ((0.42 + (0.72 * flap)) * ready),
      leftWingOffset: Offset(
        (62 * thinking) - (45 * ready),
        (-68 * thinking) - (30 * ready),
      ),
      rightWingOffset: Offset(
        (-10 * idea) + (45 * ready),
        (-8 * idea) - (30 * ready),
      ),
      leftWingFront: thinking,
      handFlex: handFlex,
      flightWingBlend: ready,
      flightWingBend:
          math.sin((readyProgress * math.pi * 6) - 0.8) * 0.32 * ready,
      leftLegAngle: -0.2 * flight,
      rightLegAngle: 0.2 * flight,
      legY: -25 * flight,
      leftBlink: normalBlink,
      rightBlink: math.max(normalBlink, ideaWink),
    );
  }

  static double _envelope(
    double value,
    double fadeInStart,
    double fadeInEnd,
    double fadeOutStart,
    double fadeOutEnd,
  ) =>
      _smoothStep(fadeInStart, fadeInEnd, value) *
      (1 - _smoothStep(fadeOutStart, fadeOutEnd, value));

  static double _pulse(double value, double start, double peak, double end) {
    if (value <= start || value >= end) return 0;
    if (value < peak) return _smoothStep(start, peak, value);
    return 1 - _smoothStep(peak, end, value);
  }

  static double _smoothStep(double start, double end, double value) {
    final x = ((value - start) / (end - start)).clamp(0.0, 1.0);
    return x * x * (3 - (2 * x));
  }
}

class _StageDecoration extends StatelessWidget {
  const _StageDecoration({required this.sequence});

  final _MascotSequence sequence;

  @override
  Widget build(BuildContext context) {
    final reveal = Curves.easeOutBack.transform(
      math.min(sequence.progress / 0.34, 1),
    );
    final fadeIn = Curves.easeOut.transform(
      math.min(sequence.progress / 0.16, 1),
    );
    final fadeOut = Curves.easeIn.transform(
      math.min((1 - sequence.progress) / 0.18, 1),
    );
    final opacity = math.min(fadeIn, fadeOut);

    return switch (sequence.stage) {
      _MascotStage.neutral => const SizedBox.shrink(),
      _MascotStage.wondering => Positioned(
        right: 32,
        top: 45,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: reveal,
            child: const Text(
              '?',
              style: TextStyle(
                color: AppColors.teal700,
                fontSize: FontSize.displayExtraLarge,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
      _MascotStage.thinking => Positioned(
        top: 15,
        child: Opacity(opacity: opacity, child: const _ThoughtBubble()),
      ),
      _MascotStage.idea => Positioned(
        left: 0,
        right: 0,
        top: -35,
        child: Opacity(
          opacity: opacity,
          child: Center(
            child: Transform.scale(
              scale:
                  reveal *
                  (1 + 0.06 * math.sin(sequence.progress * math.pi * 3)),
              child: const _IdeaBulb(),
            ),
          ),
        ),
      ),
      _MascotStage.ready => Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _MotionLinesPainter(
              opacity: math.sin(sequence.progress * math.pi).clamp(0, 1),
            ),
          ),
        ),
      ),
    };
  }
}

class _ThoughtBubble extends StatelessWidget {
  const _ThoughtBubble();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 57,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 76,
            height: 39,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE1E7E7), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [_Dot(), _Dot(), _Dot()],
            ),
          ),
          const Positioned(left: 17, top: 39, child: _BubbleTail(size: 10)),
          const Positioned(left: 10, top: 51, child: _BubbleTail(size: 6)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(color: Color(0xFF263838), shape: BoxShape.circle),
    child: SizedBox.square(dimension: 5),
  );
}

class _BubbleTail extends StatelessWidget {
  const _BubbleTail({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFE1E7E7)),
    ),
  );
}

class _IdeaBulb extends StatelessWidget {
  const _IdeaBulb();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 72,
    child: CustomPaint(
      key: const ValueKey('numi-idea-bulb'),
      painter: _IdeaBulbPainter(),
    ),
  );
}

class _IdeaBulbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rayPaint = Paint()
      ..color = const Color(0xFFFFC336)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final center = size.center(Offset.zero) - const Offset(0, 7);
    for (var index = 0; index < 8; index++) {
      final angle = (math.pi * 2 / 8) * index;
      final start = center + Offset(math.cos(angle), math.sin(angle)) * 24;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * 31;
      canvas.drawLine(start, end, rayPaint);
    }

    canvas.drawCircle(
      center,
      15,
      Paint()
        ..color = const Color(0xFFFFC336)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 15, height: 19),
      0,
      math.pi,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(0, 19),
          width: 17,
          height: 10,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.teal700,
    );
    canvas.drawLine(
      center + const Offset(-6, 25),
      center + const Offset(6, 25),
      Paint()
        ..color = const Color(0xFF006F70)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MotionLinesPainter extends CustomPainter {
  const _MotionLinesPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9DB6B6).withValues(alpha: opacity * 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final left = Path()
      ..moveTo(18, 164)
      ..quadraticBezierTo(7, 172, 17, 181)
      ..moveTo(26, 172)
      ..quadraticBezierTo(18, 180, 27, 187);
    final right = Path()
      ..moveTo(size.width - 18, 164)
      ..quadraticBezierTo(size.width - 7, 172, size.width - 17, 181)
      ..moveTo(size.width - 26, 172)
      ..quadraticBezierTo(size.width - 18, 180, size.width - 27, 187);
    canvas
      ..drawPath(left, paint)
      ..drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant _MotionLinesPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
