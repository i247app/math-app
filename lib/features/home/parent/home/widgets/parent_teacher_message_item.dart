import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/widgets/home_profile_menu.dart';
import 'package:numi/features/home/widgets/home_visual_constants.dart';
import 'package:numi/features/home/parent/home/models/parent_child_summary.dart';
import 'package:numi/features/home/parent/shared/parent_home_helpers.dart';

class ParentTeacherMessageItem extends StatelessWidget {
  const ParentTeacherMessageItem({
    super.key,
    required this.summary,
    required this.index,
  });

  final ParentChildSummary summary;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final childName = homeProfileDisplayName(context, summary.profile);
    final className = parentClassroomName(context, summary);
    final teacherName = context.getText(
      index.isEven
          ? AppKeys.homeMessageTeacherOne
          : AppKeys.homeMessageTeacherTwo,
    );
    final time = context.getText(
      index.isEven ? AppKeys.homeMessageTimeOne : AppKeys.homeMessageTimeTwo,
    );
    final body = context.getText(
      index.isEven ? AppKeys.homeMessageBodyOne : AppKeys.homeMessageBodyTwo,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              index.isEven
                  ? homeTeacherAvatarOneAsset
                  : homeTeacherAvatarTwoAsset,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: FontSize.xxs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$className - ${childName.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
