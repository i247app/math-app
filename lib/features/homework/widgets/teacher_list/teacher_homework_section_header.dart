part of '../../presentation/teacher_homework_screen.dart';

class _TeacherHomeworkSectionHeader extends StatelessWidget {
  const _TeacherHomeworkSectionHeader({required this.purpose});

  final String purpose;

  @override
  Widget build(BuildContext context) {
    final copy = teacherExerciseCopy(purpose);
    return Row(
      children: [
        Expanded(
          child: Text(
            context.getText(copy.createdTitleKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: AppColors.navy900,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 28 / 20,
            ),
          ),
        ),
        SvgPicture.asset(
          'assets/images/teacher_homework_sort.svg',
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        Text(
          context.getText(AppKeys.teacherAssignmentNewest),
          style: GoogleFonts.andika(
            color: const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }
}
