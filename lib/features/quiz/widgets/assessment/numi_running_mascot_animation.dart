import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Native Flutter cutout-rig animation of Numi running sideways.
///
/// The branded body, glasses, eye, and wing pixels are sampled from the
/// original mascot asset, while the 12-frame reference is modeled as a smooth
/// procedural run cycle with:
/// - 2-step harmonic leg kinematics with stride, push-off, and recovery phases.
/// - Dynamic vertical body bounce, squash & stretch, and forward lean.
/// - Wing/arm pumping and trailing feather deformation.
/// - Floor shadow scaling with height.
/// - Dynamic trailing wind/speed lines.
class NumiRunningMascotAnimation extends StatefulWidget {
  const NumiRunningMascotAnimation({
    super.key,
    this.width = 240,
    this.height = 210,
    this.cycleDuration = const Duration(milliseconds: 650),
    this.isRunning = true,
    this.showSpeedLines = true,
    this.showShadow = true,
  });

  /// The width of the animation canvas.
  final double width;

  /// The height of the animation canvas.
  final double height;

  /// Time taken to complete one full 2-step running cycle (both feet).
  final Duration cycleDuration;

  /// Whether the animation is currently active.
  final bool isRunning;

  /// Whether to render the speed/wind trails behind Numi.
  final bool showSpeedLines;

  /// Whether to render the ground contact shadow.
  final bool showShadow;

  @override
  State<NumiRunningMascotAnimation> createState() =>
      _NumiRunningMascotAnimationState();
}

class _NumiRunningMascotAnimationState extends State<NumiRunningMascotAnimation>
    with SingleTickerProviderStateMixin {
  static const _sourceAsset = 'assets/images/numi-mascot.png';

  late final AnimationController _controller;
  ui.Image? _atlas;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    );
    if (widget.isRunning) {
      _controller.repeat();
    }
    _loadAtlas();
  }

  Future<void> _loadAtlas() async {
    final data = await rootBundle.load(_sourceAsset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() => _atlas = frame.image);
  }

  @override
  void didUpdateWidget(covariant NumiRunningMascotAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cycleDuration != widget.cycleDuration) {
      _controller.duration = widget.cycleDuration;
      if (_controller.isAnimating) {
        _controller.repeat();
      }
    }
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.25;
    } else if (widget.isRunning && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _atlas?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Numi Running Mascot',
      image: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final atlas = _atlas;
              if (atlas == null) {
                return Image.asset(
                  _sourceAsset,
                  key: const ValueKey('numi-running-loading-fallback'),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                );
              }
              return CustomPaint(
                painter: _NumiRunningPainter(
                  atlas: atlas,
                  progress: _controller.value,
                  showSpeedLines: widget.showSpeedLines,
                  showShadow: widget.showShadow,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Canvas painter responsible for drawing all vector layers of Numi running.
class _NumiRunningPainter extends CustomPainter {
  const _NumiRunningPainter({
    required this.atlas,
    required this.progress,
    required this.showSpeedLines,
    required this.showShadow,
  });

  final ui.Image atlas;
  final double progress;
  final bool showSpeedLines;
  final bool showShadow;

  static const _rigSize = Size(400, 350);

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

    final pose = _RunningPose.evaluate(progress);

    // 1. Trailing speed lines
    if (showSpeedLines) {
      _drawSpeedLines(canvas, pose);
    }

    // 2. Ground Shadow
    if (showShadow) {
      _drawShadow(canvas, pose);
    }

    // 3. Far leg (chân phía sau)
    _drawLeg(
      canvas,
      pose.farLeg,
      isFarLeg: true,
      bodyOffset: Offset(0, pose.bodyBounceY),
    );

    // 4. Far wing tip (optional subtle back-wing peek)
    if (pose.farWingVisibility > 0.01) {
      _drawFarWing(canvas, pose);
    }

    // 5. Main Body with forward lean and bounce
    canvas.save();
    canvas.translate(0, pose.bodyBounceY);

    // Body rotation pivot (around center of gravity)
    const bodyCenter = Offset(215, 175);
    canvas
      ..translate(bodyCenter.dx, bodyCenter.dy)
      ..rotate(pose.bodyLeanAngle)
      ..scale(pose.bodyScaleX, pose.bodyScaleY)
      ..translate(-bodyCenter.dx, -bodyCenter.dy);

    _drawBody(canvas);
    _drawOrangeVisor(canvas);
    _drawBeak(canvas);

    canvas.restore();

    // 6. Near leg (chân phía trước)
    _drawLeg(
      canvas,
      pose.nearLeg,
      isFarLeg: false,
      bodyOffset: Offset(0, pose.bodyBounceY),
    );

    // 7. Near wing (cánh chính vung tay / quạt gió)
    canvas.save();
    canvas.translate(0, pose.bodyBounceY);
    _drawNearWing(canvas, pose);
    canvas.restore();

    canvas.restore();
  }

  // --- DRAWING COMPONENTS ---

  void _drawShadow(Canvas canvas, _RunningPose pose) {
    const shadowCenter = Offset(215, 305);
    final widthFactor = (1.0 - (pose.altitude * 0.35)).clamp(0.5, 1.1);
    final alpha = (0.24 * (1.0 - (pose.altitude * 0.45))).clamp(0.08, 0.28);

    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: 145 * widthFactor,
        height: 18 * widthFactor,
      ),
      Paint()
        ..color = Color.fromRGBO(0, 36, 36, alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
  }

  void _drawBody(Canvas canvas) {
    final body = Path()
      ..addOval(
        Rect.fromCenter(
          center: const Offset(213, 176),
          width: 158,
          height: 151,
        ),
      );

    // Keep the official mascot's shaded material instead of approximating it
    // with a hand-authored radial gradient.
    _drawAtlasCutout(
      canvas,
      mask: body,
      source: const Rect.fromLTWH(190, 600, 620, 210),
      destination: const Rect.fromLTWH(133, 100, 160, 154),
    );
  }

  void _drawOrangeVisor(Canvas canvas) {
    // Mirror the original right glasses half into Numi's running side profile.
    final visorPath = Path()
      ..moveTo(224, 82)
      ..lineTo(251, 70)
      ..lineTo(301, 157)
      ..lineTo(221, 207)
      ..close();

    _drawAtlasCutout(
      canvas,
      mask: visorPath,
      source: const Rect.fromLTWH(500, 130, 410, 500),
      destination: const Rect.fromLTWH(216, 69, 91, 151),
      mirrorX: true,
    );
  }

  void _drawBeak(Canvas canvas) {
    final upper = Path()
      ..moveTo(292, 145)
      ..lineTo(316, 160)
      ..lineTo(289, 163)
      ..close();
    final lower = Path()
      ..moveTo(289, 163)
      ..lineTo(316, 160)
      ..lineTo(296, 177)
      ..close();

    canvas
      ..drawPath(
        upper,
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(291, 145),
            const Offset(315, 164),
            const [Color(0xFFFFC542), Color(0xFFFF9F05)],
          ),
      )
      ..drawPath(
        lower,
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(289, 161),
            const Offset(307, 177),
            const [Color(0xFFFFA514), Color(0xFFE77B00)],
          ),
      );
  }

  Rect _atlasSource(Rect normalized) {
    final scaleX = atlas.width / 1000;
    final scaleY = atlas.height / 1000;
    return Rect.fromLTRB(
      normalized.left * scaleX,
      normalized.top * scaleY,
      normalized.right * scaleX,
      normalized.bottom * scaleY,
    );
  }

  void _drawAtlasCutout(
    Canvas canvas, {
    required Path mask,
    required Rect source,
    required Rect destination,
    bool mirrorX = false,
    double opacity = 1,
  }) {
    canvas
      ..save()
      ..clipPath(mask);
    if (mirrorX) {
      canvas
        ..translate(destination.left + destination.right, 0)
        ..scale(-1, 1);
    }
    canvas.drawImageRect(
      atlas,
      _atlasSource(source),
      destination,
      Paint()
        ..color = Colors.white.withValues(alpha: opacity.clamp(0, 1))
        ..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  void _drawNearWing(Canvas canvas, _RunningPose pose) {
    final wing = pose.nearWing;
    const shoulder = Offset(175, 175);

    canvas
      ..save()
      ..translate(shoulder.dx, shoulder.dy)
      ..rotate(wing.angle)
      ..translate(-shoulder.dx, -shoulder.dy);

    final wingPath = Path();

    if (wing.isPumpingForward) {
      // Bent arm/wing pumping forward (as in frames 2, 6, 12)
      wingPath
        ..moveTo(175, 165)
        ..cubicTo(205, 160, 238, 175, 248, 198) // Forearm forward
        ..cubicTo(242, 218, 222, 222, 198, 212) // Hand/wing tuck
        ..cubicTo(175, 202, 160, 185, 175, 165)
        ..close();
    } else {
      // Trailing wing with feather ridges (frames 1, 3, 4, 5, etc.)
      wingPath
        ..moveTo(180, 165)
        ..cubicTo(145, 155, 110, 172, 90, 192) // Top curve trailing back
        ..cubicTo(82, 206, 92, 218, 115, 212) // Outer feather 1
        ..cubicTo(105, 225, 120, 230, 138, 220) // Middle feather 2
        ..cubicTo(135, 234, 152, 234, 172, 218) // Bottom feather 3
        ..cubicTo(188, 204, 190, 185, 180, 165)
        ..close();
    }

    _drawAtlasCutout(
      canvas,
      mask: wingPath,
      source: const Rect.fromLTWH(135, 565, 180, 225),
      destination: wing.isPumpingForward
          ? const Rect.fromLTWH(158, 150, 98, 78)
          : const Rect.fromLTWH(82, 151, 112, 88),
      mirrorX: wing.isPumpingForward,
    );
    canvas.restore();
  }

  void _drawFarWing(Canvas canvas, _RunningPose pose) {
    const shoulder = Offset(215, 165);
    final wing = pose.farWing;

    canvas
      ..save()
      ..translate(shoulder.dx, shoulder.dy)
      ..rotate(wing.angle)
      ..translate(-shoulder.dx, -shoulder.dy);

    final farWingPath = Path()
      ..moveTo(225, 155)
      ..cubicTo(248, 142, 272, 150, 285, 168)
      ..cubicTo(280, 182, 260, 185, 240, 178)
      ..cubicTo(230, 172, 222, 162, 225, 155)
      ..close();

    _drawAtlasCutout(
      canvas,
      mask: farWingPath,
      source: const Rect.fromLTWH(685, 565, 180, 225),
      destination: const Rect.fromLTWH(218, 143, 74, 48),
      opacity: pose.farWingVisibility,
    );
    canvas.restore();
  }

  void _drawLeg(
    Canvas canvas,
    _LegPose leg, {
    required bool isFarLeg,
    required Offset bodyOffset,
  }) {
    final hip =
        (isFarLeg ? const Offset(195, 230) : const Offset(228, 238)) +
        bodyOffset;

    const thighLength = 28.0;
    const shinLength = 26.0;

    // Forward kinematics: Hip -> Knee -> Ankle -> Toe
    final knee =
        hip +
        Offset(
          math.sin(leg.thighAngle) * thighLength,
          math.cos(leg.thighAngle) * thighLength,
        );

    final ankle =
        knee +
        Offset(
          math.sin(leg.thighAngle + leg.kneeBend) * shinLength,
          math.cos(leg.thighAngle + leg.kneeBend) * shinLength,
        );

    final legColor = isFarLeg
        ? const Color(0xFF00565A)
        : const Color(0xFF007B80);

    final legStrokePaint = Paint()
      ..color = legColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw thigh & shin bones
    final legPath = Path()
      ..moveTo(hip.dx, hip.dy)
      ..lineTo(knee.dx, knee.dy)
      ..lineTo(ankle.dx, ankle.dy);

    canvas.drawPath(legPath, legStrokePaint);

    // Draw foot / shoe pointing right
    canvas.save();
    canvas.translate(ankle.dx, ankle.dy);
    canvas.rotate(leg.footAngle);

    final footPath = Path()
      ..moveTo(-6, -4)
      ..lineTo(22, -4)
      ..cubicTo(28, -4, 28, 7, 20, 7)
      ..lineTo(-6, 7)
      ..close();

    final footPaint = Paint()
      ..color = isFarLeg ? const Color(0xFF00494D) : const Color(0xFF006F74)
      ..style = PaintingStyle.fill;

    canvas.drawPath(footPath, footPaint);
    canvas.restore();
  }

  void _drawSpeedLines(Canvas canvas, _RunningPose pose) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final lineDefs = [
      (y: 155.0, phaseOffset: 0.0, baseLen: 38.0),
      (y: 175.0, phaseOffset: 0.33, baseLen: 50.0),
      (y: 195.0, phaseOffset: 0.67, baseLen: 42.0),
    ];

    for (final def in lineDefs) {
      final linePhase = (progress * 2.5 + def.phaseOffset) % 1.0;
      final startX = 110.0 - (linePhase * 80.0);
      final len = def.baseLen * (1.0 - (linePhase * 0.4));
      final opacity = math.sin(linePhase * math.pi).clamp(0.0, 1.0) * 0.65;

      paint.color = const Color(0xFF88C9CB).withValues(alpha: opacity);
      canvas.drawLine(
        Offset(startX - len, def.y + pose.bodyBounceY * 0.4),
        Offset(startX, def.y + pose.bodyBounceY * 0.4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NumiRunningPainter oldDelegate) =>
      oldDelegate.atlas != atlas ||
      oldDelegate.progress != progress ||
      oldDelegate.showSpeedLines != showSpeedLines ||
      oldDelegate.showShadow != showShadow;
}

// --- KINEMATICS & POSE CALCULATIONS ---

class _LegPose {
  const _LegPose({
    required this.thighAngle,
    required this.kneeBend,
    required this.footAngle,
  });

  final double thighAngle;
  final double kneeBend;
  final double footAngle;
}

class _WingPose {
  const _WingPose({required this.angle, required this.isPumpingForward});

  final double angle;
  final bool isPumpingForward;
}

class _RunningPose {
  const _RunningPose({
    required this.bodyBounceY,
    required this.bodyLeanAngle,
    required this.bodyScaleX,
    required this.bodyScaleY,
    required this.altitude,
    required this.nearLeg,
    required this.farLeg,
    required this.nearWing,
    required this.farWing,
    required this.farWingVisibility,
  });

  final double bodyBounceY;
  final double bodyLeanAngle;
  final double bodyScaleX;
  final double bodyScaleY;
  final double altitude;
  final _LegPose nearLeg;
  final _LegPose farLeg;
  final _WingPose nearWing;
  final _WingPose farWing;
  final double farWingVisibility;

  /// Evaluates full kinematic running rig for a cycle progress [t] in [0, 1].
  static _RunningPose evaluate(double t) {
    // 2 strides per full cycle (Left foot stride, Right foot stride)
    final double bouncePhase = (t * math.pi * 4.0);

    // Body vertical bounce (Double bounce per full run cycle)
    // Lowest point at foot-strike, highest point at flight peak
    final double bounceSin = math.sin(bouncePhase);
    final double bodyBounceY =
        -14.0 * (bounceSin > 0 ? bounceSin : 0.0) +
        3.0 * (bounceSin < 0 ? -bounceSin : 0.0);

    final double altitude = (bodyBounceY.abs() / 14.0).clamp(0.0, 1.0);

    // Dynamic squash & stretch
    final double bodyScaleX = 1.0 + (0.04 * math.cos(bouncePhase));
    final double bodyScaleY = 1.0 - (0.04 * math.cos(bouncePhase));

    // Forward lean with rhythmic tilt
    final double bodyLeanAngle = 0.12 + (0.03 * math.sin(bouncePhase));

    // Calculate leg kinematics for near & far legs (180 degree / 0.5 phase shift)
    final nearLeg = _evaluateLeg(t);
    final farLeg = _evaluateLeg((t + 0.5) % 1.0);

    // Wing kinematics: pumps forward during stride transitions
    final nearWing = _evaluateWing(t);
    final farWing = _evaluateWing((t + 0.5) % 1.0);

    final farWingVis = (math.sin(t * math.pi * 2.0) > 0.3) ? 0.7 : 0.0;

    return _RunningPose(
      bodyBounceY: bodyBounceY,
      bodyLeanAngle: bodyLeanAngle,
      bodyScaleX: bodyScaleX,
      bodyScaleY: bodyScaleY,
      altitude: altitude,
      nearLeg: nearLeg,
      farLeg: farLeg,
      nearWing: nearWing,
      farWing: farWing,
      farWingVisibility: farWingVis,
    );
  }

  static _LegPose _evaluateLeg(double phase) {
    final p = phase % 1.0;
    double thighAngle;
    double kneeBend;
    double footAngle;

    if (p < 0.25) {
      // 1. Foot strike & Ground contact drive (đạp đất đẩy người)
      final k = p / 0.25;
      thighAngle = _lerp(0.45, -0.55, k);
      kneeBend = _lerp(0.20, 0.05, k);
      footAngle = _lerp(-0.15, 0.45, k);
    } else if (p < 0.50) {
      // 2. Push-off & High back trail (chân vung cao ra sau)
      final k = (p - 0.25) / 0.25;
      thighAngle = _lerp(-0.55, -0.85, k);
      kneeBend = _lerp(0.05, 1.25, k);
      footAngle = _lerp(0.45, 0.85, k);
    } else if (p < 0.75) {
      // 3. Recovery swing (thu chân về trước, gập gối cao)
      final k = (p - 0.50) / 0.25;
      thighAngle = _lerp(-0.85, 0.65, k);
      kneeBend = _lerp(1.25, 1.40, k);
      footAngle = _lerp(0.85, -0.20, k);
    } else {
      // 4. Forward extension (duỗi chân chuẩn bị chạm đất)
      final k = (p - 0.75) / 0.25;
      thighAngle = _lerp(0.65, 0.45, k);
      kneeBend = _lerp(1.40, 0.20, k);
      footAngle = _lerp(-0.20, -0.15, k);
    }

    return _LegPose(
      thighAngle: thighAngle,
      kneeBend: kneeBend,
      footAngle: footAngle,
    );
  }

  static _WingPose _evaluateWing(double phase) {
    final p = phase % 1.0;
    // Wing pumps forward during the forward-swing stride phase
    final bool isPumping = (p > 0.08 && p < 0.32) || (p > 0.88);
    final double angle = isPumping
        ? math.sin(p * math.pi * 4.0) * 0.18
        : -0.15 + (math.sin(p * math.pi * 2.0) * 0.32);

    return _WingPose(angle: angle, isPumpingForward: isPumping);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
