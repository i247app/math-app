import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/profile.dart';
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
    this.isSwitching = false,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final StudentProfile profile;
  final bool isActive;
  final bool isSwitching;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final accent = isActive ? colors.brandStrong : colors.textSecondary;
    final radius = BorderRadius.circular(18);
    final role = ProfileRole.fromProfile(profile);
    final isTeacher = role == ProfileRole.teacher;

    return Material(
      color: colors.elevatedSurface,
      borderRadius: radius,
      child: InkWell(
        onTap: isSwitching ? null : onSelect,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
          decoration: BoxDecoration(
            color: colors.elevatedSurface.withValues(alpha: 0.96),
            borderRadius: radius,
            border: Border.all(
              color: isActive
                  ? colors.brandStrong
                  : colors.border.withValues(alpha: 0.92),
              width: isActive ? 1.6 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: ProfileAvatar(
                      avatarKey: profile.avatarKey,
                      avatarUrl: profile.avatarUrl,
                      isActive: isActive,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            settingsProfileName(context, profile),
                            softWrap: true,
                            style: GoogleFonts.andika(
                              color: colors.textPrimary,
                              fontSize: FontSize.large,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: ManagedProfileRolePill(role: role),
                        ),
                        ProfileIdLine(profile: profile, isActive: isActive),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ProfileRadio(
                      isActive: isActive,
                      isLoading: isSwitching,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: ProfileDetailLine(
                  leading: Icon(
                    isTeacher ? Icons.apartment_rounded : Icons.school_outlined,
                    color: accent,
                    size: 18,
                  ),
                  color: accent,
                  label: isTeacher
                      ? context.getText(AppKeys.school)
                      : context.getText(AppKeys.grade),
                  value: isTeacher
                      ? settingsProfileSchool(context, profile)
                      : settingsProfileGrade(context, profile),
                ),
              ),
              if (!isTeacher)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ProfileDetailLine(
                    leading: Icon(Icons.book_outlined, color: accent, size: 18),
                    color: accent,
                    label: context.getText(AppKeys.program),
                    value: settingsProfileProgram(context, profile),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 12,
                  children: [
                    ProfileActionButton(
                      backgroundColor: colors.brand.withValues(alpha: 0.12),
                      width: 42,
                      height: 42,
                      borderRadius: BorderRadius.circular(10),
                      onTap: onEdit,
                      child: Icon(
                        Icons.edit_rounded,
                        color: colors.brandStrong,
                        size: 23,
                      ),
                    ),
                    ProfileActionButton(
                      backgroundColor: const Color(0xFFFFD8D8),
                      width: 42,
                      height: 42,
                      borderRadius: BorderRadius.circular(10),
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE83434),
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
