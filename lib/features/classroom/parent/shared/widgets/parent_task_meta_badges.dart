import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/parent/shared/widgets/parent_task_meta_chip.dart';

class ParentTaskMetaBadges extends StatelessWidget {
  const ParentTaskMetaBadges({
    super.key,
    required this.childName,
    required this.classroomName,
  });

  final String? childName;
  final String classroomName;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final cleanChildName = childName?.trim();
    final cleanClassroom = classroomName.trim();

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: [
        if (cleanChildName?.isNotEmpty == true)
          ParentTaskMetaChip(
            label: cleanChildName!,
            color: colors.infoSurface,
            textColor: colors.textMuted,
            fontSize: FontSize.xxs,
          ),
        if (cleanClassroom.isNotEmpty)
          ParentTaskMetaChip(
            label: cleanClassroom,
            color: colors.infoSurface,
            textColor: colors.textMuted,
            fontSize: FontSize.xxs,
          ),
      ],
    );
  }
}
