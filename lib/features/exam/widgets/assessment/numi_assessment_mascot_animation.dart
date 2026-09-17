import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

part 'mascot/rig_painter.dart';
part 'mascot/rig_pose.dart';
part 'mascot/decorations.dart';

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
