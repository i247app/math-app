part of '../numi_farm_stage_screen.dart';

class NumiFarmHarvestStageScreen extends StatefulWidget {
  const NumiFarmHarvestStageScreen({super.key, required this.stage})
    : assert(stage == 1 || stage == 2);

  final int stage;

  @override
  State<NumiFarmHarvestStageScreen> createState() =>
      _NumiFarmHarvestStageScreenState();
}

class _NumiFarmHarvestStageScreenState extends State<NumiFarmHarvestStageScreen>
    with _FarmSessionMixin<NumiFarmHarvestStageScreen> {
  late final List<NumiFarmCountRound> _rounds = buildHarvestRounds(
    widget.stage,
  );
  final Set<int> _pickedCarrots = <int>{};
  int _roundIndex = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _feedbackTick = 0;
  bool _isSolved = false;
  bool _isWrong = false;

  NumiFarmCountRound get _round => _rounds[_roundIndex];

  @override
  void initState() {
    super.initState();
    startFarmSession();
  }

  @override
  void dispose() {
    disposeFarmSession();
    super.dispose();
  }

  void _toggleCarrot(int index) {
    if (_isSolved || _isWrong) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      if (!_pickedCarrots.add(index)) {
        _pickedCarrots.remove(index);
      }
    });
  }

  Future<void> _checkAnswer() async {
    if (_pickedCarrots.isEmpty || _isSolved) {
      HapticFeedback.selectionClick();
      return;
    }

    if (_pickedCarrots.length == _round.target) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isSolved = true;
        _correctAnswers++;
      });
      await playCorrectSound();
      await Future<void>.delayed(const Duration(milliseconds: 520));
      if (mounted) {
        await _advanceAfterAnswer();
      }
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _wrongAnswers++;
      _isWrong = true;
      _feedbackTick++;
    });
    await playIncorrectSound();
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      await _advanceAfterAnswer();
    }
  }

  Future<void> _advanceAfterAnswer() async {
    if (_roundIndex < _rounds.length - 1) {
      setState(() {
        _roundIndex++;
        _pickedCarrots.clear();
        _isSolved = false;
        _isWrong = false;
        _feedbackTick = 0;
      });
      return;
    }

    stopFarmSession();
    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: _farmInk.withValues(alpha: 0.42),
      builder: (_) => _FarmStageCompleteDialog(
        stars: _earnedStars,
        stage: widget.stage,
        elapsed: elapsed,
        correctAnswers: _correctAnswers,
        wrongAnswers: _wrongAnswers,
      ),
    );
    if (completed == true && mounted) {
      await farmExitController.exitWithResult(true);
    }
  }

  int get _earnedStars {
    return _starsForScore(correct: _correctAnswers, total: _rounds.length);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_roundIndex + 1) / _rounds.length;
    final screen = Scaffold(
      backgroundColor: _farmCream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 690;
            return Padding(
              padding: EdgeInsets.fromLTRB(18, compact ? 10 : 16, 18, 14),
              child: Column(
                children: [
                  _FarmHeader(
                    round: _roundIndex + 1,
                    roundCount: _rounds.length,
                    progress: progress,
                    stageTitleKey: numiFarmStage(widget.stage).titleKey,
                    elapsed: elapsed,
                    onBack: farmExitController.requestExit,
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  _FarmOrderCard(
                    target: _round.target,
                    feedbackTick: _feedbackTick,
                    isSolved: _isSolved,
                    isWrong: _isWrong,
                    compact: compact,
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  Expanded(
                    child: _FarmField(
                      itemCount: _round.fieldItemCount,
                      pickedCarrots: _pickedCarrots,
                      onCarrotTap: _toggleCarrot,
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  _FarmBottomBar(
                    picked: _pickedCarrots.length,
                    target: _round.target,
                    isSolved: _isSolved,
                    isWrong: _isWrong,
                    onPressed: _checkAnswer,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    return GuardedExitScope<bool>(
      controller: farmExitController,
      shouldConfirm: true,
      confirmExit: confirmFarmExit,
      exitResult: false,
      child: screen,
    );
  }
}
