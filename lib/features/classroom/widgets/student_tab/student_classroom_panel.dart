import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/widgets/student_tab/student_classroom_card.dart';
import 'package:numi/features/classroom/widgets/student_tab/student_join_classroom_button.dart';
import 'package:numi/shared/widgets/app_state_panel.dart';
import 'package:numi/shared/widgets/circular_loading_card.dart';

class StudentClassroomPanel extends StatelessWidget {
  const StudentClassroomPanel({
    super.key,
    required this.classrooms,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onJoinClassroom,
  });
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
          child: StudentJoinClassroomButton(onTap: onJoinClassroom),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: isLoading && classrooms.isEmpty
              ? const CircularLoadingCard()
              : error != null && classrooms.isEmpty
              ? AppStatePanel(
                  icon: Icons.wifi_off_rounded,
                  title: error!,
                  message: context.getText(AppKeys.retry),
                  actionLabel: context.getText(AppKeys.retryUpper),
                  onAction: onRetry,
                )
              : classrooms.isEmpty
              ? AppStatePanel(
                  icon: Icons.groups_rounded,
                  title: context.getText(AppKeys.studentNoClassroomsTitle),
                  message: context.getText(AppKeys.studentNoClassroomsMessage),
                )
              : Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final classroom in classrooms)
                      StudentClassroomCard(classroom: classroom),
                  ],
                ),
        ),
      ],
    );
  }
}
