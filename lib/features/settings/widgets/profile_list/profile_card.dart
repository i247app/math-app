import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/settings/widgets/profile_list/managed_profile_role_pill.dart';
import 'package:numi/features/settings/widgets/profile_list/profile_avatar.dart';
import 'package:numi/features/settings/widgets/profile_list/profile_icon_button.dart';
import 'package:numi/features/settings/widgets/profile_list/profile_id_line.dart';
import 'package:numi/features/settings/widgets/profile_list/profile_info_line.dart';
import 'package:numi/features/settings/widgets/profile_list/profile_list_helpers.dart';
import 'package:numi/features/settings/widgets/profile_list/profile_radio.dart';

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
              ProfileInfoLine(
                icon: isTeacher
                    ? Icons.apartment_rounded
                    : Icons.school_outlined,
                iconColor: accent,
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
                ProfileInfoLine(
                  icon: Icons.book_outlined,
                  iconColor: accent,
                  label: context.getText(AppKeys.program),
                  value: settingsProfileProgram(context, profile),
                  scale: scale,
                ),
              ],
              SizedBox(height: 14 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ProfileIconButton(
                    icon: Icons.edit_rounded,
                    foregroundColor: colors.brandStrong,
                    backgroundColor: colors.brand.withValues(alpha: 0.12),
                    scale: scale,
                    onTap: onEdit,
                  ),
                  SizedBox(width: 12 * scale),
                  ProfileIconButton(
                    icon: Icons.delete_outline_rounded,
                    foregroundColor: const Color(0xFFE83434),
                    backgroundColor: const Color(0xFFFFD8D8),
                    scale: scale,
                    onTap: onDelete,
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
