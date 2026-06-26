part of '../../../home_screen.dart';

class _ParentRoomTaskHeader extends StatelessWidget {
  const _ParentRoomTaskHeader({
    required this.dateLabel,
    required this.childName,
    required this.classroomName,
  });

  final String dateLabel;
  final String? childName;
  final String classroomName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            dateLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B5C62),
              fontSize: FontSize.xs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (childName != null)
          _ParentRoomChip(
            label: childName!,
            color: const Color(0xFFF2F4F6),
            textColor: const Color(0xFF4F5960),
            fontSize: FontSize.xxs,
          ),
        const SizedBox(width: 5),
        _ParentRoomChip(
          label: classroomName,
          color: const Color(0xFFF2F4F6),
          textColor: const Color(0xFF4F5960),
          fontSize: FontSize.xxs,
        ),
      ],
    );
  }
}
