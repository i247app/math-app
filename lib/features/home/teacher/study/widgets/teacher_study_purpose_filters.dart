part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherStudyPurposeFilters extends StatelessWidget {
  const _TeacherStudyPurposeFilters({
    required this.selectedPurpose,
    required this.scale,
    required this.onSelected,
  });

  final String selectedPurpose;
  final double scale;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TeacherStudyFilterChip(
          label: context.getText(AppKeys.teacherAssignments),
          selected: selectedPurpose == classroomExercisePurposeHomework,
          scale: scale,
          onTap: () => onSelected(classroomExercisePurposeHomework),
        ),
        SizedBox(width: 8 * scale),
        _TeacherStudyFilterChip(
          label: context.getText(AppKeys.teacherAssessments),
          selected: selectedPurpose == classroomExercisePurposeExam,
          scale: scale,
          onTap: () => onSelected(classroomExercisePurposeExam),
        ),
      ],
    );
  }
}
