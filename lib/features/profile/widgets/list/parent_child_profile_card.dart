import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/profile/domain/models/profile_role.dart';
import 'package:numi/shared/widgets/profile_avatar_image.dart';
import 'package:numi/features/profile/widgets/list/managed_profile_role_pill.dart';
import 'package:numi/features/profile/widgets/list/parent_profile_code_line.dart';
import 'package:numi/features/profile/widgets/list/profile_action_button.dart';
import 'package:numi/features/profile/widgets/list/profile_detail_line.dart';
import 'package:numi/features/profile/widgets/list/profile_list_helpers.dart';
import 'package:numi/features/profile/widgets/list/profile_radio.dart';

class ParentChildProfileCard extends StatelessWidget {
  const ParentChildProfileCard({
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
    final radius = BorderRadius.circular(16);
    final borderColor = isActive ? colors.brandStrong : colors.border;
    final textColor = isActive ? colors.textPrimary : colors.textSecondary;

    return Material(
      color: colors.elevatedSurface,
      borderRadius: radius,
      child: InkWell(
        onTap: isSwitching ? null : onSelect,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: radius,
            border: Border.all(color: borderColor, width: isActive ? 1.4 : 1),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: ProfileAvatarImage(
                          size: 72,
                          avatarKey: profile.avatarKey,
                          avatarUrl: profile.avatarUrl,
                          borderColor: isActive
                              ? colors.brandStrong
                              : colors.border,
                          borderWidth: 3,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  settingsProfileName(context, profile),
                                  softWrap: true,
                                  style: GoogleFonts.andika(
                                    color: textColor,
                                    fontSize: FontSize.large,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: ManagedProfileRolePill(
                                  role: ProfileRole.student,
                                ),
                              ),
                              ParentProfileCodeLine(
                                profile: profile,
                                isActive: isActive,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: ProfileDetailLine(
                      leading: SizedBox(
                        width: 18,
                        height: 18,
                        child: SvgPicture.asset(
                          'assets/icons/parent-profile-manage-grade.svg',
                        ),
                      ),
                      label: context.getText(AppKeys.grade),
                      value: settingsProfileGrade(context, profile),
                      color: isActive
                          ? const Color(0xFF008080)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ProfileDetailLine(
                      leading: SizedBox(
                        width: 18,
                        height: 18,
                        child: SvgPicture.asset(
                          'assets/icons/parent-profile-manage-program.svg',
                        ),
                      ),
                      label: context.getText(AppKeys.learningProgram),
                      value: settingsProfileProgram(context, profile),
                      color: isActive
                          ? const Color(0xFF008080)
                          : const Color(0xFF6B7280),
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
                          child: SvgPicture.asset(
                            'assets/icons/parent-profile-manage-edit.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                        ProfileActionButton(
                          backgroundColor: const Color(0xFFFFE4E4),
                          width: 42,
                          height: 42,
                          borderRadius: BorderRadius.circular(10),
                          onTap: onDelete,
                          child: SvgPicture.asset(
                            'assets/icons/parent-profile-manage-delete.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: ProfileRadio(isActive: isActive, isLoading: isSwitching),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
