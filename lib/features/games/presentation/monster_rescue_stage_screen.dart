import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/games/monster_rescue/monster_rescue_data.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

const _rescueInk = Color(0xFF153A3C);
const _rescueTeal = Color(0xFF007D77);
const _rescueMint = Color(0xFFDDF6E7);
const _rescueYellow = Color(0xFFFFD84D);
const _rescueCoral = Color(0xFFFF745F);
const _rescueSky = Color(0xFF58C8E8);
const _rescuePaper = Color(0xFFFFFDF5);

enum _RescuePhase { intro, path, bridge, boss, rescued }

class MonsterRescueStageScreen extends StatefulWidget {
  const MonsterRescueStageScreen({super.key, required this.level});

  final int level;

  @override
  State<MonsterRescueStageScreen> createState() =>
      _MonsterRescueStageScreenState();
}

class _MonsterRescueStageScreenState extends State<MonsterRescueStageScreen> {
  late final MonsterRescueLevelConfig _config;
  final GuardedExitController<bool> _exitController =
      GuardedExitController<bool>();
  final AudioPlayer _effectsPlayer = AudioPlayer();

  _RescuePhase _phase = _RescuePhase.intro;
  late int _teamSize;
  int _choiceIndex = 0;
  int _bridgeAssigned = 1;
  int _stars = 0;
  bool _animating = false;
  int? _lastTeamSize;
  late List<int> _bossCores;
  final Set<int> _brokenCores = <int>{};

  @override
  void initState() {
    super.initState();
    _config = monsterRescueLevel(widget.level);
    _teamSize = _config.startingTeam;
    _bossCores = const [];
  }

  @override
  void dispose() {
    _effectsPlayer.dispose();
    super.dispose();
  }

  void _startRescue() {
    HapticFeedback.heavyImpact();
    setState(() => _phase = _RescuePhase.path);
  }

  Future<void> _chooseGate(RescueGate gate) async {
    if (_animating) {
      return;
    }
    final choice = _config.choices[_choiceIndex];
    final leftResult = choice.left.apply(_teamSize);
    final rightResult = choice.right.apply(_teamSize);
    final newSize = gate.apply(_teamSize);
    setState(() {
      _animating = true;
      _lastTeamSize = _teamSize;
      _teamSize = newSize;
      if (newSize == (leftResult > rightResult ? leftResult : rightResult)) {
        _stars += 1;
      }
    });
    HapticFeedback.heavyImpact();
    unawaited(_playEffect('correct.wav'));
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (!mounted) {
      return;
    }
    setState(() {
      _lastTeamSize = null;
      _animating = false;
      if (_choiceIndex < _config.choices.length - 1) {
        _choiceIndex += 1;
      } else {
        _phase = _RescuePhase.bridge;
        _bridgeAssigned = 1;
      }
    });
  }

  void _changeBridgeTeam(int delta) {
    final next = (_bridgeAssigned + delta).clamp(1, _teamSize - 1);
    if (next == _bridgeAssigned) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _bridgeAssigned = next);
  }

  Future<void> _openBridge() async {
    if (_bridgeAssigned != _config.bridgeTeam || _animating) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() {
      _animating = true;
      _stars += 1;
    });
    unawaited(_playEffect('correct.wav'));
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    final lastCore = _teamSize - 5;
    setState(() {
      _bossCores = <int>[2, 3, lastCore];
      _phase = _RescuePhase.boss;
      _animating = false;
    });
  }

  int get _numiCommittedToBoss =>
      _brokenCores.fold<int>(0, (total, index) => total + _bossCores[index]);

  Future<void> _attackCore(int index) async {
    if (_animating || _brokenCores.contains(index)) {
      return;
    }
    final remaining = _teamSize - _numiCommittedToBoss;
    final required = _bossCores[index];
    if (remaining < required) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _brokenCores.add(index));
    HapticFeedback.heavyImpact();
    unawaited(_playEffect('correct.wav'));
    if (_brokenCores.length != _bossCores.length || !mounted) {
      return;
    }
    setState(() {
      _animating = true;
      _stars += 1;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    setState(() {
      _phase = _RescuePhase.rescued;
      _animating = false;
    });
  }

  Future<void> _playEffect(String name) async {
    try {
      await _effectsPlayer.stop();
      await _effectsPlayer.play(AssetSource('sounds/effects/$name'));
    } catch (_) {
      // Sound is a reward layer; gameplay remains available without audio.
    }
  }

  Future<bool> _confirmExit(BuildContext dialogContext) async {
    final shouldExit = await showDialog<bool>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.pets_rounded, color: _rescueTeal),
        title: Text(context.getText(AppKeys.gamesExitTitle)),
        content: Text(context.getText(AppKeys.gamesExitMessage)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.getText(AppKeys.gamesKeepPlaying)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.getText(AppKeys.gamesRescueBackToMap)),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  double get _progress => switch (_phase) {
    _RescuePhase.intro => 0,
    _RescuePhase.path => 0.15 + (_choiceIndex * 0.2),
    _RescuePhase.bridge => 0.58,
    _RescuePhase.boss => 0.72 + (_brokenCores.length * 0.08),
    _RescuePhase.rescued => 1,
  };

  @override
  Widget build(BuildContext context) {
    return GuardedExitScope<bool>(
      controller: _exitController,
      shouldConfirm: _phase != _RescuePhase.rescued,
      confirmExit: _confirmExit,
      child: Scaffold(
        backgroundColor: _rescueMint,
        body: SafeArea(
          child: switch (_phase) {
            _RescuePhase.intro => _buildIntro(),
            _RescuePhase.rescued => _buildRescued(),
            _ => _buildMission(),
          },
        ),
      ),
    );
  }

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

class _GateCard extends StatelessWidget {
  const _GateCard({
    super.key,
    required this.gate,
    required this.teamSize,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final RescueGate gate;
  final int teamSize;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final result = gate.apply(teamSize);
    return Semantics(
      button: true,
      label: '${gate.label}, $teamSize thành $result',
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            height: 137,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.32), blurRadius: 15),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gate.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 37,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$teamSize → $result 🐾',
                    style: const TextStyle(
                      color: _rescueInk,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumiSquad extends StatelessWidget {
  const _NumiSquad({required this.count, this.previousCount});

  final int count;
  final int? previousCount;

  @override
  Widget build(BuildContext context) {
    final visible = count.clamp(0, 14);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: -5,
            runSpacing: -5,
            children: List.generate(
              visible,
              (index) => AnimatedScale(
                duration: Duration(milliseconds: 220 + (index * 25)),
                scale: previousCount != null && index >= previousCount!
                    ? 1.28
                    : 1,
                curve: Curves.elasticOut,
                child: const Text('🐾', style: TextStyle(fontSize: 27)),
              ),
            ),
          ),
        ),
        if (count > visible)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '+${count - visible}',
              style: const TextStyle(
                color: _rescueInk,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _TeamBox extends StatelessWidget {
  const _TeamBox({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _rescueInk,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$count 🐾',
            style: const TextStyle(
              color: _rescueInk,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BossCore extends StatelessWidget {
  const _BossCore({
    super.key,
    required this.requiredNumi,
    required this.broken,
    required this.enabled,
    required this.onTap,
  });

  final int requiredNumi;
  final bool broken;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: broken ? _rescueTeal.withValues(alpha: 0.35) : _rescueCoral,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          height: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: broken ? _rescueSky : Colors.white,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                broken ? Icons.bolt_rounded : Icons.lock_rounded,
                color: Colors.white,
                size: 27,
              ),
              const SizedBox(height: 5),
              Text(
                broken ? '✓' : '$requiredNumi 🐾',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.08, size.height)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.06,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.94,
        size.width * 0.92,
        0,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB79063)
        ..strokeWidth = 40
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE5C99F)
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
