import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_meta_chip.dart';

class ParentTaskMetaBadges extends StatelessWidget {
  const ParentTaskMetaBadges({
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
          ParentTaskMetaChip(
            label: cleanChildName!,
            color: const Color(0xFFEAF7F7),
            textColor: const Color(0xFF7F8FA0),
            fontSize: FontSize.xxs,
          ),
        if (cleanClassroom.isNotEmpty)
          ParentTaskMetaChip(
            label: cleanClassroom,
            color: const Color(0xFFEAF7F7),
            textColor: const Color(0xFF7F8FA0),
            fontSize: FontSize.xxs,
          ),
      ],
    );
  }
}
