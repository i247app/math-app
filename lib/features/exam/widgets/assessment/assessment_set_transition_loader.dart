import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

enum AssessmentSetTransitionKind { downGrade, stayGrade, grow, trophy }

/// Encouragement matched to the next assessment set's grade change.
class AssessmentSetTransitionLoader extends StatefulWidget {
  const AssessmentSetTransitionLoader({super.key, required this.kind});

  final AssessmentSetTransitionKind kind;

  static Color backgroundColorOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF252525)
      : const Color(0xFFF2F2F2);

  @override
  State<AssessmentSetTransitionLoader> createState() =>
      _AssessmentSetTransitionLoaderState();
}

class _AssessmentSetTransitionLoaderState
    extends State<AssessmentSetTransitionLoader>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _textController;
  late final Animation<double> _artOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    final isDownGrade = widget.kind == AssessmentSetTransitionKind.downGrade;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: isDownGrade ? 2600 : 1800),
    );
    _textController = AnimationController(
      vsync: this,
      duration: _controller.duration,
    );
    // Fade the artwork around the loop boundary to soften its restart.
    _artOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 10),
    ]).animate(_controller);
    final textCurve = CurvedAnimation(
      parent: _textController,
      curve: isDownGrade
          ? const Interval(0.72, 0.97, curve: Curves.easeOut)
          : const Interval(0.5, 0.86, curve: Curves.easeOut),
    );
    _textOpacity = textCurve;
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(textCurve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _textController.stop();
      _controller.value = 1;
      _textController.value = 1;
    } else {
      if (!_controller.isAnimating) {
        _controller.value = 0;
        _controller.repeat();
      }
      _textController.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = AssessmentSetTransitionLoader.backgroundColorOf(context);
    final blobColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE6E6E6);
    final (artKey, artLabel, title, subtitle) = switch (widget.kind) {
      AssessmentSetTransitionKind.downGrade => (
        'set-transition-stepping-stones',
        'A small dot stepping forward across three stones',
        'One step at a time.',
        'You’ve got this.',
      ),
      AssessmentSetTransitionKind.stayGrade => (
        'set-transition-puzzle',
        'Two puzzle pieces fitting together',
        'That was a bit tricky, right?',
        'Let’s try another one.',
      ),
      AssessmentSetTransitionKind.grow => (
        'set-transition-sprout',
        'A sprout opening its leaves',
        'Every try helps you grow.',
        'Let’s keep going.',
      ),
      AssessmentSetTransitionKind.trophy => (
        'grade-up-trophy',
        'Gold trophy',
        'You are doing good',
        null,
      ),
    };
    final painter = switch (widget.kind) {
      AssessmentSetTransitionKind.downGrade => _SteppingStonesPainter(
        animation: _controller,
        blobColor: blobColor,
        isDark: isDark,
      ),
      AssessmentSetTransitionKind.stayGrade => _PuzzlePainter(
        animation: _controller,
        blobColor: blobColor,
        isDark: isDark,
      ),
      AssessmentSetTransitionKind.grow => _SproutPainter(
        animation: _controller,
        blobColor: blobColor,
        isDark: isDark,
      ),
      AssessmentSetTransitionKind.trophy => _TrophyPainter(
        animation: _controller,
        blobColor: blobColor,
      ),
    };
    return ColoredBox(
      color: background,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 360,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: artLabel,
                    image: true,
                    child: FadeTransition(
                      key: const ValueKey('set-transition-art-fade'),
                      opacity: MediaQuery.disableAnimationsOf(context)
                          ? const AlwaysStoppedAnimation(1.0)
                          : _artOpacity,
                      child: RepaintBoundary(
                        child: CustomPaint(
                          key: ValueKey(artKey),
                          size: const Size(190, 148),
                          painter: painter,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    key: const ValueKey('set-transition-message'),
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text.rich(
                            widget.kind == AssessmentSetTransitionKind.trophy
                                ? TextSpan(
                                    children: [
                                      const TextSpan(text: 'You are '),
                                      TextSpan(
                                        text: 'doing good',
                                        style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFFFFCF65)
                                              : const Color(0xFF956600),
                                        ),
                                      ),
                                    ],
                                  )
                                : TextSpan(text: title),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: FontSize.xxl,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              letterSpacing: -0.65,
                              color: context.themeColors.textPrimary,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: FontSize.small,
                                height: 1.4,
                                color: context.themeColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract class _GrowthPainter extends CustomPainter {
  _GrowthPainter({
    required this.animation,
    required this.blobColor,
    required this.isDark,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color blobColor;
  final bool isDark;
  Color get teal => isDark ? const Color(0xFF83C4BC) : const Color(0xFF65A9A1);
  Color get softTeal =>
      isDark ? const Color(0xFF659F96) : const Color(0xFF9BC7C0);

  double phase(double start, double end) => Curves.easeOut.transform(
    ((animation.value - start) / (end - start)).clamp(0, 1),
  );

  void paintBackdrop(Canvas canvas, Size size) {
    canvas.scale(size.width / 190, size.height / 148);
    canvas.drawPath(
      Path()
        ..moveTo(101, 10)
        ..cubicTo(128, 3, 148, 24, 160, 53)
        ..cubicTo(177, 87, 164, 118, 131, 132)
        ..cubicTo(99, 145, 48, 135, 32, 111)
        ..cubicTo(11, 76, 35, 38, 66, 23)
        ..cubicTo(78, 17, 90, 13, 101, 10)
        ..close(),
      Paint()..color = blobColor,
    );
  }

  @override
  bool shouldRepaint(covariant _GrowthPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.blobColor != blobColor ||
      oldDelegate.isDark != isDark;
}

class _SteppingStonesPainter extends _GrowthPainter {
  _SteppingStonesPainter({
    required super.animation,
    required super.blobColor,
    required super.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    paintBackdrop(canvas, size);
    final stonePaint = Paint()
      ..color = isDark ? const Color(0xFF637F76) : const Color(0xFFB0C4BF);
    for (final left in [21.0, 74.0, 127.0]) {
      canvas.drawOval(Rect.fromLTWH(left, 105, 42, 13), stonePaint);
    }

    final progress = (animation.value / 0.8).clamp(0.0, 1.0);
    // Pause briefly on each stone, then make two gentle forward hops.
    final double x;
    final double lift;
    if (progress <= 0.1) {
      x = 42;
      lift = 0;
    } else if (progress < 0.45) {
      final hop = Curves.easeInOut.transform((progress - 0.1) / 0.35);
      x = 42 + 53 * hop;
      lift = 22 * math.sin(math.pi * hop);
    } else if (progress <= 0.55) {
      x = 95;
      lift = 0;
    } else if (progress < 0.9) {
      final hop = Curves.easeInOut.transform((progress - 0.55) / 0.35);
      x = 95 + 53 * hop;
      lift = 22 * math.sin(math.pi * hop);
    } else {
      x = 148;
      lift = 0;
    }
    canvas.drawCircle(Offset(x, 95 - lift), 10, Paint()..color = teal);
    canvas.restore();
  }
}

class _PuzzlePainter extends _GrowthPainter {
  _PuzzlePainter({
    required super.animation,
    required super.blobColor,
    required super.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    paintBackdrop(canvas, size);
    final progress = Curves.easeInOut.transform(
      (animation.value / 0.72).clamp(0, 1),
    );
    // The pieces test a small angle, then settle into the matching position.
    final searching = progress < 0.42;
    final t = searching ? progress / 0.42 : (progress - 0.42) / 0.58;
    final leftX = searching ? -15 + 6 * t : -9 + 9 * t;
    final leftY = searching ? 5 - 8 * t : -3 + 3 * t;
    final leftAngle = searching ? -12 + 19 * t : 7 - 7 * t;
    final rightX = searching ? 18 - 6 * t : 12 - 12 * t;
    final rightAngle = searching ? 8 - 11 * t : -3 + 3 * t;

    canvas.save();
    canvas.translate(122 + rightX, 78.5);
    canvas.rotate(rightAngle * math.pi / 180);
    canvas.translate(-122, -78.5);
    final rightPiece = Path.combine(
      PathOperation.difference,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(96, 51, 52, 55),
          const Radius.circular(8),
        ),
      ),
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(96, 79), radius: 11)),
    );
    canvas.drawPath(rightPiece, Paint()..color = softTeal);
    canvas.restore();

    canvas.save();
    canvas.translate(68 + leftX, 78.5 + leftY);
    canvas.rotate(leftAngle * math.pi / 180);
    canvas.translate(-68, -78.5);
    final leftPaint = Paint()..color = teal;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(42, 51, 52, 55),
        const Radius.circular(8),
      ),
      leftPaint,
    );
    canvas.drawCircle(const Offset(94, 79), 10, leftPaint);
    canvas.restore();
    canvas.restore();
  }
}

class _SproutPainter extends _GrowthPainter {
  _SproutPainter({
    required super.animation,
    required super.blobColor,
    required super.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    paintBackdrop(canvas, size);
    canvas.drawOval(
      const Rect.fromLTWH(66, 119, 58, 7),
      Paint()
        ..color = isDark ? const Color(0xFF505853) : const Color(0xFFC8CECA),
    );
    canvas.save();
    canvas.translate(95, 121);
    canvas.scale(1, 0.35 + 0.65 * phase(0, 0.6));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-2, -56, 4, 56),
        const Radius.circular(3),
      ),
      Paint()..color = teal,
    );
    canvas.restore();

    final leftProgress = phase(0.13, 0.65);
    canvas.save();
    canvas.translate(95, 99);
    canvas.rotate((52 - 29 * leftProgress) * math.pi / 180);
    canvas.scale(0.35 + 0.65 * leftProgress);
    canvas.translate(-42, -25);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(32, -1, 43, 9, 42, 25)
        ..cubicTo(10, 27, 0, 13, 0, 0)
        ..close(),
      Paint()..color = teal.withValues(alpha: 0.5 + 0.5 * leftProgress),
    );
    canvas.restore();

    final rightProgress = phase(0.24, 0.76);
    canvas.save();
    canvas.translate(95, 80);
    canvas.rotate((-42 + 24 * rightProgress) * math.pi / 180);
    canvas.scale(0.35 + 0.65 * rightProgress);
    canvas.translate(0, -25);
    canvas.drawPath(
      Path()
        ..moveTo(42, 0)
        ..cubicTo(42, 17, 30, 25, 0, 25)
        ..cubicTo(-1, 8, 15, 0, 42, 0)
        ..close(),
      Paint()..color = softTeal.withValues(alpha: 0.5 + 0.5 * rightProgress),
    );
    canvas.restore();
    canvas.restore();
  }
}

class _TrophyPainter extends CustomPainter {
  _TrophyPainter({required this.animation, required this.blobColor})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color blobColor;
  static const _gold = Color(0xFFF5C75B);
  static const _goldDeep = Color(0xFFDFA52D);
  static const _highlight = Color(0xFFFFF4CF);

  double _phase(double start, double end, Curve curve) =>
      curve.transform(((animation.value - start) / (end - start)).clamp(0, 1));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 190, size.height / 148);
    final blobOpacity = _phase(0, 0.47, Curves.easeOut);
    final blob = Path()
      ..moveTo(101, 10)
      ..cubicTo(128, 3, 148, 24, 160, 53)
      ..cubicTo(177, 87, 164, 118, 131, 132)
      ..cubicTo(99, 145, 48, 135, 32, 111)
      ..cubicTo(11, 76, 35, 38, 66, 23)
      ..cubicTo(78, 17, 90, 13, 101, 10)
      ..close();
    canvas.drawPath(
      blob,
      Paint()..color = blobColor.withValues(alpha: blobOpacity),
    );
    canvas.drawOval(
      const Rect.fromLTWH(66, 125, 58, 7),
      Paint()
        ..color = _goldDeep.withValues(alpha: 0.12 * blobOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final raysOpacity = _phase(0.27, 0.63, Curves.easeOut);
    final rayPaint = Paint()
      ..color = _goldDeep.withValues(alpha: 0.8 * raysOpacity)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final (start, end) in <(Offset, Offset)>[
      (const Offset(13, 53), const Offset(22, 61)),
      (const Offset(8, 78), const Offset(19, 74)),
      (const Offset(177, 53), const Offset(168, 61)),
      (const Offset(182, 78), const Offset(171, 74)),
    ]) {
      canvas.drawLine(start, end, rayPaint);
    }

    final cupOpacity = _phase(0, 0.3, Curves.easeOut);
    final cupScale = 0.65 + 0.35 * _phase(0, 0.5, Curves.easeOutBack);
    canvas.saveLayer(
      const Rect.fromLTWH(0, 0, 190, 148),
      Paint()..color = Colors.white.withValues(alpha: cupOpacity),
    );
    canvas.translate(95, 107);
    canvas.scale(cupScale);
    canvas.translate(-95, -107);

    final handlePaint = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(64, 43)
        ..lineTo(52, 43)
        ..quadraticBezierTo(47, 72, 69, 73),
      handlePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(126, 43)
        ..lineTo(138, 43)
        ..quadraticBezierTo(143, 72, 121, 73),
      handlePaint,
    );
    final basePaint = Paint()..color = _goldDeep;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(89, 85, 12, 29),
        const Radius.circular(3),
      ),
      basePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(73.5, 113, 43, 10),
        const Radius.circular(4),
      ),
      basePaint,
    );
    final bowl = Path()
      ..moveTo(68, 34)
      ..lineTo(122, 34)
      ..quadraticBezierTo(127, 34, 127, 39)
      ..lineTo(125, 63)
      ..cubicTo(123, 80, 111, 92, 95, 92)
      ..cubicTo(79, 92, 67, 80, 65, 63)
      ..lineTo(63, 39)
      ..quadraticBezierTo(63, 34, 68, 34)
      ..close();
    canvas.drawPath(
      bowl,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gold, _goldDeep],
        ).createShader(const Rect.fromLTWH(63, 34, 64, 58)),
    );
    // One soft glint passes across the cup before the message settles.
    if (animation.value > 0.36 && animation.value < 0.78) {
      final shineX = 38 + 105 * _phase(0.36, 0.78, Curves.easeInOut);
      canvas.save();
      canvas.clipPath(bowl);
      canvas.drawRect(
        Rect.fromLTWH(shineX, 25, 18, 85),
        Paint()
          ..shader = LinearGradient(
            colors: [
              _highlight.withValues(alpha: 0),
              _highlight.withValues(alpha: 0.3),
              _highlight.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(shineX, 25, 18, 85)),
      );
      canvas.restore();
    }
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final radius = i.isEven ? 13.0 : 5.6;
      final x = 95 + radius * math.cos(angle);
      final y = 62 + radius * math.sin(angle);
      if (i == 0) {
        star.moveTo(x, y);
      } else {
        star.lineTo(x, y);
      }
    }
    canvas.drawPath(star..close(), Paint()..color = _highlight);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TrophyPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.blobColor != blobColor;
}
