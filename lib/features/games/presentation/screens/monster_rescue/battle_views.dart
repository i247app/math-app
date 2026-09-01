part of '../monster_rescue_stage_screen.dart';

extension _MonsterRescueBattleViews on _MonsterRescueStageScreenState {
  Widget _buildBridge() {
    final ready = _bridgeAssigned == _config.bridgeTeam;
    final crossing = _teamSize - _bridgeAssigned;
    return SingleChildScrollView(
      key: const ValueKey('rescue-bridge'),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      child: Column(
        children: [
          _MissionPrompt(
            eyebrow: context.getText(AppKeys.gamesRescueTeamChallenge),
            title: context.getText(AppKeys.gamesRescueBridgeTitle),
            message: context.formatText(AppKeys.gamesRescueBridgeHint, {
              'count': _config.bridgeTeam,
            }),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _rescuePaper,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: ready ? _rescueTeal : const Color(0xFFE4DCC5),
                width: ready ? 3 : 2,
              ),
            ),
            child: Column(
              children: [
                const Text('🌉', style: TextStyle(fontSize: 67)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TeamBox(
                        title: context.getText(AppKeys.gamesRescueHoldLever),
                        count: _bridgeAssigned,
                        color: _rescueYellow,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Text(
                        '+',
                        style: TextStyle(
                          color: _rescueInk.withValues(alpha: 0.52),
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _TeamBox(
                        title: context.getText(AppKeys.gamesRescueCrossBridge),
                        count: crossing,
                        color: _rescueSky,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      key: const ValueKey('rescue-bridge-minus'),
                      onPressed: () => _changeBridgeTeam(-1),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        '$_bridgeAssigned',
                        key: const ValueKey('rescue-bridge-count'),
                        style: const TextStyle(
                          color: _rescueInk,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      key: const ValueKey('rescue-bridge-plus'),
                      onPressed: () => _changeBridgeTeam(1),
                      style: IconButton.styleFrom(backgroundColor: _rescueTeal),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              key: const ValueKey('rescue-open-bridge'),
              onPressed: _animating ? null : _openBridge,
              style: FilledButton.styleFrom(
                backgroundColor: ready ? _rescueTeal : _rescueCoral,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: Icon(ready ? Icons.lock_open_rounded : Icons.lock_rounded),
              label: Text(
                context.getText(
                  ready
                      ? AppKeys.gamesRescueOpenBridge
                      : AppKeys.gamesRescueNeedExactTeam,
                ),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoss() {
    final remaining = _teamSize - _numiCommittedToBoss;
    return SingleChildScrollView(
      key: const ValueKey('rescue-boss'),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      child: Column(
        children: [
          _MissionPrompt(
            eyebrow: context.getText(AppKeys.gamesRescueFinalChallenge),
            title: context.getText(AppKeys.gamesRescueBossTitle),
            message: context.getText(AppKeys.gamesRescueBossHint),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF254C5D), Color(0xFF112F3A)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🦾', style: TextStyle(fontSize: 55)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.getText(AppKeys.gamesRescueBossName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          context.formatText(AppKeys.gamesRescueNumiReady, {
                            'count': remaining,
                          }),
                          style: const TextStyle(
                            color: _rescueYellow,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: List.generate(_bossCores.length, (index) {
                    final broken = _brokenCores.contains(index);
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 5,
                          right: index == _bossCores.length - 1 ? 0 : 5,
                        ),
                        child: _BossCore(
                          key: ValueKey('rescue-boss-core-$index'),
                          requiredNumi: _bossCores[index],
                          broken: broken,
                          enabled:
                              !_animating && remaining >= _bossCores[index],
                          onTap: () => _attackCore(index),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                _NumiSquad(count: remaining),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
