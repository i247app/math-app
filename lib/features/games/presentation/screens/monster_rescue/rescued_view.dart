part of '../monster_rescue_stage_screen.dart';

extension _MonsterRescueResultView on _MonsterRescueStageScreenState {
  Widget _buildRescued() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(_config.creatureAsset, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x16000000), Color(0xE50A3938)],
              stops: [0.45, 1],
            ),
          ),
        ),
        Positioned(
          left: 22,
          right: 22,
          bottom: 22,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(color: Color(0x55000000), blurRadius: 24),
              ],
            ),
            child: Column(
              children: [
                Text(
                  context.getText(AppKeys.gamesRescueCompleteTitle),
                  key: const ValueKey('rescue-complete-title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _rescueInk,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  context.formatText(AppKeys.gamesRescueCompleteMessage, {
                    'name': _config.creatureName,
                  }),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _rescueInk.withValues(alpha: 0.72),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(
                        index < _stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: _rescueYellow,
                        size: 31,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _rescueMint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 23)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.getText(AppKeys.gamesRescueSkillUnlocked),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _rescueTeal,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    key: const ValueKey('rescue-back-to-map'),
                    onPressed: () => _exitController.exitWithResult(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: _rescueCoral,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    icon: const Icon(Icons.home_rounded),
                    label: Text(
                      context.getText(AppKeys.gamesRescueBringHome),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
