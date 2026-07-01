part of '../../presentation/quiz_review_screen.dart';

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.quiz});

  final GeneratedQuiz quiz;

  @override
  Widget build(BuildContext context) {
    final total = quiz.grading?.totalQuestions ?? quiz.questions.length;
    final correct = quiz.grading?.correctNumber ?? _computedCorrectCount(quiz);
    final wrong = total > correct ? total - correct : 0;
    final time = _timeLabel(quiz);

    return _ReviewCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(
            icon: Icons.quiz_outlined,
            iconColor: _teal,
            iconBackground: const Color(0xFFDDF1FF),
            valueColor: _teal,
            value: '$total',
            label: context.getText(AppKeys.totalQuestions),
          ),
          _StatItem(
            icon: Icons.check_circle_outline_rounded,
            iconColor: _teal,
            iconBackground: _tealSoft,
            valueColor: _teal,
            value: '$correct',
            label: context.getText(AppKeys.correct),
          ),
          _StatItem(
            icon: Icons.cancel_outlined,
            iconColor: _red,
            iconBackground: const Color(0xFFFFDCDD),
            valueColor: _red,
            value: '$wrong',
            label: context.getText(AppKeys.incorrect),
          ),
          _StatItem(
            icon: Icons.schedule_rounded,
            iconColor: _orange,
            iconBackground: const Color(0xFFFFEAD6),
            valueColor: _orange,
            value: time,
            label: context.getText(AppKeys.time),
          ),
        ],
      ),
    );
  }
}
