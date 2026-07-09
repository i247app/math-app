import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/core/theme/app_theme_colors.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/profile/widgets/profile_avatar_image.dart';
import 'package:numi_flutter/features/settings/widgets/profile_list/managed_profile_role_pill.dart';
import 'package:numi_flutter/features/settings/widgets/profile_list/parent_icon_button.dart';
import 'package:numi_flutter/features/settings/widgets/profile_list/parent_profile_code_line.dart';
import 'package:numi_flutter/features/settings/widgets/profile_list/parent_profile_info_line.dart';
import 'package:numi_flutter/features/settings/widgets/profile_list/profile_list_helpers.dart';
import 'package:numi_flutter/features/settings/widgets/profile_list/profile_radio.dart';

class ParentChildProfileCard extends StatelessWidget {
  const ParentChildProfileCard({
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
    final radius = BorderRadius.circular(16 * scale);
    final borderColor = isActive ? colors.brandStrong : colors.border;
    final textColor = isActive ? colors.textPrimary : colors.textSecondary;

    return Material(
      color: colors.elevatedSurface,
      borderRadius: radius,
      child: InkWell(
        onTap: onSelect,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: radius,
            border: Border.all(
              color: borderColor,
              width: isActive ? 1.4 * scale : 1 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 18 * scale,
                offset: Offset(0, 8 * scale),
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
                      ProfileAvatarImage(
                        size: 72 * scale,
                        avatarKey: profile.avatarKey,
                        avatarUrl: profile.avatarUrl,
                        borderColor: isActive
                            ? colors.brandStrong
                            : colors.border,
                        borderWidth: 3 * scale,
                      ),
                      SizedBox(width: 14 * scale),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 28 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                settingsProfileName(context, profile),
                                softWrap: true,
                                style: GoogleFonts.andika(
                                  color: textColor,
                                  fontSize: FontSize.large * scale,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              ManagedProfileRolePill(
                                role: ProfileRole.student,
                                scale: scale,
                              ),
                              SizedBox(height: 8 * scale),
                              ParentProfileCodeLine(
                                profile: profile,
                                isActive: isActive,
                                scale: scale,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14 * scale),
                  ParentProfileInfoLine(
                    assetPath: 'assets/images/parent_profile_manage_grade.svg',
                    label: context.getText(AppKeys.grade),
                    value: settingsProfileGrade(context, profile),
                    isActive: isActive,
                    scale: scale,
                  ),
                  SizedBox(height: 12 * scale),
                  ParentProfileInfoLine(
                    assetPath:
                        'assets/images/parent_profile_manage_program.svg',
                    label: context.getText(AppKeys.learningProgram),
                    value: settingsProfileProgram(context, profile),
                    isActive: isActive,
                    scale: scale,
                  ),
                  SizedBox(height: 14 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ParentIconButton(
                        assetPath:
                            'assets/images/parent_profile_manage_edit.svg',
                        backgroundColor: colors.brand.withValues(alpha: 0.12),
                        size: 42 * scale,
                        iconSize: 20 * scale,
                        onTap: onEdit,
                      ),
                      SizedBox(width: 12 * scale),
                      ParentIconButton(
                        assetPath:
                            'assets/images/parent_profile_manage_delete.svg',
                        backgroundColor: const Color(0xFFFFE4E4),
                        size: 42 * scale,
                        iconSize: 20 * scale,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: ProfileRadio(isActive: isActive, scale: scale),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
