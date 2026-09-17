part of '../monster_rescue_stage_screen.dart';

class _MissionHeader extends StatelessWidget {
  const _MissionHeader({
    required this.creatureAsset,
    required this.creatureName,
    required this.teamSize,
    required this.stars,
    required this.progress,
    required this.onBack,
  });

  final String creatureAsset;
  final String creatureName;
  final int teamSize;
  final int stars;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 12),
      decoration: const BoxDecoration(
        color: _rescuePaper,
        boxShadow: [BoxShadow(color: Color(0x1B264B43), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  creatureAsset,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.getText(AppKeys.gamesRescueTitle),
                      style: const TextStyle(
                        color: _rescueTeal,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      creatureName,
                      style: const TextStyle(
                        color: _rescueInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(emoji: '⭐', value: '$stars'),
              const SizedBox(width: 7),
              _StatusPill(emoji: '🐾', value: '$teamSize'),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              color: _rescueCoral,
              backgroundColor: _rescueInk.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.emoji, required this.value});

  final String emoji;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _rescueMint,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$emoji $value',
        style: const TextStyle(
          color: _rescueInk,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MissionPrompt extends StatelessWidget {
  const _MissionPrompt({
    required this.eyebrow,
    required this.title,
    required this.message,
  });

  final String eyebrow;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _rescueCoral,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _rescueInk,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _rescueInk.withValues(alpha: 0.68),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
