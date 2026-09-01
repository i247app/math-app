import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/profile/domain/models/profile_role.dart';
import 'package:numi/features/profile/presentation/widgets/list/managed_profile_role_pill.dart';
import 'package:numi/features/profile/presentation/widgets/list/parent_profile_avatar.dart';
import 'package:numi/features/profile/presentation/widgets/list/profile_action_button.dart';
import 'package:numi/features/profile/presentation/widgets/list/profile_radio.dart';

class ParentInfoCard extends StatelessWidget {
  const ParentInfoCard({
    super.key,
    required this.profile,
    required this.user,
    required this.isActive,
    this.isSwitching = false,
    required this.onSelect,
    required this.onEdit,
  });

  final StudentProfile profile;
  final LoginUser? user;
  final bool isActive;
  final bool isSwitching;
  final VoidCallback onSelect;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final email = _displayEmail(context, user);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isSwitching ? null : onSelect,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF008080), width: 1.3),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: [
            ParentProfileAvatar(profile: profile),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              _displayParentName(context, profile, user),
                              softWrap: true,
                              style: GoogleFonts.andika(
                                color: AppColors.textPrimary,
                                fontSize: FontSize.large,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const ManagedProfileRolePill(
                              role: ProfileRole.parent,
                            ),
                          ],
                        ),
                      ),
                      ProfileActionButton(
                        backgroundColor: const Color(0xFFE6F5F5),
                        width: 34,
                        height: 34,
                        borderRadius: BorderRadius.circular(10),
                        onTap: onEdit,
                        child: SvgPicture.asset(
                          'assets/icons/parent-profile-manage-edit.svg',
                          width: 19,
                          height: 19,
                        ),
                      ),
                      ProfileRadio(isActive: isActive, isLoading: isSwitching),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      spacing: 8,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/parent-profile-manage-mail.svg',
                          width: 16,
                          height: 16,
                        ),
                        Expanded(
                          child: Text(
                            '${context.getText(AppKeys.email)}: $email',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.andika(
                              color: const Color(0xFF6B7280),
                              fontSize: FontSize.caption,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
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
