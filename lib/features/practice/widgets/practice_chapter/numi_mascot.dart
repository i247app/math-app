part of '../../screens/practice_chapter_screen.dart';

class _NumiMascot extends StatelessWidget {
  const _NumiMascot({required this.animation, required this.scale});

  final Animation<double> animation;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final lift = math.sin(animation.value * math.pi) * -10 * scale;
        final tilt = math.sin(animation.value * math.pi * 2) * 0.035;

        return Transform.translate(
          offset: Offset(0, lift),
          child: Transform.rotate(angle: tilt, child: child),
        );
      },
      child: SizedBox(
        width: 96 * scale,
        height: 96 * scale,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 5 * scale,
              child: Container(
                width: 58 * scale,
                height: 12 * scale,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Image.asset(
              'assets/images/welcome-numi-character.png',
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
