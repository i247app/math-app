import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/games/math_squadron/math_squadron_data.dart';

const _spaceTop = Color(0xFF060D2D);
const _spaceBottom = Color(0xFF111C52);
const _spaceCyan = Color(0xFF39D9FF);
const _spaceGold = Color(0xFFFFD95A);
const _spaceRed = Color(0xFFFF625F);
const _spaceGreen = Color(0xFF4DE3A7);
const _waveSize = 30;
const _minimumMathKills = 10;
const _reloadDuration = 0.9;

enum _MissionPhase { wave, boss, ended }

enum _MissionResultAction { retry, map }

class _MeteorEntity {
  _MeteorEntity({
    required this.id,
    this.question,
    required this.x,
    required this.y,
    required this.speed,
    required this.scale,
  });

  final int id;
  final MathSquadronQuestion? question;
  final double x;
  double y;
  final double speed;
  final double scale;
  double shieldFlash = 0;

  bool get hasQuestion => question != null;
}

class _BossMissile {
  _BossMissile({required this.id, required this.x}) : y = -0.08;

  final int id;
  final double x;
  double y;
}

class _BossPartEntity {
  _BossPartEntity({
    required this.id,
    required this.question,
    required this.position,
    required this.isArmor,
  });

  final int id;
  final MathSquadronQuestion question;
  final Offset position;
  final bool isArmor;
  bool alive = true;
  double shieldFlash = 0;
}

class MathSquadronStageScreen extends StatefulWidget {
  const MathSquadronStageScreen({super.key, required this.level});

  final int level;

  @override
  State<MathSquadronStageScreen> createState() =>
      _MathSquadronStageScreenState();
}

class _MathSquadronStageScreenState extends State<MathSquadronStageScreen> {
  late final MathSquadronLevelConfig _config;
  late final math.Random _random;
  final AudioPlayer _effectsPlayer = AudioPlayer();

  Timer? _gameTimer;
  DateTime _lastTick = DateTime.now();
  _MissionPhase _phase = _MissionPhase.wave;
  final List<_MeteorEntity> _meteors = [];
  final List<_BossMissile> _missiles = [];
  final List<_BossPartEntity> _bossParts = [];
  Offset _shipPosition = const Offset(0.5, 0.84);
  int _nextEntityId = 1;
  int _spawned = 0;
  int _plainSpawnedSinceQuestion = 0;
  int _passed = 0;
  int _destroyed = 0;
  int _wrongShots = 0;
  int _bossPartsDestroyed = 0;
  int _score = 0;
  int _combo = 0;
  late int _shields;
  late String _currentAmmo;
  String? _nextAmmo;
  final List<String> _ammoQueue = [];
  bool _nextAmmoGuaranteed = false;
  double _reloadRemaining = 0;
  double _spawnClock = 0;
  double _worldTime = 0;
  double _bossTime = 0;
  double _missileClock = 0;
  int _laserCycle = -1;
  double _laserLane = 0.5;
  bool _laserDamagedThisCycle = false;
  double _damageImmunity = 0;
  bool _shotFlashing = false;
  bool _lastShotCorrect = false;
  Offset? _shotTarget;
  bool _finishing = false;
  bool _allowPop = false;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _config = mathSquadronLevel(widget.level);
    assert(_hasValidQuestions(_config));
    _random = math.Random(widget.level * 7919);
    _startMission();
  }

  void _startMission() {
    _gameTimer?.cancel();
    _phase = _MissionPhase.wave;
    _meteors.clear();
    _missiles.clear();
    _bossParts.clear();
    _shipPosition = const Offset(0.5, 0.84);
    _spawned = 0;
    _plainSpawnedSinceQuestion = 0;
    _passed = 0;
    _destroyed = 0;
    _wrongShots = 0;
    _bossPartsDestroyed = 0;
    _score = 0;
    _combo = 0;
    _shields = _config.shields;
    _spawnClock = 0;
    _worldTime = 0;
    _bossTime = 0;
    _missileClock = 0;
    _laserCycle = -1;
    _laserDamagedThisCycle = false;
    _damageImmunity = 0;
    _shotFlashing = false;
    _finishing = false;
    _paused = false;
    final first = _config.questions.first;
    _currentAmmo = _randomAmmo();
    _nextAmmo = _randomAmmo(excluding: _currentAmmo);
    _ammoQueue.clear();
    _nextAmmoGuaranteed = false;
    _reloadRemaining = 0;
    _spawnMeteor(question: first, startNearTop: true);
    _lastTick = DateTime.now();
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 33),
      (_) => _tick(),
    );
  }

  void _tick() {
    if (!mounted || _phase == _MissionPhase.ended || _finishing || _paused) {
      return;
    }
    final now = DateTime.now();
    final dt =
        (now.difference(_lastTick).inMicroseconds / 1000000).clamp(0.0, 0.08);
    _lastTick = now;
    var shouldFinishWave = false;
    setState(() {
      _worldTime += dt;
      _damageImmunity = math.max(0, _damageImmunity - dt);
      if (_reloadRemaining > 0) {
        _reloadRemaining = math.max(0, _reloadRemaining - dt);
        if (_reloadRemaining == 0 && _nextAmmo != null) {
          _currentAmmo = _nextAmmo!;
          if (_ammoQueue.isNotEmpty) {
            _nextAmmo = _ammoQueue.removeAt(0);
            _nextAmmoGuaranteed = true;
          } else {
            _nextAmmo = _randomAmmo(excluding: _currentAmmo);
            _nextAmmoGuaranteed = false;
          }
        }
      }
      if (_phase == _MissionPhase.wave) {
        _updateWave(dt);
        shouldFinishWave = _spawned >= _waveSize && _meteors.isEmpty;
      } else if (_phase == _MissionPhase.boss) {
        _updateBoss(dt);
      }
    });
    if (shouldFinishWave) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _completeWave());
    }
  }

  void _updateWave(double dt) {
    final spawnInterval = math.max(0.84, 1.3 - widget.level * 0.045);
    _spawnClock += dt;
    if (_spawned < _waveSize &&
        _spawnClock >= spawnInterval &&
        _meteors.length < 8) {
      _spawnClock = 0;
      final activeQuestions =
          _meteors.where((meteor) => meteor.hasQuestion).length;
      final spawnQuestion = activeQuestions == 0 ||
          (activeQuestions < 2 &&
              (_plainSpawnedSinceQuestion >= 2 || _random.nextDouble() < 0.42));
      _spawnMeteor(withQuestion: spawnQuestion);
    }

    final passedIds = <int>[];
    for (final meteor in _meteors) {
      meteor.y += meteor.speed * dt;
      meteor.shieldFlash = math.max(0, meteor.shieldFlash - dt);
      if (_collides(_shipPosition, Offset(meteor.x, meteor.y), 0.085)) {
        passedIds.add(meteor.id);
        if (meteor.hasQuestion) {
          _passed += 1;
        }
        _takeDamage();
      } else if (meteor.y > 1.08) {
        passedIds.add(meteor.id);
        if (meteor.hasQuestion) {
          _passed += 1;
        }
      }
    }
    if (passedIds.isNotEmpty) {
      _meteors.removeWhere((meteor) => passedIds.contains(meteor.id));
    }
  }

  void _spawnMeteor({
    MathSquadronQuestion? question,
    bool startNearTop = false,
    bool withQuestion = true,
  }) {
    if (withQuestion && _spawned >= _waveSize) {
      return;
    }
    final selectedQuestion = withQuestion
        ? question ??
            _config.questions[_random.nextInt(_config.questions.length)]
        : null;
    final activeQuestionsBefore =
        _meteors.where((meteor) => meteor.hasQuestion).length;
    final lane = 0.12 + _random.nextDouble() * 0.76;
    _meteors.add(
      _MeteorEntity(
        id: _nextEntityId++,
        question: selectedQuestion,
        x: lane,
        y: startNearTop ? 0.04 : -0.14,
        speed: 0.075 + widget.level * 0.005 + _random.nextDouble() * 0.018,
        scale: 0.86 + _random.nextDouble() * 0.22,
      ),
    );
    if (selectedQuestion != null) {
      _spawned += 1;
      _plainSpawnedSinceQuestion = 0;
      _registerMathAmmo(
        selectedQuestion.correctAnswer,
        prioritizeNext: activeQuestionsBefore == 0,
      );
    } else {
      _plainSpawnedSinceQuestion += 1;
    }
  }

  String _randomAmmo({String? excluding}) {
    final answers = _config.questions
        .map((question) => question.correctAnswer)
        .toSet()
        .where((answer) => answer != excluding)
        .toList(growable: false);
    if (answers.isEmpty) {
      return _config.questions.first.correctAnswer;
    }
    return answers[_random.nextInt(answers.length)];
  }

  void _registerMathAmmo(
    String answer, {
    required bool prioritizeNext,
  }) {
    if (_currentAmmo == answer) {
      if (!prioritizeNext) {
        _ammoQueue.add(answer);
      }
      return;
    }
    if (prioritizeNext && _nextAmmo != answer) {
      _nextAmmo = answer;
      _nextAmmoGuaranteed = true;
      return;
    }
    if (!_nextAmmoGuaranteed) {
      _nextAmmo = answer;
      _nextAmmoGuaranteed = true;
      return;
    }
    _ammoQueue.add(answer);
  }

  Future<void> _fire() async {
    if (_shotFlashing ||
        _reloadRemaining > 0 ||
        _phase == _MissionPhase.ended) {
      return;
    }
    if (_phase == _MissionPhase.wave) {
      final target = _nearestMeteorInLane();
      if (target == null) {
        _startEmptyShot();
      } else {
        final correct = !target.hasQuestion ||
            target.question!.correctAnswer == _currentAmmo;
        HapticFeedback.lightImpact();
        setState(() {
          _shotFlashing = true;
          _lastShotCorrect = correct;
          _shotTarget = Offset(target.x, target.y);
          if (correct) {
            _meteors.remove(target);
            if (target.hasQuestion) {
              _destroyed += 1;
              _combo += 1;
              _score += 100 + math.min(_combo, 5) * 20;
            } else {
              _score += 25;
            }
          } else {
            target.shieldFlash = 0.45;
            _wrongShots += 1;
            _combo = 0;
          }
        });
        unawaited(_playEffect(correct));
      }
    } else {
      final target = _nearestBossPartInLane();
      if (target == null) {
        _startEmptyShot();
      } else {
        final correct = target.question.correctAnswer == _currentAmmo;
        HapticFeedback.lightImpact();
        setState(() {
          _shotFlashing = true;
          _lastShotCorrect = correct;
          _shotTarget = target.position;
          if (correct) {
            target.alive = false;
            _bossPartsDestroyed += 1;
            _combo += 1;
            _score += 180 + math.min(_combo, 5) * 25;
          } else {
            target.shieldFlash = 0.45;
            _wrongShots += 1;
            _combo = 0;
          }
        });
        unawaited(_playEffect(correct));
        if (_bossParts.every((part) => !part.alive)) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _finishMission(true));
        }
      }
    }
    if (mounted) {
      setState(() => _reloadRemaining = _reloadDuration);
    }
    await Future<void>.delayed(const Duration(milliseconds: 190));
    if (mounted) {
      setState(() {
        _shotFlashing = false;
        _shotTarget = null;
      });
    }
  }

  void _startEmptyShot() {
    HapticFeedback.selectionClick();
    setState(() {
      _shotFlashing = true;
      _lastShotCorrect = true;
      _shotTarget = Offset(_shipPosition.dx, 0);
    });
  }

  _MeteorEntity? _nearestMeteorInLane() {
    final candidates = _meteors
        .where(
          (meteor) =>
              meteor.y < _shipPosition.dy &&
              (meteor.x - _shipPosition.dx).abs() < 0.115,
        )
        .toList()
      ..sort((a, b) => b.y.compareTo(a.y));
    return candidates.isEmpty ? null : candidates.first;
  }

  _BossPartEntity? _nearestBossPartInLane() {
    final candidates = _bossParts
        .where(
          (part) =>
              part.alive && (part.position.dx - _shipPosition.dx).abs() < 0.12,
        )
        .toList()
      ..sort((a, b) => b.position.dy.compareTo(a.position.dy));
    return candidates.isEmpty ? null : candidates.first;
  }

  Future<void> _playEffect(bool correct) async {
    try {
      await _effectsPlayer.stop();
      await _effectsPlayer.play(
        AssetSource(
          correct
              ? 'sounds/effects/correct.wav'
              : 'sounds/effects/incorrect.wav',
        ),
      );
    } catch (_) {
      // Keep gameplay running when audio cannot initialize.
    }
  }

  void _completeWave() {
    if (!mounted || _phase != _MissionPhase.wave || _finishing) {
      return;
    }
    if (_destroyed < _minimumMathKills) {
      _finishMission(false);
      return;
    }
    if (_config.isBoss) {
      setState(_enterBoss);
    } else {
      _finishMission(true);
    }
  }

  void _enterBoss() {
    _phase = _MissionPhase.boss;
    _bossTime = 0;
    _missileClock = 0;
    _missiles.clear();
    final bonusArmor = _destroyed < 15
        ? 2
        : _destroyed < 22
            ? 1
            : 0;
    final partCount = 4 + bonusArmor;
    const positions = <Offset>[
      Offset(0.24, 0.25),
      Offset(0.76, 0.25),
      Offset(0.34, 0.43),
      Offset(0.66, 0.43),
      Offset(0.50, 0.58),
      Offset(0.18, 0.57),
      Offset(0.82, 0.57),
    ];
    _ammoQueue.clear();
    _currentAmmo = _randomAmmo();
    _nextAmmo = _randomAmmo(excluding: _currentAmmo);
    _nextAmmoGuaranteed = false;
    for (var index = 0; index < partCount; index++) {
      final question = _config.questions[
          (index + _random.nextInt(_config.questions.length)) %
              _config.questions.length];
      _bossParts.add(
        _BossPartEntity(
          id: _nextEntityId++,
          question: question,
          position: positions[index],
          isArmor: index >= 4,
        ),
      );
      _registerMathAmmo(
        question.correctAnswer,
        prioritizeNext: index == 0,
      );
    }
    _reloadRemaining = 0;
  }

  void _updateBoss(double dt) {
    _bossTime += dt;
    _missileClock += dt;
    for (final part in _bossParts) {
      part.shieldFlash = math.max(0, part.shieldFlash - dt);
    }

    final missileInterval = math.max(4.1, 5.0 - widget.level * 0.1);
    if (_missileClock >= missileInterval) {
      _missileClock = 0;
      final lanes = [0.2, 0.36, 0.52, 0.68, 0.82];
      _missiles.add(
        _BossMissile(
          id: _nextEntityId++,
          x: lanes[_random.nextInt(lanes.length)],
        ),
      );
    }
    final removedMissiles = <int>[];
    for (final missile in _missiles) {
      missile.y += 0.145 * dt;
      if (_collides(_shipPosition, Offset(missile.x, missile.y), 0.07)) {
        removedMissiles.add(missile.id);
        _takeDamage();
      } else if (missile.y > 1.08) {
        removedMissiles.add(missile.id);
      }
    }
    _missiles.removeWhere((missile) => removedMissiles.contains(missile.id));

    final cycle = (_bossTime / 9.0).floor();
    if (cycle != _laserCycle) {
      _laserCycle = cycle;
      _laserLane = 0.16 + _random.nextDouble() * 0.68;
      _laserDamagedThisCycle = false;
    }
    if (_laserActive &&
        !_laserDamagedThisCycle &&
        (_shipPosition.dx - _laserLane).abs() < 0.095) {
      _laserDamagedThisCycle = true;
      _takeDamage();
    }
  }

  double get _laserPhase => _bossTime % 9.0;
  bool get _laserWarning =>
      _phase == _MissionPhase.boss && _laserPhase >= 6.3 && _laserPhase < 7.75;
  bool get _laserActive =>
      _phase == _MissionPhase.boss && _laserPhase >= 7.75 && _laserPhase < 8.55;

  void _takeDamage() {
    if (_damageImmunity > 0 || _phase == _MissionPhase.ended) {
      return;
    }
    _damageImmunity = 1.0;
    _shields = math.max(0, _shields - 1);
    _combo = 0;
    HapticFeedback.vibrate();
    unawaited(_playEffect(false));
    if (_shields == 0) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _finishMission(false));
    }
  }

  bool _collides(Offset a, Offset b, double distance) =>
      (a - b).distance < distance;

  Future<void> _finishMission(bool won) async {
    if (_finishing || !mounted) {
      return;
    }
    _finishing = true;
    _phase = _MissionPhase.ended;
    final action = await showDialog<_MissionResultAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MissionResultDialog(
        won: won,
        isBoss: _config.isBoss,
        level: _config.level,
        score: _score,
        destroyed: _destroyed,
        passed: _passed,
        wrongShots: _wrongShots,
        bossPartsDestroyed: _bossPartsDestroyed,
      ),
    );
    if (!mounted) return;
    if (action == _MissionResultAction.retry) {
      setState(_startMission);
      return;
    }
    await _popWithResult(won);
  }

  Future<void> _popWithResult(bool result) async {
    if (!mounted) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop(result);
  }

  Future<bool> _confirmExit() async {
    _paused = true;
    final exit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.getText(AppKeys.gamesSquadronExitTitle)),
            content: Text(context.getText(AppKeys.gamesSquadronExitMessage)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.getText(AppKeys.gamesSquadronKeepPlaying)),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.getText(AppKeys.gamesFarmBackToMap)),
              ),
            ],
          ),
        ) ??
        false;
    if (!exit) {
      _paused = false;
      _lastTick = DateTime.now();
    }
    return exit;
  }

  void _moveShip(DragUpdateDetails details, Size size) {
    if (_phase == _MissionPhase.ended || size.width <= 0 || size.height <= 0) {
      return;
    }
    setState(() {
      _shipPosition = Offset(
        (_shipPosition.dx + details.delta.dx / size.width).clamp(0.08, 0.92),
        (_shipPosition.dy + details.delta.dy / size.height).clamp(0.48, 0.92),
      );
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _effectsPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(_config.accentValue);
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await _confirmExit() && context.mounted) {
          await _popWithResult(false);
        }
      },
      child: Scaffold(
        backgroundColor: _spaceTop,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_spaceTop, _spaceBottom],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 700;
                return Column(
                  children: [
                    _MissionHud(
                      level: _config.level,
                      phase: _phase,
                      shields: _shields,
                      maxShields: _config.shields,
                      score: _score,
                      combo: _combo,
                      progress: _phase == _MissionPhase.wave
                          ? _spawned / _waveSize
                          : _bossParts.isEmpty
                              ? 0
                              : _bossParts.where((part) => part.alive).length /
                                  _bossParts.length,
                      accent: accent,
                      onBack: () async {
                        if (await _confirmExit() && context.mounted) {
                          await _popWithResult(false);
                        }
                      },
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, arenaConstraints) {
                          final size = Size(
                            arenaConstraints.maxWidth,
                            arenaConstraints.maxHeight,
                          );
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanUpdate: (details) => _moveShip(details, size),
                            child: _GameArena(
                              size: size,
                              phase: _phase,
                              level: widget.level,
                              worldTime: _worldTime,
                              meteors: _meteors,
                              bossParts: _bossParts,
                              missiles: _missiles,
                              shipPosition: _shipPosition,
                              shipDamaged: _damageImmunity > 0,
                              shotFlashing: _shotFlashing,
                              lastShotCorrect: _lastShotCorrect,
                              shotTarget: _shotTarget,
                              laserWarning: _laserWarning,
                              laserActive: _laserActive,
                              laserLane: _laserLane,
                              compact: compact,
                            ),
                          );
                        },
                      ),
                    ),
                    _AmmoPanel(
                      currentAmmo: _currentAmmo,
                      nextAmmo: _nextAmmo,
                      reloading: _reloadRemaining > 0,
                      reloadProgress:
                          1 - (_reloadRemaining / _reloadDuration).clamp(0, 1),
                      compact: compact,
                      onFire: _fire,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GameArena extends StatelessWidget {
  const _GameArena({
    required this.size,
    required this.phase,
    required this.level,
    required this.worldTime,
    required this.meteors,
    required this.bossParts,
    required this.missiles,
    required this.shipPosition,
    required this.shipDamaged,
    required this.shotFlashing,
    required this.lastShotCorrect,
    required this.shotTarget,
    required this.laserWarning,
    required this.laserActive,
    required this.laserLane,
    required this.compact,
  });

  final Size size;
  final _MissionPhase phase;
  final int level;
  final double worldTime;
  final List<_MeteorEntity> meteors;
  final List<_BossPartEntity> bossParts;
  final List<_BossMissile> missiles;
  final Offset shipPosition;
  final bool shipDamaged;
  final bool shotFlashing;
  final bool lastShotCorrect;
  final Offset? shotTarget;
  final bool laserWarning;
  final bool laserActive;
  final double laserLane;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final meteorSize = compact ? 92.0 : 106.0;
    return ClipRect(
      child: CustomPaint(
        painter: _MovingStarfieldPainter(progress: worldTime / 9),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (phase == _MissionPhase.boss)
              Positioned(
                top: compact ? 8 : 14,
                left: size.width * 0.08,
                child: CustomPaint(
                  size: Size(size.width * 0.84, size.height * 0.42),
                  painter: _BossShipPainter(level: level, hit: false),
                ),
              ),
            if (phase == _MissionPhase.boss)
              for (final part in bossParts.where((part) => part.alive))
                Positioned(
                  left: size.width * part.position.dx - 38,
                  top: size.height * part.position.dy - 23,
                  child: _BossPartTarget(
                    part: part,
                  ),
                ),
            for (final meteor in meteors)
              Positioned(
                left: size.width * meteor.x - meteorSize * meteor.scale / 2,
                top: size.height * meteor.y - meteorSize * meteor.scale / 2,
                child: _EquationMeteor(
                  meteor: meteor,
                  size: meteorSize * meteor.scale,
                ),
              ),
            for (final missile in missiles)
              Positioned(
                left: size.width * missile.x - 16,
                top: size.height * missile.y - 24,
                child: Transform.rotate(
                  angle: math.pi,
                  child: const CustomPaint(
                    size: Size(32, 55),
                    painter: _MissilePainter(),
                  ),
                ),
              ),
            if (laserWarning || laserActive)
              Positioned(
                left: size.width * laserLane - (laserActive ? 30 : 19),
                top: 0,
                bottom: 0,
                child: Container(
                  width: laserActive ? 60 : 38,
                  decoration: BoxDecoration(
                    color: (laserActive ? _spaceRed : _spaceGold)
                        .withValues(alpha: laserActive ? 0.42 : 0.12),
                    border: Border.symmetric(
                      vertical: BorderSide(
                        color: laserActive ? Colors.white : _spaceGold,
                        width: laserActive ? 2.5 : 1.5,
                      ),
                    ),
                    boxShadow: laserActive
                        ? const [
                            BoxShadow(
                              color: _spaceRed,
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            if (shotFlashing && shotTarget != null)
              CustomPaint(
                size: size,
                painter: _LaserPainter(
                  from: Offset(
                    size.width * shipPosition.dx,
                    size.height * shipPosition.dy,
                  ),
                  to: Offset(
                    size.width * shotTarget!.dx,
                    size.height * shotTarget!.dy,
                  ),
                  correct: lastShotCorrect,
                ),
              ),
            Positioned(
              left: size.width * shipPosition.dx - (compact ? 37 : 44),
              top: size.height * shipPosition.dy - (compact ? 43 : 50),
              child: CustomPaint(
                size: Size(compact ? 74 : 88, compact ? 83 : 99),
                painter: _SpaceShipPainter(
                  firing: shotFlashing,
                  damaged: shipDamaged,
                ),
              ),
            ),
            if (phase == _MissionPhase.boss && laserWarning)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: _WarningChip(
                    label: context.getText(AppKeys.gamesSquadronLaserWarning),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EquationMeteor extends StatelessWidget {
  const _EquationMeteor({
    required this.meteor,
    required this.size,
  });

  final _MeteorEntity meteor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final flash = meteor.shieldFlash > 0;
    final question = meteor.question;
    return AnimatedScale(
      scale: flash ? 0.94 : 1,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MeteorPainter(
                  color: flash
                      ? _spaceRed
                      : question?.targetKind == MathSquadronTargetKind.crystal
                          ? const Color(0xFF5741A5)
                          : const Color(0xFF86513B),
                  energyCore: question != null &&
                      question.targetKind != MathSquadronTargetKind.meteor,
                ),
              ),
            ),
            if (question != null)
              Container(
                constraints: BoxConstraints(maxWidth: size * 0.76),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xE60A1235),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: flash ? _spaceRed : _spaceCyan,
                    width: flash ? 2.5 : 1.3,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    question.prompt,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BossPartTarget extends StatelessWidget {
  const _BossPartTarget({required this.part});

  final _BossPartEntity part;

  @override
  Widget build(BuildContext context) {
    final flash = part.shieldFlash > 0;
    return AnimatedScale(
      scale: flash ? 0.94 : 1,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: part.isArmor
                ? const [Color(0xFF765321), Color(0xFF2E263C)]
                : const [Color(0xFF273C77), Color(0xFF10183C)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: flash ? _spaceRed : _spaceCyan,
            width: flash ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _spaceCyan.withValues(alpha: 0.28),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              part.isArmor ? Icons.shield_rounded : Icons.settings_rounded,
              color: part.isArmor ? _spaceGold : _spaceCyan,
              size: 14,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                part.question.prompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
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

class _AmmoPanel extends StatelessWidget {
  const _AmmoPanel({
    required this.currentAmmo,
    required this.nextAmmo,
    required this.reloading,
    required this.reloadProgress,
    required this.compact,
    required this.onFire,
  });

  final String currentAmmo;
  final String? nextAmmo;
  final bool reloading;
  final double reloadProgress;
  final bool compact;
  final VoidCallback onFire;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, compact ? 8 : 10, 14, compact ? 8 : 12),
      decoration: const BoxDecoration(
        color: Color(0xF20A1235),
        border: Border(top: BorderSide(color: Color(0x4439D9FF))),
        boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 18)],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 56 : 64,
            height: compact ? 56 : 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white, _spaceCyan, Color(0xFF1764B2)],
              ),
              boxShadow: [BoxShadow(color: _spaceCyan, blurRadius: 18)],
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  currentAmmo,
                  style: const TextStyle(
                    color: _spaceTop,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getText(AppKeys.gamesSquadronCurrentAmmo),
                  style: const TextStyle(
                    color: _spaceCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.getText(AppKeys.gamesSquadronAimShip),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (nextAmmo != null)
                  Text(
                    context.formatText(
                      AppKeys.gamesSquadronNextAmmo,
                      {'ammo': nextAmmo},
                    ),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: reloading ? Colors.white12 : _spaceRed,
            shape: const CircleBorder(),
            elevation: reloading ? 0 : 8,
            shadowColor: _spaceRed,
            child: InkWell(
              onTap: onFire,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: compact ? 64 : 72,
                height: compact ? 64 : 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (reloading)
                      SizedBox(
                        width: compact ? 54 : 62,
                        height: compact ? 54 : 62,
                        child: CircularProgressIndicator(
                          value: reloadProgress,
                          strokeWidth: 4,
                          color: _spaceCyan,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          reloading
                              ? Icons.sync_rounded
                              : Icons.rocket_launch_rounded,
                          color: reloading ? _spaceCyan : Colors.white,
                          size: compact ? 24 : 27,
                        ),
                        Text(
                          context.getText(
                            reloading
                                ? AppKeys.gamesSquadronReloading
                                : AppKeys.gamesSquadronFire,
                          ),
                          style: TextStyle(
                            color: reloading ? _spaceCyan : Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionHud extends StatelessWidget {
  const _MissionHud({
    required this.level,
    required this.phase,
    required this.shields,
    required this.maxShields,
    required this.score,
    required this.combo,
    required this.progress,
    required this.accent,
    required this.onBack,
  });

  final int level;
  final _MissionPhase phase;
  final int shields;
  final int maxShields;
  final int score;
  final int combo;
  final double progress;
  final Color accent;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 5),
      child: Row(
        children: [
          _HudCircleButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase == _MissionPhase.boss
                      ? context.formatText(
                          AppKeys.gamesSquadronBossLevel,
                          {'level': level},
                        )
                      : context.formatText(
                          AppKeys.gamesLevelLabel,
                          {'level': level},
                        ),
                  style: TextStyle(
                    color:
                        phase == _MissionPhase.boss ? _spaceGold : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 6,
                    color: phase == _MissionPhase.boss ? _spaceRed : accent,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Row(
            children: List.generate(
              maxShields,
              (index) => Icon(
                Icons.shield_rounded,
                color: index < shields ? _spaceCyan : Colors.white12,
                size: maxShields > 5 ? 13 : 16,
              ),
            ),
          ),
          if (combo >= 2) ...[
            const SizedBox(width: 6),
            _HudChip(
              icon: Icons.local_fire_department_rounded,
              label: '×$combo',
              color: _spaceGold,
            ),
          ],
          const SizedBox(width: 6),
          _HudChip(icon: Icons.star_rounded, label: '$score', color: accent),
        ],
      ),
    );
  }
}

class _WarningChip extends StatelessWidget {
  const _WarningChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _spaceRed.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [BoxShadow(color: _spaceRed, blurRadius: 15)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HudCircleButton extends StatelessWidget {
  const _HudCircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white10,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      );
}

class _HudChip extends StatelessWidget {
  const _HudChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class _MissionResultDialog extends StatelessWidget {
  const _MissionResultDialog({
    required this.won,
    required this.isBoss,
    required this.level,
    required this.score,
    required this.destroyed,
    required this.passed,
    required this.wrongShots,
    required this.bossPartsDestroyed,
  });

  final bool won;
  final bool isBoss;
  final int level;
  final int score;
  final int destroyed;
  final int passed;
  final int wrongShots;
  final int bossPartsDestroyed;

  @override
  Widget build(BuildContext context) {
    final stars = destroyed >= 24
        ? 3
        : destroyed >= 20
            ? 2
            : destroyed >= _minimumMathKills
                ? 1
                : 0;
    final color = won ? _spaceCyan : _spaceRed;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF111C4B),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 30)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won
                  ? isBoss
                      ? Icons.emoji_events_rounded
                      : Icons.rocket_launch_rounded
                  : Icons.shield_outlined,
              color: won ? _spaceGold : _spaceRed,
              size: 58,
            ),
            Text(
              context.getText(
                won
                    ? isBoss
                        ? AppKeys.gamesSquadronBossDefeated
                        : AppKeys.gamesSquadronComplete
                    : AppKeys.gamesSquadronTryAgain,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Icon(
                  Icons.star_rounded,
                  color: index < stars ? _spaceGold : Colors.white12,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                _ResultStat(
                    icon: Icons.bolt_rounded,
                    value: '$destroyed',
                    color: _spaceGreen),
                const SizedBox(width: 7),
                _ResultStat(
                    icon: Icons.flight_takeoff_rounded,
                    value: '$passed',
                    color: _spaceCyan),
                const SizedBox(width: 7),
                _ResultStat(
                    icon: Icons.close_rounded,
                    value: '$wrongShots',
                    color: _spaceRed),
                const SizedBox(width: 7),
                _ResultStat(
                    icon: Icons.settings_rounded,
                    value: '$bossPartsDestroyed',
                    color: _spaceGold),
              ],
            ),
            const SizedBox(height: 19),
            if (won)
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(_MissionResultAction.map),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: _spaceCyan,
                  foregroundColor: _spaceTop,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17)),
                ),
                child: Text(
                  context.getText(AppKeys.gamesFarmBackToMap),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_MissionResultAction.map),
                      child: Text(context.getText(AppKeys.gamesFarmBackToMap)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_MissionResultAction.retry),
                      style: FilledButton.styleFrom(backgroundColor: _spaceRed),
                      child: Text(context.getText(AppKeys.retryUpper)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat(
      {required this.icon, required this.value, required this.color});
  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
}

class _MovingStarfieldPainter extends CustomPainter {
  const _MovingStarfieldPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    for (var index = 0; index < 75; index++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.55 + random.nextDouble() * 1.6;
      final y = (baseY + progress * size.height * speed) % size.height;
      canvas.drawLine(
        Offset(x, y - 2 - speed * 2),
        Offset(x, y + 2 + speed * 2),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.17 + speed * 0.2)
          ..strokeWidth = speed * 0.7
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MovingStarfieldPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _MeteorPainter extends CustomPainter {
  const _MeteorPainter({required this.color, this.energyCore = false});
  final Color color;
  final bool energyCore;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.44;
    final path = Path();
    const bumps = [1.0, .82, .94, .78, 1.0, .86, .92, .8, .98, .84, .91, .79];
    for (var index = 0; index < bumps.length; index++) {
      final angle = index / bumps.length * math.pi * 2 - math.pi / 2;
      final point = center +
          Offset(math.cos(angle), math.sin(angle)) * radius * bumps[index];
      index == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawShadow(path, Colors.black, 7, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.35, -.45),
          colors: [
            Color.lerp(color, Colors.white, .28)!,
            color,
            Color.lerp(color, Colors.black, .42)!,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final crater = Paint()..color = Colors.black.withValues(alpha: .28);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-radius * .34, -radius * .2),
        width: radius * .42,
        height: radius * .28,
      ),
      crater,
    );
    final crack = Paint()
      ..color = energyCore ? _spaceCyan : const Color(0xFFFF9A3D)
      ..strokeWidth = math.max(1.2, size.width * .018)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * .55, center.dy + radius * .05)
        ..lineTo(center.dx - radius * .18, center.dy - radius * .08)
        ..lineTo(center.dx + radius * .03, center.dy + radius * .25)
        ..lineTo(center.dx + radius * .48, center.dy + radius * .12),
      crack,
    );
  }

  @override
  bool shouldRepaint(covariant _MeteorPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.energyCore != energyCore;
}

class _SpaceShipPainter extends CustomPainter {
  const _SpaceShipPainter({required this.firing, required this.damaged});
  final bool firing;
  final bool damaged;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final glow = damaged ? _spaceRed : _spaceCyan;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * .83),
        width: w * .72,
        height: h * .28,
      ),
      Paint()
        ..color = glow.withValues(alpha: .3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    final flamePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, _spaceCyan, Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - w * .2, h * .68, w * .4, h * .35));
    for (final dx in [-.19, .19]) {
      canvas.drawPath(
        Path()
          ..moveTo(cx + w * dx - w * .07, h * .68)
          ..lineTo(cx + w * dx, h * (firing ? 1.06 : .94))
          ..lineTo(cx + w * dx + w * .07, h * .68)
          ..close(),
        flamePaint,
      );
    }
    final wings = Path()
      ..moveTo(cx, h * .03)
      ..lineTo(w * .79, h * .55)
      ..lineTo(w * .96, h * .69)
      ..lineTo(w * .68, h * .73)
      ..lineTo(cx, h * .61)
      ..lineTo(w * .32, h * .73)
      ..lineTo(w * .04, h * .69)
      ..lineTo(w * .21, h * .55)
      ..close();
    canvas.drawShadow(wings, Colors.black, 8, true);
    canvas.drawPath(
      wings,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFEAF7FF), Color(0xFF4389C7), Color(0xFF183A72)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    final body = Path()
      ..moveTo(cx, 0)
      ..quadraticBezierTo(w * .66, h * .35, w * .61, h * .78)
      ..lineTo(cx, h * .88)
      ..lineTo(w * .39, h * .78)
      ..quadraticBezierTo(w * .34, h * .35, cx, 0)
      ..close();
    canvas.drawPath(
      body,
      Paint()..color = damaged ? const Color(0xFFFFA09D) : Colors.white,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * .35),
        width: w * .24,
        height: h * .3,
      ),
      Paint()..color = const Color(0xFF43C9E8),
    );
  }

  @override
  bool shouldRepaint(covariant _SpaceShipPainter oldDelegate) =>
      oldDelegate.firing != firing || oldDelegate.damaged != damaged;
}

class _BossShipPainter extends CustomPainter {
  const _BossShipPainter({required this.level, required this.hit});
  final int level;
  final bool hit;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final accent = switch (level) {
      3 => const Color(0xFFFF5964),
      5 => const Color(0xFFFF9A3D),
      _ => const Color(0xFFFF4DCA),
    };
    final body = Path()
      ..moveTo(w * .5, h * .03)
      ..lineTo(w * .7, h * .25)
      ..lineTo(w * .98, h * .43)
      ..lineTo(w * .83, h * .78)
      ..lineTo(w * .61, h * .66)
      ..lineTo(w * .5, h * .97)
      ..lineTo(w * .39, h * .66)
      ..lineTo(w * .17, h * .78)
      ..lineTo(w * .02, h * .43)
      ..lineTo(w * .3, h * .25)
      ..close();
    canvas.drawShadow(body, Colors.black, 12, true);
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(accent, Colors.white, .18)!,
            const Color(0xFF111735)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    final armor = Paint()
      ..color = accent
      ..strokeWidth = math.max(2, w * .018)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(w * .1, h * .45)
        ..lineTo(w * .38, h * .35)
        ..lineTo(w * .5, h * .1)
        ..lineTo(w * .62, h * .35)
        ..lineTo(w * .9, h * .45),
      armor,
    );
    for (final x in [.13, .28, .72, .87]) {
      canvas.drawCircle(
          Offset(w * x, h * .58), h * .055, Paint()..color = _spaceGold);
    }
    canvas.drawCircle(Offset(w * .5, h * .48), h * .16,
        Paint()..color = accent.withValues(alpha: .28));
    canvas.drawCircle(
        Offset(w * .5, h * .48), h * .08, Paint()..color = _spaceCyan);
  }

  @override
  bool shouldRepaint(covariant _BossShipPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.hit != hit;
}

class _MissilePainter extends CustomPainter {
  const _MissilePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    canvas.drawPath(
      Path()
        ..moveTo(cx, 0)
        ..quadraticBezierTo(size.width * .88, size.height * .25,
            size.width * .72, size.height * .78)
        ..lineTo(cx, size.height * .9)
        ..lineTo(size.width * .28, size.height * .78)
        ..quadraticBezierTo(size.width * .12, size.height * .25, cx, 0)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          colors: [Colors.white, _spaceRed, Color(0xFF5B1735)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .34, size.height * .76)
        ..lineTo(cx, size.height)
        ..lineTo(size.width * .66, size.height * .76)
        ..close(),
      Paint()..color = _spaceGold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LaserPainter extends CustomPainter {
  const _LaserPainter(
      {required this.from, required this.to, required this.correct});
  final Offset from;
  final Offset to;
  final bool correct;

  @override
  void paint(Canvas canvas, Size size) {
    final color = correct ? _spaceCyan : _spaceRed;
    canvas.drawLine(
        from,
        to,
        Paint()
          ..color = color.withValues(alpha: .35)
          ..strokeWidth = 12);
    canvas.drawLine(
        from,
        to,
        Paint()
          ..color = color
          ..strokeWidth = 4);
    canvas.drawLine(
        from,
        to,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _LaserPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.correct != correct;
}

bool _hasValidQuestions(MathSquadronLevelConfig config) {
  return config.questions.every((question) {
    final unique = question.answers.toSet();
    return question.answers.length == 4 &&
        unique.length == 4 &&
        question.answers
                .where((answer) => answer == question.correctAnswer)
                .length ==
            1;
  });
}
