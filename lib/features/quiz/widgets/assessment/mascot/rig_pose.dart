part of '../numi_assessment_mascot_animation.dart';

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
