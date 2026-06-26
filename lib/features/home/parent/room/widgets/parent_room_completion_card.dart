part of '../../../home_screen.dart';

// ignore: unused_element
class _ParentRoomCompletionCard extends StatelessWidget {
  const _ParentRoomCompletionCard({
    required this.completion,
    required this.onTap,
    // ignore: unused_element_parameter
    this.compact = false,
  });

  final HomeLayoutRecentCompletion completion;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final exercise = completion.exercise;
    final title = _roomExerciseTitle(context, exercise);
    final childName = completion.child == null
        ? null
        : homeProfileDisplayName(context, completion.child!);
    final classroomName = _roomClassName(context, completion.classroom);
    final purpose = _roomPurposeLabel(context, exercise?.purpose);
    final accent = _roomScoreAccent(completion.scorePercentage);
    final dateLabel = _roomDateLabel(
      completion.gradedDt ?? completion.submittedDt ?? exercise?.createDt,
    );
    final score = ((completion.scorePercentage ?? 0) / 10).round().clamp(0, 10);

    return _ParentRoomTaskShell(
      accent: accent,
      compact: compact,
      onTap: onTap,
      leading: _ParentTaskScoreRing(score: score, color: accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ParentRoomTaskHeader(
            dateLabel: dateLabel,
            childName: childName,
            classroomName: classroomName,
          ),
          const SizedBox(height: 9),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF121B42),
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 7),
          _ParentTaskMetaChip(
            label: purpose,
            color: accent.withValues(alpha: 0.13),
            textColor: accent,
            fontSize: FontSize.xxs,
          ),
        ],
      ),
    );
  }
}
