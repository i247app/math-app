import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';

/// The five-beat Numi sequence used while an assessment is being generated.
///
/// The neutral pose comes from the existing brand asset. The other poses live
/// in a single sprite sheet so the complete loop only adds one decoded image.
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

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycleDuration)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.68;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Numi',
      image: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: 270,
          height: 260,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final sequence = _MascotSequence.at(_controller.value);
              final transition = sequence.transition;
              final nextSequence = _MascotSequence(
                sequence.nextStage,
                transition,
              );
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  _AnimatedPose(
                    sequence: sequence,
                    opacity: 1 - transition,
                    transition: transition,
                  ),
                  if (transition > 0)
                    _AnimatedPose(
                      sequence: nextSequence,
                      opacity: transition,
                      transition: transition,
                      incoming: true,
                    ),
                  _StageDecoration(sequence: sequence, opacity: 1 - transition),
                  if (transition > 0)
                    _StageDecoration(
                      sequence: nextSequence,
                      opacity: transition,
                    ),
                ],
              );
            },
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

  _MascotStage get nextStage =>
      _MascotStage.values[(stage.index + 1) % _MascotStage.values.length];

  double get transition {
    const transitionStart = 0.56;
    final value = ((progress - transitionStart) / (1 - transitionStart)).clamp(
      0.0,
      1.0,
    );
    return Curves.easeInOutCubic.transform(value);
  }

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

class _AnimatedPose extends StatelessWidget {
  const _AnimatedPose({
    required this.sequence,
    required this.opacity,
    required this.transition,
    this.incoming = false,
  });

  final _MascotSequence sequence;
  final double opacity;
  final double transition;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOut.transform(sequence.progress);
    final wave = math.sin(t * math.pi);
    final double y;
    final double angle;
    final double scale;

    switch (sequence.stage) {
      case _MascotStage.neutral:
        y = -2 * wave;
        angle = 0;
        scale = 1;
      case _MascotStage.wondering:
        y = -3 * wave;
        angle = -0.025 * wave;
        scale = 1;
      case _MascotStage.thinking:
        y = -1.5 * wave;
        angle = 0;
        scale = 1 + (0.012 * wave);
      case _MascotStage.idea:
        y = -6 * wave;
        angle = 0.018 * math.sin(t * math.pi * 2);
        scale = 1 + (0.025 * wave);
      case _MascotStage.ready:
        y = -13 * wave;
        angle = 0.035 * math.sin(t * math.pi * 2);
        scale = 1 + (0.035 * wave);
    }

    final entryProgress = incoming ? transition : 1.0;
    final exitProgress = incoming ? 0.0 : transition;
    final entryLift = (1 - entryProgress) * 8;
    final entryAngle = incoming ? (1 - entryProgress) * 0.025 : 0.0;

    return IgnorePointer(
      child: Opacity(
        opacity: opacity.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, y + entryLift),
          child: Transform.rotate(
            angle: angle + entryAngle,
            child: Transform.scale(
              scaleX: scale * (1 + (0.025 * exitProgress)),
              scaleY:
                  scale *
                  (incoming
                      ? 0.96 + (0.04 * entryProgress)
                      : 1 - (0.025 * exitProgress)),
              alignment: Alignment.bottomCenter,
              child: sequence.stage == _MascotStage.neutral
                  ? Image.asset(
                      'assets/images/numi-mascot.png',
                      width: 202,
                      height: 188,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    )
                  : _SpritePose(frame: sequence.stage.index - 1),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpritePose extends StatelessWidget {
  const _SpritePose({required this.frame});

  static const _frameWidth = 210.0;
  static const _sheetWidth = _frameWidth * 4;
  static const _sheetHeight = 272.0;

  final int frame;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        key: ValueKey('numi-sprite-pose-$frame'),
        width: _frameWidth,
        height: 192,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: _sheetWidth,
          maxWidth: _sheetWidth,
          minHeight: _sheetHeight,
          maxHeight: _sheetHeight,
          child: Transform.translate(
            offset: Offset(-frame * _frameWidth, -34),
            child: Image.asset(
              'assets/images/numi-assessment-loading-sprite.png',
              width: _sheetWidth,
              height: _sheetHeight,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class _StageDecoration extends StatelessWidget {
  const _StageDecoration({required this.sequence, required this.opacity});

  final _MascotSequence sequence;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final reveal = Curves.easeOutBack.transform(
      math.min(sequence.progress / 0.36, 1),
    );

    return switch (sequence.stage) {
      _MascotStage.neutral => const SizedBox.shrink(),
      _MascotStage.wondering => Positioned(
        right: 30,
        top: 30,
        child: Opacity(
          opacity: opacity.clamp(0, 1),
          child: Transform.scale(
            scale: reveal,
            child: const Text(
              '?',
              style: TextStyle(
                color: AppColors.teal700,
                fontSize: 46,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
      _MascotStage.thinking => Positioned(
        top: 12,
        child: Opacity(
          opacity: math.min(sequence.progress / 0.25, 1) * opacity.clamp(0, 1),
          child: const _ThoughtBubble(),
        ),
      ),
      _MascotStage.idea => Positioned(
        left: 0,
        right: 0,
        top: -4,
        child: Opacity(
          opacity: opacity.clamp(0, 1),
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
              opacity:
                  math.sin(sequence.progress * math.pi).clamp(0, 1) *
                  opacity.clamp(0, 1),
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
              children: [_ThoughtDot(), _ThoughtDot(), _ThoughtDot()],
            ),
          ),
          const Positioned(left: 17, top: 39, child: _BubbleTail(size: 10)),
          const Positioned(left: 10, top: 51, child: _BubbleTail(size: 6)),
        ],
      ),
    );
  }
}

class _ThoughtDot extends StatelessWidget {
  const _ThoughtDot();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFF263838),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(dimension: 5),
    );
  }
}

class _BubbleTail extends StatelessWidget {
  const _BubbleTail({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE1E7E7)),
      ),
    );
  }
}

class _IdeaBulb extends StatelessWidget {
  const _IdeaBulb();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size.square(72), painter: _BulbRaysPainter()),
          const Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFFFFC336),
            size: 48,
            shadows: [Shadow(color: Color(0x33FFB300), blurRadius: 8)],
          ),
        ],
      ),
    );
  }
}

class _BulbRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC336)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final center = size.center(Offset.zero) - const Offset(0, 3);
    for (var index = 0; index < 8; index++) {
      final angle = (math.pi * 2 / 8) * index;
      final start = center + Offset(math.cos(angle), math.sin(angle)) * 27;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * 33;
      canvas.drawLine(start, end, paint);
    }
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
      ..moveTo(18, 148)
      ..quadraticBezierTo(7, 156, 17, 165)
      ..moveTo(26, 156)
      ..quadraticBezierTo(18, 164, 27, 171);
    final right = Path()
      ..moveTo(size.width - 18, 148)
      ..quadraticBezierTo(size.width - 7, 156, size.width - 17, 165)
      ..moveTo(size.width - 26, 156)
      ..quadraticBezierTo(size.width - 18, 164, size.width - 27, 171);
    canvas
      ..drawPath(left, paint)
      ..drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant _MotionLinesPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
