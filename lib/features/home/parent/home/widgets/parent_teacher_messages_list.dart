import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/home/widgets/parent_teacher_message_item.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_empty_task_line.dart';

class ParentTeacherMessagesList extends StatelessWidget {
  const ParentTeacherMessagesList({super.key, required this.summaries});

  final List<ParentChildSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final visibleSummaries = summaries.take(2).toList(growable: false);
    if (visibleSummaries.isEmpty) {
      return ParentEmptyTaskLine(
        icon: Icons.mail_outline_rounded,
        text: context.getText(AppKeys.homeMessageBodyOne),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < visibleSummaries.length; index++) ...[
          ParentTeacherMessageItem(
            summary: visibleSummaries[index],
            index: index,
          ),
          if (index != visibleSummaries.length - 1)
            Divider(height: 24, color: colors.border),
        ],
      ],
    );
  }
}
