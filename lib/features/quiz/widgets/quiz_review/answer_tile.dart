part of '../../presentation/quiz_review_screen.dart';

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.answer,
    required this.selectedLabel,
    required this.correctLabel,
    required this.showCorrectAnswer,
    this.onTap,
  });

  final QuizAnswer answer;
  final String? selectedLabel;
  final String? correctLabel;
  final bool showCorrectAnswer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = answer.label.trim().toUpperCase();
    final isSelected = selectedLabel == label;
    final isCorrect = correctLabel == label;
    final hasSelection = selectedLabel != null;
    final isWrongSelected = hasSelection && isSelected && !isCorrect;
    final isRevealedCorrect = isCorrect && (isSelected || showCorrectAnswer);
    final borderColor = isWrongSelected
        ? _red
        : isRevealedCorrect
        ? _teal
        : _cardBorder;
    final background = isWrongSelected
        ? _redSoft
        : isRevealedCorrect
        ? _tealLight
        : Colors.white;
    final foreground = isWrongSelected || isRevealedCorrect
        ? (isWrongSelected ? _red : _teal)
        : _deepInk;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 59),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isWrongSelected
                      ? _red
                      : isRevealedCorrect
                      ? _green
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWrongSelected || isRevealedCorrect
                        ? Colors.transparent
                        : const Color(0xFF9BB0B3),
                  ),
                ),
                child: _CenteredText(
                  label,
                  color: isWrongSelected || isRevealedCorrect
                      ? Colors.white
                      : _deepInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  verticalOffset: 1.2,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  answer.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 18,
                    fontWeight: isWrongSelected || isRevealedCorrect
                        ? FontWeight.w900
                        : FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (isWrongSelected || isRevealedCorrect)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isWrongSelected ? _red : _teal,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWrongSelected ? Icons.close_rounded : Icons.check_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
