import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/games/numi_farm/numi_farm_data.dart';

const _farmGreen = Color(0xFF38898B);
const _farmDeepGreen = Color(0xFF176B55);
const _farmLeaf = Color(0xFF65B83C);
const _farmOrange = Color(0xFFF58B32);
const _farmInk = Color(0xFF253228);
const _farmMuted = Color(0xFF68746B);
const _farmCream = Color(0xFFFFFBEE);
const _farmSoil = Color(0xFF9B653D);

class NumiFarmHarvestStageScreen extends StatefulWidget {
  const NumiFarmHarvestStageScreen({
    super.key,
    required this.stage,
  }) : assert(stage == 1 || stage == 2);

  final int stage;

  @override
  State<NumiFarmHarvestStageScreen> createState() =>
      _NumiFarmHarvestStageScreenState();
}

class _NumiFarmHarvestStageScreenState
    extends State<NumiFarmHarvestStageScreen> {
  late final List<NumiFarmCountRound> _rounds =
      buildHarvestRounds(widget.stage);
  final Set<int> _pickedCarrots = <int>{};
  int _roundIndex = 0;
  int _mistakes = 0;
  int _feedbackTick = 0;
  bool _isSolved = false;

  NumiFarmCountRound get _round => _rounds[_roundIndex];

  void _toggleCarrot(int index) {
    if (_isSolved) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      if (!_pickedCarrots.add(index)) {
        _pickedCarrots.remove(index);
      }
    });
  }

  void _checkAnswer() {
    if (_pickedCarrots.isEmpty || _isSolved) {
      HapticFeedback.selectionClick();
      return;
    }

    if (_pickedCarrots.length == _round.target) {
      HapticFeedback.mediumImpact();
      setState(() => _isSolved = true);
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _mistakes++;
      _feedbackTick++;
    });
  }

  Future<void> _continue() async {
    if (!_isSolved) {
      _checkAnswer();
      return;
    }

    if (_roundIndex < _rounds.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _roundIndex++;
        _pickedCarrots.clear();
        _isSolved = false;
        _feedbackTick = 0;
      });
      return;
    }

    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: _farmInk.withValues(alpha: 0.42),
      builder: (_) => _FarmStageCompleteDialog(
        stars: _earnedStars,
        stage: widget.stage,
      ),
    );
    if (completed == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  int get _earnedStars {
    if (_mistakes == 0) {
      return 3;
    }
    if (_mistakes <= 2) {
      return 2;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_roundIndex + 1) / _rounds.length;
    return Scaffold(
      backgroundColor: _farmCream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 690;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                compact ? 10 : 16,
                18,
                14,
              ),
              child: Column(
                children: [
                  _FarmHeader(
                    round: _roundIndex + 1,
                    roundCount: _rounds.length,
                    progress: progress,
                    stageTitleKey: numiFarmStage(widget.stage).titleKey,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  _FarmOrderCard(
                    target: _round.target,
                    feedbackTick: _feedbackTick,
                    isSolved: _isSolved,
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
                    isLastRound: _roundIndex == _rounds.length - 1,
                    onPressed: _continue,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FarmHeader extends StatelessWidget {
  const _FarmHeader({
    required this.round,
    required this.roundCount,
    required this.progress,
    required this.stageTitleKey,
    required this.onBack,
  });

  final int round;
  final int roundCount;
  final double progress;
  final String stageTitleKey;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: _farmDeepGreen.withValues(alpha: 0.16),
              child: InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: _farmDeepGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.getText(AppKeys.gamesFarmTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _farmInk,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    context.getText(stageTitleKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _farmMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: _farmGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$round/$roundCount',
                style: const TextStyle(
                  color: _farmDeepGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: _farmGreen.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation(_farmGreen),
          ),
        ),
      ],
    );
  }
}

class _FarmOrderCard extends StatelessWidget {
  const _FarmOrderCard({
    required this.target,
    required this.feedbackTick,
    required this.isSolved,
    required this.compact,
  });

  final int target;
  final int feedbackTick;
  final bool isSolved;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(feedbackTick),
      tween: Tween(begin: feedbackTick == 0 ? 0 : 1, end: 0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(math.sin(value * math.pi * 5) * 7 * value, 0),
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding:
            EdgeInsets.fromLTRB(14, compact ? 10 : 14, 18, compact ? 10 : 14),
        decoration: BoxDecoration(
          color: isSolved ? const Color(0xFFE7F7DF) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSolved
                ? _farmLeaf.withValues(alpha: 0.45)
                : _farmGreen.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: _farmDeepGreen.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: compact ? 62 : 76,
              height: compact ? 62 : 76,
              child: Image.asset(
                'assets/images/welcome_numi_character.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSolved
                        ? context.getText(AppKeys.gamesFarmCorrect)
                        : context.getText(AppKeys.gamesFarmOrderLabel),
                    style: TextStyle(
                      color: isSolved ? _farmDeepGreen : _farmMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: isSolved
                              ? context.getText(AppKeys.gamesFarmBasketReady)
                              : context.getText(AppKeys.gamesFarmHarvestPrefix),
                        ),
                        if (!isSolved)
                          TextSpan(
                            text: ' $target ',
                            style: const TextStyle(
                              color: _farmOrange,
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        if (!isSolved)
                          TextSpan(
                            text: context.getText(
                              AppKeys.gamesFarmHarvestSuffix,
                            ),
                          ),
                      ],
                    ),
                    style: const TextStyle(
                      color: _farmInk,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmField extends StatelessWidget {
  const _FarmField({
    required this.itemCount,
    required this.pickedCarrots,
    required this.onCarrotTap,
  });

  final int itemCount;
  final Set<int> pickedCarrots;
  final ValueChanged<int> onCarrotTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F6D4), Color(0xFFD5EDB8)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _farmLeaf.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: _farmDeepGreen.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 310 ? 3 : 4;
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) => _CarrotPlot(
              isPicked: pickedCarrots.contains(index),
              onTap: () => onCarrotTap(index),
            ),
          );
        },
      ),
    );
  }
}

class _CarrotPlot extends StatelessWidget {
  const _CarrotPlot({required this.isPicked, required this.onTap});

  final bool isPicked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isPicked,
      label: context.getText(AppKeys.gamesFarmCarrot),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isPicked
                  ? Colors.white.withValues(alpha: 0.38)
                  : Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPicked
                    ? _farmGreen.withValues(alpha: 0.36)
                    : Colors.white.withValues(alpha: 0.72),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
              child: isPicked
                  ? const _PickedCarrotSpot(key: ValueKey('picked'))
                  : const _CarrotIllustration(key: ValueKey('carrot')),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickedCarrotSpot extends StatelessWidget {
  const _PickedCarrotSpot({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52,
          height: 20,
          decoration: BoxDecoration(
            color: _farmSoil.withValues(alpha: 0.44),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: _farmGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 23),
        ),
      ],
    );
  }
}

class _CarrotIllustration extends StatelessWidget {
  const _CarrotIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: CustomPaint(
        painter: _CarrotPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _CarrotPainter extends CustomPainter {
  const _CarrotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.36);
    final leafPaint = Paint()..color = _farmLeaf;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (final angle in <double>[-0.55, -0.18, 0.18, 0.55]) {
      canvas.save();
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -size.height * 0.18),
            width: size.width * 0.16,
            height: size.height * 0.38,
          ),
          Radius.circular(size.width * 0.08),
        ),
        leafPaint,
      );
      canvas.restore();
    }
    canvas.restore();

    final carrotPath = Path()
      ..moveTo(size.width * 0.29, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.29,
        size.width * 0.71,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.63,
        size.height * 0.76,
        size.width * 0.50,
        size.height * 0.92,
      )
      ..quadraticBezierTo(
        size.width * 0.37,
        size.height * 0.76,
        size.width * 0.29,
        size.height * 0.38,
      )
      ..close();
    canvas.drawPath(carrotPath, Paint()..color = _farmOrange);

    final detailPaint = Paint()
      ..color = const Color(0xFFE36C22)
      ..strokeWidth = math.max(1.5, size.width * 0.025)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.51 + i * 0.11);
      canvas.drawLine(
        Offset(size.width * 0.40, y),
        Offset(size.width * 0.55, y + size.height * 0.025),
        detailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CarrotPainter oldDelegate) => false;
}

class _FarmBottomBar extends StatelessWidget {
  const _FarmBottomBar({
    required this.picked,
    required this.target,
    required this.isSolved,
    required this.isLastRound,
    required this.onPressed,
  });

  final int picked;
  final int target;
  final bool isSolved;
  final bool isLastRound;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 112),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _farmGreen.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_basket_rounded, color: _farmOrange),
              const SizedBox(width: 8),
              Text(
                '$picked/$target',
                style: const TextStyle(
                  color: _farmInk,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: picked == 0 ? null : onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: isSolved ? _farmLeaf : _farmGreen,
              disabledBackgroundColor: _farmGreen.withValues(alpha: 0.16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isSolved
                  ? context.getText(
                      isLastRound
                          ? AppKeys.gamesFarmFinish
                          : AppKeys.gamesFarmNext,
                    )
                  : context.getText(AppKeys.gamesFarmCheck),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NumiFarmChoiceStageScreen extends StatefulWidget {
  const NumiFarmChoiceStageScreen({
    super.key,
    required this.stage,
  }) : assert(stage >= 3 && stage <= 5);

  final int stage;

  @override
  State<NumiFarmChoiceStageScreen> createState() =>
      _NumiFarmChoiceStageScreenState();
}

class _NumiFarmChoiceStageScreenState extends State<NumiFarmChoiceStageScreen> {
  late final List<NumiFarmChoiceRound> _rounds =
      buildChoiceRounds(widget.stage);
  int _roundIndex = 0;
  int _mistakes = 0;
  int _feedbackTick = 0;
  String? _selectedAnswer;
  bool _isSolved = false;

  NumiFarmChoiceRound get _round => _rounds[_roundIndex];

  void _selectAnswer(String answer) {
    if (_isSolved) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedAnswer = answer);
  }

  void _checkAnswer() {
    if (_selectedAnswer == null || _isSolved) {
      HapticFeedback.selectionClick();
      return;
    }
    if (_selectedAnswer == _round.answer) {
      HapticFeedback.mediumImpact();
      setState(() => _isSolved = true);
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _mistakes++;
      _feedbackTick++;
    });
  }

  Future<void> _continue() async {
    if (!_isSolved) {
      _checkAnswer();
      return;
    }
    if (_roundIndex < _rounds.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _roundIndex++;
        _selectedAnswer = null;
        _isSolved = false;
        _feedbackTick = 0;
      });
      return;
    }

    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: _farmInk.withValues(alpha: 0.42),
      builder: (_) => _FarmStageCompleteDialog(
        stars: _earnedStars,
        stage: widget.stage,
      ),
    );
    if (completed == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  int get _earnedStars {
    if (_mistakes == 0) {
      return 3;
    }
    if (_mistakes <= 2) {
      return 2;
    }
    return 1;
  }

  String get _promptKey => switch (_round.kind) {
        NumiFarmChoiceKind.comparison => AppKeys.gamesFarmComparePrompt,
        NumiFarmChoiceKind.addition => AppKeys.gamesFarmAdditionPrompt,
        NumiFarmChoiceKind.subtraction => AppKeys.gamesFarmSubtractionPrompt,
      };

  @override
  Widget build(BuildContext context) {
    final progress = (_roundIndex + 1) / _rounds.length;
    return Scaffold(
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
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  SizedBox(height: compact ? 12 : 18),
                  _FarmChoicePrompt(
                    promptKey: _promptKey,
                    isSolved: _isSolved,
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(_feedbackTick),
                      tween: Tween(
                        begin: _feedbackTick == 0 ? 0 : 1,
                        end: 0,
                      ),
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
                    onSelected: _selectAnswer,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _selectedAnswer == null ? null : _continue,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: _isSolved ? _farmLeaf : _farmGreen,
                      disabledBackgroundColor:
                          _farmGreen.withValues(alpha: 0.16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _isSolved
                          ? context.getText(
                              _roundIndex == _rounds.length - 1
                                  ? AppKeys.gamesFarmFinish
                                  : AppKeys.gamesFarmNext,
                            )
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
  }
}

class _FarmChoicePrompt extends StatelessWidget {
  const _FarmChoicePrompt({
    required this.promptKey,
    required this.isSolved,
  });

  final String promptKey;
  final bool isSolved;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: isSolved ? const Color(0xFFE7F7DF) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSolved
              ? _farmLeaf.withValues(alpha: 0.45)
              : _farmGreen.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Image.asset(
              'assets/images/welcome_numi_character.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.getText(
                isSolved ? AppKeys.gamesFarmCorrect : promptKey,
              ),
              style: const TextStyle(
                color: _farmInk,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmChoiceChallenge extends StatelessWidget {
  const _FarmChoiceChallenge({required this.round});

  final NumiFarmChoiceRound round;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F6D4), Color(0xFFD5EDB8)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _farmLeaf.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: _farmDeepGreen.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: round.kind == NumiFarmChoiceKind.comparison
          ? _ComparisonChallenge(round: round)
          : _EquationChallenge(round: round),
    );
  }
}

class _ComparisonChallenge extends StatelessWidget {
  const _ComparisonChallenge({required this.round});

  final NumiFarmChoiceRound round;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ProduceBasket(count: round.left)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '?',
              style: TextStyle(
                color: _farmGreen,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        Expanded(child: _ProduceBasket(count: round.right)),
      ],
    );
  }
}

class _EquationChallenge extends StatelessWidget {
  const _EquationChallenge({required this.round});

  final NumiFarmChoiceRound round;

  @override
  Widget build(BuildContext context) {
    final operation = round.kind == NumiFarmChoiceKind.addition ? '+' : '−';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(child: _ProduceBasket(count: round.left)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                operation,
                style: const TextStyle(
                  color: _farmDeepGreen,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(child: _ProduceBasket(count: round.right)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            '${round.left} $operation ${round.right} = ?',
            style: const TextStyle(
              color: _farmInk,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProduceBasket extends StatelessWidget {
  const _ProduceBasket({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 3,
            runSpacing: 3,
            children: List.generate(
              count,
              (_) => const _MiniProduce(),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFC98742),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF9C602D), width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniProduce extends StatelessWidget {
  const _MiniProduce();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 23,
      height: 28,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: _farmOrange,
              shape: BoxShape.circle,
            ),
          ),
          const Positioned(
            top: 0,
            child: Icon(Icons.eco_rounded, color: _farmLeaf, size: 14),
          ),
        ],
      ),
    );
  }
}

class _FarmAnswerChoices extends StatelessWidget {
  const _FarmAnswerChoices({
    required this.choices,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.isSolved,
    required this.onSelected,
  });

  final List<String> choices;
  final String correctAnswer;
  final String? selectedAnswer;
  final bool isSolved;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < choices.length; index++) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(
            child: _FarmAnswerButton(
              answer: choices[index],
              isSelected: selectedAnswer == choices[index],
              isCorrect: isSolved && choices[index] == correctAnswer,
              onTap: () => onSelected(choices[index]),
            ),
          ),
        ],
      ],
    );
  }
}

class _FarmAnswerButton extends StatelessWidget {
  const _FarmAnswerButton({
    required this.answer,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  final String answer;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isCorrect
        ? _farmLeaf
        : isSelected
            ? _farmGreen
            : Colors.white;
    final foreground = isCorrect || isSelected ? Colors.white : _farmInk;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      elevation: isSelected || isCorrect ? 0 : 2,
      shadowColor: _farmDeepGreen.withValues(alpha: 0.14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 64,
          child: Center(
            child: Text(
              answer,
              style: TextStyle(
                color: foreground,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FarmStageCompleteDialog extends StatelessWidget {
  const _FarmStageCompleteDialog({
    required this.stars,
    required this.stage,
  });

  final int stars;
  final int stage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: Image.asset(
                'assets/images/welcome_numi_character.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.getText(AppKeys.gamesFarmCompleteTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _farmInk,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.formatText(
                AppKeys.gamesFarmCompleteMessage,
                {'stage': stage},
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _farmMuted,
                fontSize: FontSize.normal,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star_rounded,
                    color: index < stars
                        ? const Color(0xFFFFC21C)
                        : const Color(0xFFE2E6E3),
                    size: 42,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: _farmGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                context.getText(AppKeys.gamesFarmBackToMap),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
