import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/home/widgets/parent_teacher_message_item.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_empty_task_line.dart';

class ParentTeacherMessagesList extends StatelessWidget {
  const ParentTeacherMessagesList({required this.summaries});

  final List<ParentChildSummary> summaries;

  @override
  Widget build(BuildContext context) {
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
            const Divider(height: 24, color: Color(0xFFE9EEF2)),
        ],
      ],
    );
  }
}