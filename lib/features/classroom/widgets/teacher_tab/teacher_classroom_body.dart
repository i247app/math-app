import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/widgets/teacher_tab/teacher_classroom_add_button.dart';
import 'package:numi/features/classroom/widgets/teacher_tab/teacher_classroom_empty_state.dart';
import 'package:numi/features/classroom/widgets/teacher_tab/teacher_classroom_list_card.dart';
import 'package:numi/features/classroom/widgets/teacher_tab/teacher_classroom_search_field.dart';

class TeacherClassroomBody extends StatelessWidget {
  const TeacherClassroomBody({
    super.key,
    required this.scale,
    required this.error,
    required this.classrooms,
    required this.displayedClassrooms,
    required this.searchController,
    required this.entranceBuilder,
    required this.onCreateClass,
    required this.onOpenClassDetail,
  });

  final double scale;
  final String? error;
  final List<ClassroomModel> classrooms;
  final List<ClassroomModel> displayedClassrooms;
  final TextEditingController searchController;
  final Widget Function(int order, Widget child, bool markOnEnd)
  entranceBuilder;
  final VoidCallback onCreateClass;
  final ValueChanged<ClassroomModel> onOpenClassDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        entranceBuilder(
          0,
          TeacherClassroomAddButton(scale: scale, onTap: onCreateClass),
          false,
        ),
        SizedBox(height: 16 * scale),
        entranceBuilder(
          1,
          TeacherClassroomSearchField(
            scale: scale,
            controller: searchController,
          ),
          false,
        ),
        SizedBox(height: 24 * scale),
        if (error != null && classrooms.isEmpty)
          entranceBuilder(
            2,
            TeacherClassroomEmptyState(scale: scale, message: error!),
            true,
          )
        else if (classrooms.isEmpty)
          entranceBuilder(
            2,
            TeacherClassroomEmptyState(
              scale: scale,
              message: context.getText(AppKeys.teacherEmptyClassroomList),
            ),
            true,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: displayedClassrooms.length,
            separatorBuilder: (_, _) => SizedBox(height: 16 * scale),
            itemBuilder: (context, index) {
              final classroom = displayedClassrooms[index];
              return entranceBuilder(
                2 + index,
                TeacherClassroomListCard(
                  scale: scale,
                  classroom: classroom,
                  onTap: () => onOpenClassDetail(classroom),
                ),
                index == displayedClassrooms.length - 1,
              );
            },
          ),
      ],
    );
  }
}
