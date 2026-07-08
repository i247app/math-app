part of '../../presentation/teacher_homework_screen.dart';

class _TeacherAssignmentCard extends StatelessWidget {
  const _TeacherAssignmentCard({required this.exercise, required this.onTap});

  final ClassroomExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exerciseId = exercise.stableId?.toString() ?? '-';
    final dateParts = teacherExerciseDateParts(exercise.endDate);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 82,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEFF6FF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 48,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateParts.day,
                      style: GoogleFonts.andika(
                        color: AppColors.navy900,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      dateParts.month,
                      style: GoogleFonts.andika(
                        color: const Color(0xFF6B7280),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        teacherExerciseTitle(context, exercise),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: AppColors.navy900,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 17.5 / 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.formatText(AppKeys.teacherAssignmentId, {
                          'id': exerciseId,
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: const Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  'assets/images/teacher_homework_more.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
