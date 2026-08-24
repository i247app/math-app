import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/profile/widgets/profile_avatar_image.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_helpers.dart';

class TeacherStudentSearchResultTile extends StatelessWidget {
  const TeacherStudentSearchResultTile({
    super.key,
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final StudentProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = profile.name?.trim().isNotEmpty == true
        ? profile.name!.trim()
        : context.getText(AppKeys.teacherStudentFallback);
    final subtitle = studentSearchSubtitle(context, profile);
    return Material(
      color: selected ? const Color(0xFFE8F7F7) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.teal520 : const Color(0xFFE5ECEF),
            ),
          ),
          child: Row(
            children: [
              ProfileAvatarImage(
                size: 44,
                avatarKey: profile.avatarKey,
                avatarUrl: profile.avatarUrl,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E3A5F),
                          fontSize: FontSize.compact,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textCoolMuted,
                            fontSize: FontSize.xxs,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Checkbox(
                value: selected,
                activeColor: AppColors.teal520,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (_) => onTap(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
