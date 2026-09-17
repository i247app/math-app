part of '../numi_farm_stage_screen.dart';

class _FarmHeader extends StatelessWidget {
  const _FarmHeader({
    required this.round,
    required this.roundCount,
    required this.progress,
    required this.stageTitleKey,
    required this.elapsed,
    required this.onBack,
  });

  final int round;
  final int roundCount;
  final double progress;
  final String stageTitleKey;
  final Duration elapsed;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: _farmDeepGreen.withValues(alpha: 0.16),
              child: InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(Icons.arrow_back_rounded, color: _farmDeepGreen),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.getText(AppKeys.gamesFarmTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _farmInk,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    context.getText(stageTitleKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _farmMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            _FarmTimerChip(elapsed: elapsed),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: _farmGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$round/$roundCount',
                style: const TextStyle(
                  color: _farmDeepGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: _farmGreen.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation(_farmGreen),
          ),
        ),
      ],
    );
  }
}

class _FarmTimerChip extends StatelessWidget {
  const _FarmTimerChip({required this.elapsed});

  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _farmGreen.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: _farmGreen, size: 16),
          const SizedBox(width: 4),
          Text(
            _formatElapsed(elapsed),
            style: const TextStyle(
              color: _farmInk,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmOrderCard extends StatelessWidget {
  const _FarmOrderCard({
    required this.target,
    required this.feedbackTick,
    required this.isSolved,
    required this.isWrong,
    required this.compact,
  });

  final int target;
  final int feedbackTick;
  final bool isSolved;
  final bool isWrong;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(feedbackTick),
      tween: Tween(begin: feedbackTick == 0 ? 0 : 1, end: 0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(math.sin(value * math.pi * 5) * 7 * value, 0),
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.fromLTRB(
          14,
          compact ? 10 : 14,
          18,
          compact ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: isSolved
              ? const Color(0xFFE7F7DF)
              : isWrong
              ? const Color(0xFFFFEEEE)
              : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSolved
                ? _farmLeaf.withValues(alpha: 0.45)
                : isWrong
                ? const Color(0xFFE53935)
                : _farmGreen.withValues(alpha: 0.10),
            width: isWrong ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _farmDeepGreen.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: compact ? 62 : 76,
              height: compact ? 62 : 76,
              child: Image.asset(
                'assets/images/welcome-numi-character.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSolved
                        ? context.getText(AppKeys.gamesFarmCorrect)
                        : isWrong
                        ? context.getText(AppKeys.gamesFarmIncorrect)
                        : context.getText(AppKeys.gamesFarmOrderLabel),
                    style: TextStyle(
                      color: isSolved ? _farmDeepGreen : _farmMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: isSolved
                              ? context.getText(AppKeys.gamesFarmBasketReady)
                              : context.getText(AppKeys.gamesFarmHarvestPrefix),
                        ),
                        if (!isSolved)
                          TextSpan(
                            text: ' $target ',
                            style: const TextStyle(
                              color: _farmOrange,
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        if (!isSolved)
                          TextSpan(
                            text: context.getText(
                              AppKeys.gamesFarmHarvestSuffix,
                            ),
                          ),
                      ],
                    ),
                    style: const TextStyle(
                      color: _farmInk,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
