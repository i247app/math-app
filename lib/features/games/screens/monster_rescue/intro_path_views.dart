part of '../monster_rescue_stage_screen.dart';

extension _MonsterRescueIntroPathViews on _MonsterRescueStageScreenState {
  Widget _buildIntro() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(_config.creatureAsset, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xD90B3535)],
              stops: [0.4, 1],
            ),
          ),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: IconButton.filledTonal(
            onPressed: _exitController.requestExit,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _rescueYellow,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  context.getText(AppKeys.gamesRescueUrgent),
                  style: const TextStyle(
                    color: _rescueInk,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.getText(_config.titleKey),
                key: const ValueKey('rescue-intro-title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.formatText(AppKeys.gamesRescueIntroMessage, {
                  'name': _config.creatureName,
                }),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  key: const ValueKey('rescue-start'),
                  onPressed: _startRescue,
                  style: FilledButton.styleFrom(
                    backgroundColor: _rescueCoral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  icon: const Icon(Icons.directions_run_rounded, size: 28),
                  label: Text(
                    context.getText(AppKeys.gamesRescueStart),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMission() {
    return Column(
      children: [
        _MissionHeader(
          creatureAsset: _config.creatureAsset,
          creatureName: _config.creatureName,
          teamSize:
              _teamSize -
              (_phase == _RescuePhase.boss ? _numiCommittedToBoss : 0),
          stars: _stars,
          progress: _progress,
          onBack: _exitController.requestExit,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: switch (_phase) {
              _RescuePhase.path => _buildPathChoice(),
              _RescuePhase.bridge => _buildBridge(),
              _RescuePhase.boss => _buildBoss(),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPathChoice() {
    final choice = _config.choices[_choiceIndex];
    return SingleChildScrollView(
      key: ValueKey('rescue-path-$_choiceIndex'),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      child: Column(
        children: [
          _MissionPrompt(
            eyebrow: context.formatText(AppKeys.gamesRescueCheckpoint, {
              'current': _choiceIndex + 1,
              'total': _config.choices.length,
            }),
            title: context.getText(AppKeys.gamesRescueChoosePath),
            message: context.getText(AppKeys.gamesRescueGateHint),
          ),
          const SizedBox(height: 15),
          Container(
            height: 192,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8ADBC0), Color(0xFFDCF3B2)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26566B48),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 14,
                  top: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      _config.creatureAsset,
                      width: 66,
                      height: 66,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 83,
                  child: CustomPaint(painter: _TrailPainter()),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _NumiSquad(
                    count: _teamSize,
                    previousCount: _lastTeamSize,
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 15,
                  child: Text(
                    choice.sceneEmoji,
                    style: const TextStyle(fontSize: 41),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _GateCard(
                  key: ValueKey('rescue-left-gate-$_choiceIndex'),
                  gate: choice.left,
                  teamSize: _teamSize,
                  color: _rescueSky,
                  enabled: !_animating,
                  onTap: () => _chooseGate(choice.left),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: _GateCard(
                  key: ValueKey('rescue-right-gate-$_choiceIndex'),
                  gate: choice.right,
                  teamSize: _teamSize,
                  color: _rescueCoral,
                  enabled: !_animating,
                  onTap: () => _chooseGate(choice.right),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
