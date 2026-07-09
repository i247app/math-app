import 'package:flutter/material.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/features/home/student/classroom/widgets/student_classroom_card.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_empty_panel.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_error_panel.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_join_classroom_button.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_loading_panel.dart';
import 'package:numi_flutter/shared/widgets/circular_loading_card.dart';

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
          StudentErrorPanel(scale: scale, message: error!, onRetry: onRetry)
        else if (classrooms.isEmpty)
          StudentEmptyPanel(
            scale: scale,
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
