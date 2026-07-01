part of '../../presentation/practice_chapter_screen.dart';

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.completed,
    required this.current,
    required this.locked,
    required this.scale,
  });

  final bool completed;
  final bool current;
  final bool locked;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? _completedGold
        : current
        ? _pathBlue
        : const Color(0xFFE5E8EB);
    final shadow = completed
        ? _completedGoldShadow
        : current
        ? _pathBlueShadow
        : const Color(0xFFBEC3C7);

    return Container(
      width: 82 * scale,
      height: 82 * scale,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: shadow, offset: Offset(0, 8 * scale))],
      ),
      alignment: Alignment.center,
      child: completed
          ? _BoldCheckIcon(size: 42 * scale)
          : Icon(
              current ? Icons.star_rounded : Icons.lock_rounded,
              color: locked ? _pathMuted : Colors.white,
              size: 34 * scale,
              weight: 900,
            ),
    );
  }
}
