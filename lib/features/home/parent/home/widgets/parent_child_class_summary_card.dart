import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/widgets/home_profile_menu.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/shared/parent_home_helpers.dart';

class ParentChildClassSummaryCard extends StatelessWidget {
  const ParentChildClassSummaryCard({super.key, required this.summary});

  final ParentChildSummary? summary;

  @override
  Widget build(BuildContext context) {
    final className = summary == null
        ? context.getText(AppKeys.parentNoClassroom)
        : parentClassroomName(context, summary!);
    final teacherName = summary?.classroom?.teacherName?.trim();

    return Container(
      // height: 120,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBE6E4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            summary == null
                ? context.getText(AppKeys.parentNoStudentTitle)
                : homeProfileDisplayName(context, summary!.profile),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: FontSize.xxl,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            className,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: FontSize.xxxl,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            teacherName?.isNotEmpty == true
                ? teacherName!
                : context.getText(AppKeys.parentNoTeacher),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: FontSize.large,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
