import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_task_meta_chip.dart';

class ParentRoomTaskHeader extends StatelessWidget {
  const ParentRoomTaskHeader({
    super.key,
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
          ParentTaskMetaChip(
            label: childName!,
            color: const Color(0xFFF2F4F6),
            textColor: const Color(0xFF4F5960),
            fontSize: FontSize.xxs,
          ),
        const SizedBox(width: 5),
        ParentTaskMetaChip(
          label: classroomName,
          color: const Color(0xFFF2F4F6),
          textColor: const Color(0xFF4F5960),
          fontSize: FontSize.xxs,
        ),
      ],
    );
  }
}
