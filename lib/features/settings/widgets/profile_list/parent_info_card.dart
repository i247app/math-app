import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/active_profile_session.dart';
import 'package:numi/features/settings/widgets/profile_list/managed_profile_role_pill.dart';
import 'package:numi/features/settings/widgets/profile_list/parent_icon_button.dart';
import 'package:numi/features/settings/widgets/profile_list/parent_profile_avatar.dart';
import 'package:numi/features/settings/widgets/profile_list/profile_radio.dart';

class ParentInfoCard extends StatelessWidget {
  const ParentInfoCard({
    super.key,
    required this.profile,
    required this.user,
    required this.isActive,
    required this.scale,
    required this.onSelect,
    required this.onEdit,
  });

  final StudentProfile profile;
  final LoginUser? user;
  final bool isActive;
  final double scale;
  final VoidCallback onSelect;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final email = _displayEmail(context, user);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: const Color(0xFF008080),
            width: 1.3 * scale,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ParentProfileAvatar(profile: profile, scale: scale),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayParentName(context, profile, user),
                              softWrap: true,
                              style: GoogleFonts.andika(
                                color: AppColors.textPrimary,
                                fontSize: FontSize.large * scale,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            ManagedProfileRolePill(
                              role: ProfileRole.parent,
                              scale: scale,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      ParentIconButton(
                        assetPath:
                            'assets/images/parent_profile_manage_edit.svg',
                        backgroundColor: const Color(0xFFE6F5F5),
                        size: 34 * scale,
                        iconSize: 19 * scale,
                        onTap: onEdit,
                      ),
                      SizedBox(width: 8 * scale),
                      ProfileRadio(isActive: isActive, scale: scale),
                    ],
                  ),
                  SizedBox(height: 10 * scale),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/parent_profile_manage_mail.svg',
                        width: 16 * scale,
                        height: 16 * scale,
                      ),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text(
                          '${context.getText(AppKeys.email)}: $email',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: const Color(0xFF6B7280),
                            fontSize: FontSize.caption * scale,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayParentName(
    BuildContext context,
    StudentProfile profile,
    LoginUser? user,
  ) {
    final profileName = profile.name?.trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }

    final userName = user?.name?.trim();
    if (userName != null && userName.isNotEmpty) {
      return userName;
    }

    return context.getText(AppKeys.roleParent);
  }

  String _displayEmail(BuildContext context, LoginUser? user) {
    final email = user?.email?.trim();
    return email == null || email.isEmpty
        ? context.getText(AppKeys.notSelected)
        : email;
  }
}
