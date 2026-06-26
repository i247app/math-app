part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherStudyClassFilters extends StatelessWidget {
  const _TeacherStudyClassFilters({
    required this.classrooms,
    required this.selectedClassroomId,
    required this.scale,
    required this.onSelected,
  });

  final List<ClassroomModel> classrooms;
  final int? selectedClassroomId;
  final double scale;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: classrooms.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 7 * scale),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _TeacherStudyFilterChip(
              label: context.getText(AppKeys.teacherStudyAllClasses),
              selected: selectedClassroomId == null,
              scale: scale,
              onTap: () => onSelected(null),
            );
          }
          final classroom = classrooms[index - 1];
          final classroomId = classroom.stableId;
          final name = classroom.name?.trim();
          return _TeacherStudyFilterChip(
            label: name?.isNotEmpty == true
                ? name!
                : context.getText(AppKeys.teacherClassFallback),
            selected: classroomId != null && classroomId == selectedClassroomId,
            scale: scale,
            onTap: classroomId == null ? null : () => onSelected(classroomId),
          );
        },
      ),
    );
  }
}
