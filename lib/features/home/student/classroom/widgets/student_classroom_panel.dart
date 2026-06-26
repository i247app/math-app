part of '../../../home_screen.dart';

class _StudentClassroomPanel extends StatelessWidget {
  const _StudentClassroomPanel({
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
          child: _StudentJoinClassroomButton(
            scale: scale,
            onTap: onJoinClassroom,
          ),
        ),
        SizedBox(height: 14 * scale),
        if (isLoading && classrooms.isEmpty)
          _StudentLoadingPanel(scale: scale)
        else if (error != null && classrooms.isEmpty)
          _StudentErrorPanel(
            scale: scale,
            message: error!,
            onRetry: onRetry,
          )
        else if (classrooms.isEmpty)
          _StudentEmptyPanel(
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
                _StudentClassroomCard(
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
