part of '../numi_farm_stage_screen.dart';

class _FarmStageCompleteDialog extends StatelessWidget {
  const _FarmStageCompleteDialog({
    required this.stars,
    required this.stage,
    required this.elapsed,
    required this.correctAnswers,
    required this.wrongAnswers,
  });

  final int stars;
  final int stage;
  final Duration elapsed;
  final int correctAnswers;
  final int wrongAnswers;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: Image.asset(
                'assets/images/welcome-numi-character.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.getText(AppKeys.gamesFarmCompleteTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _farmInk,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.formatText(AppKeys.gamesFarmCompleteMessage, {
                'stage': stage,
              }),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _farmMuted,
                fontSize: FontSize.normal,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FarmScoreChip(
                  icon: Icons.check_circle_rounded,
                  color: _farmLeaf,
                  label: context.getText(AppKeys.gamesFarmCorrectCount),
                  value: correctAnswers,
                ),
                const SizedBox(width: 10),
                _FarmScoreChip(
                  icon: Icons.cancel_rounded,
                  color: const Color(0xFFE53935),
                  label: context.getText(AppKeys.gamesFarmWrongCount),
                  value: wrongAnswers,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: _farmGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, color: _farmGreen, size: 20),
                  const SizedBox(width: 7),
                  Text(
                    '${context.getText(AppKeys.gamesFarmTime)} '
                    '${_formatElapsed(elapsed)}',
                    style: const TextStyle(
                      color: _farmInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star_rounded,
                    color: index < stars
                        ? const Color(0xFFFFC21C)
                        : const Color(0xFFE2E6E3),
                    size: 42,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: _farmGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                context.getText(AppKeys.gamesFarmBackToMap),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmScoreChip extends StatelessWidget {
  const _FarmScoreChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                '$label $value',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _farmInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
