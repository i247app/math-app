import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/games/models/monster_rescue/monster_rescue_data.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

part 'monster_rescue/intro_path_views.dart';
part 'monster_rescue/battle_views.dart';
part 'monster_rescue/rescued_view.dart';
part 'monster_rescue/mission_widgets.dart';
part 'monster_rescue/challenge_widgets.dart';

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
}
