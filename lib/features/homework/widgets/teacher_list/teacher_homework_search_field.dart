part of '../../presentation/teacher_homework_screen.dart';

class _TeacherHomeworkSearchField extends StatelessWidget {
  const _TeacherHomeworkSearchField();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 49,
      padding: const EdgeInsets.fromLTRB(26, 0, 18, 0),
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: colors.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/teacher_homework_search.svg',
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Text(
              context.getText(AppKeys.teacherAssignmentSearchHint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: colors.inputHint,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            'assets/images/teacher_homework_filter.svg',
            width: 18,
            height: 18,
          ),
        ],
      ),
    );
  }
}
