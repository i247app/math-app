import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/games/controllers/star_game_progress.dart';
import 'package:numi/features/games/controllers/star_game_round.dart';
import 'package:numi/features/games/models/star_game.dart';
import 'package:numi/features/games/widgets/star_game_art.dart';
import 'package:numi/features/games/widgets/star_game_controls.dart';
import 'package:numi/features/games/widgets/star_game_play_view.dart';
import 'package:numi/features/games/widgets/star_game_result_view.dart';

class StarGameScreen extends StatefulWidget {
  const StarGameScreen({
    super.key,
    required this.initialLevel,
    required this.progress,
  });

  final StarGameLevel initialLevel;
  final StarGameProgress progress;

  @override
  State<StarGameScreen> createState() => _StarGameScreenState();
}

class _StarGameScreenState extends State<StarGameScreen>
    with WidgetsBindingObserver {
  late StarGameLevel _level;
  late StarGameRound _round;
  StarGameRecord? _result;
  bool _newRecord = false;
  bool _unlockedNext = false;

  @override
  void initState() {
    super.initState();
    _startRound(widget.initialLevel);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _round.pause();
  }

  void _startRound(StarGameLevel level) {
    _level = level;
    _result = null;
    _newRecord = false;
    _unlockedNext = false;
    _round = StarGameRound(
      questions: buildStarGameQuestions(level),
      onFinish: (result) {
        final next = level.next;
        final wasLocked = next != null && !widget.progress.isUnlocked(next);
        _result = result;
        _newRecord = widget.progress.record(level, result);
        _unlockedNext = wasLocked && widget.progress.isUnlocked(next);
      },
    );
  }

  void _restart(StarGameLevel level) {
    _round.dispose();
    setState(() => _startRound(level));
  }

  void _answer(int choice) {
    if (!_round.answer(
      choice,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    )) {
      return;
    }
    HapticFeedback.selectionClick();
  }

  void _exit() => Navigator.of(context).pop();

  Widget _buildStage(double height) {
    if (_round.paused) {
      return _PauseView(onResume: _round.resume, onExit: _exit);
    }
    final result = _result;
    if (result == null) {
      return StarGamePlayView(
        level: _level,
        round: _round,
        height: height,
        onPause: _round.pause,
        onAnswer: _answer,
      );
    }

    final next = _level.next;
    return ListenableBuilder(
      listenable: widget.progress,
      builder: (context, _) => StarGameResultView(
        level: _level,
        result: result,
        best: widget.progress.best(_level) ?? result,
        newRecord: _newRecord,
        unlockedNext: _unlockedNext,
        onNext:
            next != null && result.stars > 0 && widget.progress.isUnlocked(next)
            ? () => _restart(next)
            : null,
        onReplay: () => _restart(_level),
        onExit: _exit,
        onRetrySave: widget.progress.saveFailed
            ? widget.progress.retrySave
            : null,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _round.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _round,
    builder: (context, _) => PopScope<void>(
      canPop: _round.phase == StarGamePhase.result,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _round.pause();
      },
      child: Scaffold(
        backgroundColor: starGameInk,
        body: StarGameSky(
          backdrop: _result == null
              ? const StarGamePlayBackdrop()
              : const StarGameBackdrop(),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = (constraints.maxHeight - 32).clamp(
                  0.0,
                  double.infinity,
                );
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 460,
                        minHeight: height,
                      ),
                      child: _buildStage(height),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

class _PauseView extends StatelessWidget {
  const _PauseView({required this.onResume, required this.onExit});

  final VoidCallback onResume;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: starGamePanel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: starGameLine),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.pause_circle_filled_rounded,
            color: starGameGold,
            size: 55,
          ),
          const SizedBox(height: 10),
          Text(
            context.getText(AppKeys.gamesPaused),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          StarGameButton(
            label: context.getText(AppKeys.gamesResume),
            icon: Icons.play_arrow_rounded,
            onPressed: onResume,
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onExit,
            style: TextButton.styleFrom(foregroundColor: starGameMuted),
            child: Text(context.getText(AppKeys.gamesBackToMap)),
          ),
        ],
      ),
    ),
  );
}
