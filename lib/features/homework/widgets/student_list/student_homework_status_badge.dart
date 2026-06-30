part of '../../presentation/student_homework_screen.dart';

class _StudentHomeworkStatusBadge extends StatelessWidget {
  const _StudentHomeworkStatusBadge({required this.exercise});

  final ClassroomExercise exercise;

  @override
  Widget build(BuildContext context) {
    final submitted = _studentHomeworkIsSubmitted(exercise);
    final overdue = _studentHomeworkIsOverdue(exercise);
    final labelKey = submitted
        ? AppKeys.studentHomeworkSubmitted
        : overdue
        ? AppKeys.studentHomeworkOverdue
        : AppKeys.studentHomeworkNotSubmitted;
    final color = submitted
        ? const Color(0xFF2E7D32)
        : overdue
        ? const Color(0xFFC2410C)
        : _studentHomeworkTeal;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          context.getText(labelKey),
          maxLines: 1,
          style: GoogleFonts.andika(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 16 / 12,
          ),
        ),
      ),
    );
  }
}
