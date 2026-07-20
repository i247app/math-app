import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/widgets/student_tab/student_classroom_card.dart';
import 'package:numi/shared/widgets/student/student_empty_panel.dart';
import 'package:numi/shared/widgets/student/student_error_panel.dart';
import 'package:numi/features/classroom/widgets/student_tab/student_join_classroom_button.dart';
import 'package:numi/shared/widgets/circular_loading_card.dart';

class StudentClassroomPanel extends StatelessWidget {
  const StudentClassroomPanel({
    super.key,
    required this.scale,
    required this.classrooms,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onJoinClassroom,
  });

  final double scale;
  final List<ClassroomModel> classrooms;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onJoinClassroom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: StudentJoinClassroomButton(
            scale: scale,
            onTap: onJoinClassroom,
          ),
        ),
        SizedBox(height: 14 * scale),
        if (isLoading && classrooms.isEmpty)
          CircularLoadingCard(scale: scale)
        else if (error != null && classrooms.isEmpty)
          StudentErrorPanel(message: error!, onRetry: onRetry)
        else if (classrooms.isEmpty)
          StudentEmptyPanel(
            icon: Icons.groups_rounded,
            title: context.getText(AppKeys.studentNoClassroomsTitle),
            message: context.getText(AppKeys.studentNoClassroomsMessage),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < classrooms.length; index++) ...[
                StudentClassroomCard(
                  scale: scale,
                  classroom: classrooms[index],
                ),
                if (index != classrooms.length - 1)
                  SizedBox(height: 12 * scale),
              ],
            ],
          ),
      ],
    );
  }
}
