import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_function_tile.dart';

class TeacherClassDetailFunctionGrid extends StatelessWidget {
  const TeacherClassDetailFunctionGrid({
    super.key,
    required this.scale,
    required this.onOpenAssignments,
    required this.onOpenAssessments,
  });

  final double scale;
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenAssessments;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10 * scale,
      mainAxisSpacing: 10 * scale,
      childAspectRatio: 148 / 90,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        TeacherClassDetailFunctionTile(
          scale: scale,
          iconAsset: 'assets/images/classroom_homework.png',
          label: context.getText(AppKeys.teacherAssignments),
          onTap: onOpenAssignments,
        ),
        TeacherClassDetailFunctionTile(
          scale: scale,
          iconAsset: 'assets/images/teacher_class_assignment.png',
          label: context.getText(AppKeys.teacherAssessments),
          onTap: onOpenAssessments,
        ),
        TeacherClassDetailFunctionTile(scale: scale),
        TeacherClassDetailFunctionTile(scale: scale),
      ],
    );
  }
}
