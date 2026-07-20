import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/shared/parent_home_helpers.dart';

class ParentChildClassSummaryCard extends StatelessWidget {
  const ParentChildClassSummaryCard({super.key, required this.summary});

  final ParentChildSummary? summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final className = summary == null
        ? context.getText(AppKeys.parentNoClassroom)
        : parentClassroomName(context, summary!);
    final teacherName = summary?.classroom?.teacherName?.trim();

    return Container(
      // height: 120,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: colors.infoSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.info.withValues(alpha: 0.22)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: [
          Text(
            summary == null
                ? context.getText(AppKeys.parentNoStudentTitle)
                : profileDisplayName(context, summary!.profile),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontSize.xxl,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            className,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontSize.xxxl,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              teacherName?.isNotEmpty == true
                  ? teacherName!
                  : context.getText(AppKeys.parentNoTeacher),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: FontSize.large,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
