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
    required this.error,
    required this.classrooms,
    required this.displayedClassrooms,
    required this.searchController,
    required this.entranceBuilder,
    required this.onCreateClass,
    required this.onOpenClassDetail,
  });
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
          TeacherClassroomAddButton(onTap: onCreateClass),
          false,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: entranceBuilder(
            1,
            TeacherClassroomSearchField(controller: searchController),
            false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: error != null && classrooms.isEmpty
              ? entranceBuilder(
                  2,
                  TeacherClassroomEmptyState(message: error!),
                  true,
                )
              : classrooms.isEmpty
              ? entranceBuilder(
                  2,
                  TeacherClassroomEmptyState(
                    message: context.getText(AppKeys.teacherEmptyClassroomList),
                  ),
                  true,
                )
              : displayedClassrooms.isEmpty
              ? TeacherClassroomEmptyState(
                  message: context.getText(AppKeys.teacherStudyNoResults),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: displayedClassrooms.length,
                  itemBuilder: (context, index) {
                    final classroom = displayedClassrooms[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == displayedClassrooms.length - 1
                            ? 0
                            : 16,
                      ),
                      child: entranceBuilder(
                        2 + index,
                        TeacherClassroomListCard(
                          classroom: classroom,
                          onTap: () => onOpenClassDetail(classroom),
                        ),
                        index == displayedClassrooms.length - 1,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
