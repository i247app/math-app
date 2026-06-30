part of '../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherHomeworkSearchField extends StatelessWidget {
  const _TeacherHomeworkSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49,
      padding: const EdgeInsets.fromLTRB(26, 0, 18, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: const Color(0xFFCCCCCC).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                color: const Color(0xFFDCBFC8),
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
