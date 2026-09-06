part of '../numi_farm_stage_screen.dart';

class NumiFarmChoiceStageScreen extends StatefulWidget {
  const NumiFarmChoiceStageScreen({super.key, required this.stage})
    : assert(stage >= 3 && stage <= 5);

  final int stage;

  @override
  State<NumiFarmChoiceStageScreen> createState() =>
      _NumiFarmChoiceStageScreenState();
}

class _NumiFarmChoiceStageScreenState extends State<NumiFarmChoiceStageScreen>
    with _FarmSessionMixin<NumiFarmChoiceStageScreen> {
  late final List<NumiFarmChoiceRound> _rounds = buildChoiceRounds(
    widget.stage,
  );
  int _roundIndex = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _feedbackTick = 0;
  String? _selectedAnswer;
  bool _isSolved = false;
  bool _isWrong = false;

  NumiFarmChoiceRound get _round => _rounds[_roundIndex];

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

  void _selectAnswer(String answer) {
    if (_isSolved || _isWrong) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedAnswer = answer);
  }

  Future<void> _checkAnswer() async {
    if (_selectedAnswer == null || _isSolved) {
      HapticFeedback.selectionClick();
      return;
    }
    if (_selectedAnswer == _round.answer) {
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
        _selectedAnswer = null;
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

  String get _promptKey => switch (_round.kind) {
    NumiFarmChoiceKind.comparison => AppKeys.gamesFarmComparePrompt,
    NumiFarmChoiceKind.addition => AppKeys.gamesFarmAdditionPrompt,
    NumiFarmChoiceKind.subtraction => AppKeys.gamesFarmSubtractionPrompt,
  };

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
                  SizedBox(height: compact ? 12 : 18),
                  _FarmChoicePrompt(
                    promptKey: _promptKey,
                    isSolved: _isSolved,
                    isWrong: _isWrong,
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(_feedbackTick),
                      tween: Tween(begin: _feedbackTick == 0 ? 0 : 1, end: 0),
                      duration: const Duration(milliseconds: 420),
                      builder: (context, value, child) => Transform.translate(
                        offset: Offset(
                          math.sin(value * math.pi * 5) * 7 * value,
                          0,
                        ),
                        child: child,
                      ),
                      child: _FarmChoiceChallenge(round: _round),
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  _FarmAnswerChoices(
                    choices: _round.choices,
                    correctAnswer: _round.answer,
                    selectedAnswer: _selectedAnswer,
                    isSolved: _isSolved,
                    isWrong: _isWrong,
                    onSelected: _selectAnswer,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _selectedAnswer == null || _isSolved || _isWrong
                        ? null
                        : _checkAnswer,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: _isSolved ? _farmLeaf : _farmGreen,
                      disabledBackgroundColor: _isSolved
                          ? _farmLeaf
                          : _isWrong
                          ? const Color(0xFFE53935)
                          : _farmGreen.withValues(alpha: 0.16),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _isSolved
                          ? context.getText(AppKeys.gamesFarmCorrect)
                          : _isWrong
                          ? context.getText(AppKeys.gamesFarmIncorrect)
                          : context.getText(AppKeys.gamesFarmCheck),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
