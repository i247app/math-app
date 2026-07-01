part of '../home_screen.dart';

class _HomeAssessmentResultCard extends StatelessWidget {
  const _HomeAssessmentResultCard({required this.quiz, required this.onTap});

  final GeneratedQuiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (quiz.grading?.scorePercentage ?? 0).clamp(0, 100);
    final score = (percent / 10).round();
    final scoreColor = score >= 8
        ? const Color(0xFF087D47)
        : const Color(0xFFFF6B17);
    final shortText = _homeQuizShortText(quiz);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.fromLTRB(18, 14, 13, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE9E4E4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: math.max(percent / 100, 0.08),
                      strokeWidth: 5,
                      backgroundColor: scoreColor.withValues(alpha: 0.12),
                      color: scoreColor,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: FontSize.xxxl,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF575757),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _homeQuizDateLabel(quiz),
                          style: const TextStyle(
                            color: Color(0xFF595959),
                            fontSize: FontSize.caption,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _homeQuizTitle(context, quiz),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: FontSize.normal,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    if (shortText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        shortText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6D5C58),
                          fontSize: FontSize.small,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8DA4BD),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
