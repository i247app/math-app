part of '../../../home_screen.dart';

class _ParentRoomBadgeRow extends StatelessWidget {
  const _ParentRoomBadgeRow({
    required this.childName,
    required this.classroomName,
  });

  final String? childName;
  final String classroomName;

  @override
  Widget build(BuildContext context) {
    final cleanChildName = childName?.trim();
    final cleanClassroom = classroomName.trim();

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: [
        if (cleanChildName?.isNotEmpty == true)
          _ParentRoomChip(
              label: cleanChildName!,
              color: const Color(0xFFEAF7F7),
              textColor: const Color(0xFF7F8FA0),
              fontSize: FontSize.xxs),
        if (cleanClassroom.isNotEmpty)
          _ParentRoomChip(
              label: cleanClassroom,
              color: const Color(0xFFEAF7F7),
              textColor: const Color(0xFF7F8FA0),
              fontSize: FontSize.xxs),
      ],
    );
  }
}
