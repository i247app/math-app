part of '../../../home_screen.dart';

class _ParentCompletedTaskListItem extends StatelessWidget {
  const _ParentCompletedTaskListItem({
    required this.completion,
    required this.onTap,
  });

  final HomeLayoutRecentCompletion completion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exercise = completion.exercise;
    final score = ((completion.scorePercentage ?? 0) / 10).round().clamp(0, 10);
    final color = score >= 8
        ? const Color(0xFF07824C)
        : const Color(0xFFFF6B17);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            _ParentTaskScoreRing(score: score, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _ParentTaskMetaBadges(
                          childName: completion.child == null
                              ? null
                              : homeProfileDisplayName(
                                  context,
                                  completion.child!,
                                ),
                          classroomName: _roomClassName(
                            context,
                            completion.classroom,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ParentTaskDateLabel(
                        date: _roomDateOnlyLabel(
                          completion.gradedDt ??
                              completion.submittedDt ??
                              completion.exercise?.createDt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _ParentTaskTitle(
                    title: _roomExerciseTitle(context, exercise),
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
