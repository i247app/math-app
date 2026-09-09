part of '../numi_assessment_mascot_animation.dart';

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
