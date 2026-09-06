import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_filter.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_filter_chip.dart';

class StudentClassroomExerciseFilterTabs extends StatelessWidget {
  const StudentClassroomExerciseFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  final StudentClassroomExerciseFilter activeFilter;
  final ValueChanged<StudentClassroomExerciseFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: StudentClassroomExerciseFilter.values.length,
        separatorBuilder: (_, _) =>
            const Padding(padding: EdgeInsets.only(right: 8)),
        itemBuilder: (context, index) {
          final filter = StudentClassroomExerciseFilter.values[index];
          return StudentClassroomExerciseFilterChip(
            label: context.getText(filter.labelKey),
            selected: filter == activeFilter,
            onTap: () => onFilterSelected(filter),
          );
        },
      ),
    );
  }
}
