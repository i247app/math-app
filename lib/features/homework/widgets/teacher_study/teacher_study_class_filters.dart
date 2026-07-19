import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/homework/widgets/teacher_study/teacher_study_filter_chip.dart';

class TeacherStudyClassFilters extends StatelessWidget {
  const TeacherStudyClassFilters({
    super.key,
    required this.classrooms,
    required this.selectedClassroomId,
    required this.onSelected,
  });

  final List<ClassroomModel> classrooms;
  final int? selectedClassroomId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: classrooms.length + 1,
        separatorBuilder: (_, _) =>
            const Padding(padding: EdgeInsets.only(right: 7)),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TeacherStudyFilterChip(
              label: context.getText(AppKeys.teacherStudyAllClasses),
              selected: selectedClassroomId == null,
              onTap: () => onSelected(null),
            );
          }
          final classroom = classrooms[index - 1];
          final classroomId = classroom.stableId;
          final name = classroom.name?.trim();
          return TeacherStudyFilterChip(
            label: name?.isNotEmpty == true
                ? name!
                : context.getText(AppKeys.teacherClassFallback),
            selected: classroomId != null && classroomId == selectedClassroomId,
            onTap: classroomId == null ? null : () => onSelected(classroomId),
          );
        },
      ),
    );
  }
}
