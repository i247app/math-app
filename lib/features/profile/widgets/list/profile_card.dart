import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/widgets/list/managed_profile_role_pill.dart';
import 'package:numi/features/profile/widgets/list/profile_avatar.dart';
import 'package:numi/features/profile/widgets/list/profile_action_button.dart';
import 'package:numi/features/profile/widgets/list/profile_detail_line.dart';
import 'package:numi/features/profile/widgets/list/profile_id_line.dart';
import 'package:numi/features/profile/widgets/list/profile_list_helpers.dart';
import 'package:numi/features/profile/widgets/list/profile_radio.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.isActive,
    required this.scale,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final StudentProfile profile;
  final bool isActive;
  final double scale;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final accent = isActive ? colors.brandStrong : colors.textSecondary;
    final radius = BorderRadius.circular(18 * scale);
    final role = ProfileRole.fromProfile(profile);
    final isTeacher = role == ProfileRole.teacher;

    return Material(
      color: colors.elevatedSurface,
      borderRadius: radius,
      child: InkWell(
        onTap: onSelect,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            18 * scale,
            16 * scale,
            16 * scale,
            16 * scale,
          ),
          decoration: BoxDecoration(
            color: colors.elevatedSurface.withValues(alpha: 0.96),
            borderRadius: radius,
            border: Border.all(
              color: isActive
                  ? colors.brandStrong
                  : colors.border.withValues(alpha: 0.92),
              width: isActive ? 1.6 * scale : 1.3 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 18 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(
                    avatarKey: profile.avatarKey,
                    avatarUrl: profile.avatarUrl,
                    isActive: isActive,
                    scale: scale,
                  ),
                  SizedBox(width: 14 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settingsProfileName(context, profile),
                          softWrap: true,
                          style: GoogleFonts.andika(
                            color: colors.textPrimary,
                            fontSize: FontSize.large * scale,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 5 * scale),
                        ManagedProfileRolePill(role: role, scale: scale),
                        SizedBox(height: 9 * scale),
                        ProfileIdLine(
                          profile: profile,
                          isActive: isActive,
                          scale: scale,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  ProfileRadio(isActive: isActive, scale: scale),
                ],
              ),
              SizedBox(height: 14 * scale),
              ProfileDetailLine(
                leading: Icon(
                  isTeacher ? Icons.apartment_rounded : Icons.school_outlined,
                  color: accent,
                  size: 18 * scale,
                ),
                color: accent,
                label: isTeacher
                    ? context.getText(AppKeys.school)
                    : context.getText(AppKeys.grade),
                value: isTeacher
                    ? settingsProfileSchool(context, profile)
                    : settingsProfileGrade(context, profile),
                scale: scale,
              ),
              if (!isTeacher) ...[
                SizedBox(height: 12 * scale),
                ProfileDetailLine(
                  leading: Icon(
                    Icons.book_outlined,
                    color: accent,
                    size: 18 * scale,
                  ),
                  color: accent,
                  label: context.getText(AppKeys.program),
                  value: settingsProfileProgram(context, profile),
                  scale: scale,
                ),
              ],
              SizedBox(height: 14 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ProfileActionButton(
                    backgroundColor: colors.brand.withValues(alpha: 0.12),
                    width: 42 * scale,
                    height: 42 * scale,
                    borderRadius: BorderRadius.circular(10 * scale),
                    onTap: onEdit,
                    child: Icon(
                      Icons.edit_rounded,
                      color: colors.brandStrong,
                      size: 23 * scale,
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  ProfileActionButton(
                    backgroundColor: const Color(0xFFFFD8D8),
                    width: 42 * scale,
                    height: 42 * scale,
                    borderRadius: BorderRadius.circular(10 * scale),
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: const Color(0xFFE83434),
                      size: 23 * scale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
