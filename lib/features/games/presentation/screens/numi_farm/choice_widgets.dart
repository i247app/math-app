part of '../numi_farm_stage_screen.dart';

class _FarmChoicePrompt extends StatelessWidget {
  const _FarmChoicePrompt({
    required this.promptKey,
    required this.isSolved,
    required this.isWrong,
  });

  final String promptKey;
  final bool isSolved;
  final bool isWrong;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: isSolved
            ? const Color(0xFFE7F7DF)
            : isWrong
            ? const Color(0xFFFFEEEE)
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSolved
              ? _farmLeaf.withValues(alpha: 0.45)
              : isWrong
              ? const Color(0xFFE53935)
              : _farmGreen.withValues(alpha: 0.10),
          width: isWrong ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Image.asset(
              'assets/images/welcome-numi-character.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.getText(
                isSolved
                    ? AppKeys.gamesFarmCorrect
                    : isWrong
                    ? AppKeys.gamesFarmIncorrect
                    : promptKey,
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
            children: List.generate(count, (_) => const _MiniProduce()),
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
    required this.isWrong,
    required this.onSelected,
  });

  final List<String> choices;
  final String correctAnswer;
  final String? selectedAnswer;
  final bool isSolved;
  final bool isWrong;
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
              isWrong: isWrong && selectedAnswer == choices[index],
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
    required this.isWrong,
    required this.onTap,
  });

  final String answer;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isCorrect
        ? _farmLeaf
        : isWrong
        ? const Color(0xFFFFEEEE)
        : isSelected
        ? _farmGreen
        : Colors.white;
    final foreground = isWrong
        ? const Color(0xFFD32F2F)
        : isCorrect || isSelected
        ? Colors.white
        : _farmInk;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWrong ? const Color(0xFFE53935) : Colors.transparent,
          width: isWrong ? 3 : 0,
        ),
      ),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(20),
        elevation: isSelected || isCorrect || isWrong ? 0 : 2,
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
      ),
    );
  }
}
