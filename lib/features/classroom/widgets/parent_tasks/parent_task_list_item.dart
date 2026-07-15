import 'package:flutter/material.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_task_date_label.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_task_meta_badges.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_task_title.dart';

class ParentTaskListItem extends StatelessWidget {
  const ParentTaskListItem({
    super.key,
    required this.leading,
    required this.title,
    required this.dateLabel,
    required this.classroomName,
    this.childName,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String dateLabel;
  final String? childName;
  final String classroomName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ParentTaskMetaBadges(
                          childName: childName,
                          classroomName: classroomName,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ParentTaskDateLabel(date: dateLabel),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ParentTaskTitle(title: title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
