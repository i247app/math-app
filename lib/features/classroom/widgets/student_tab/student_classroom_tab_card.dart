import 'package:numi/features/classroom/helpers/classroom_display_helpers.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/widgets/student_tab/student_classroom_meta_row.dart';

class StudentClassroomTabCard extends StatelessWidget {
  const StudentClassroomTabCard({
    super.key,
    required this.classroom,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = classroomDisplayName(context, classroom);
    final teacher = classroomTeacherName(context, classroom);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 22, 12, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD4D8E3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF002B6A).withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF002B6A),
                  fontSize: FontSize.xxxl,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 14),
              StudentClassroomMetaRow(
                icon: Icons.person_rounded,
                label: teacher,
              ),
              const SizedBox(height: 7),
              StudentClassroomMetaRow(
                icon: Icons.groups_rounded,
                label: context.formatText(AppKeys.teacherStudentCount, {
                  'count': classroom.displayStudentCount,
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
