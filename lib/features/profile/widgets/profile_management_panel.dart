import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/widgets/list/parent_profile_manage_panel.dart';
import 'package:numi/features/profile/widgets/list/profile_add_button.dart';
import 'package:numi/features/profile/widgets/list/profile_card.dart';
import 'package:numi/features/profile/widgets/list/profile_state_panel.dart';

class ProfileManagementPanel extends StatelessWidget {
  const ProfileManagementPanel({
    super.key,
    required this.profiles,
    required this.activeProfile,
    required this.user,
    required this.activeProfileId,
    required this.switchingProfileId,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onAdd,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.canAddProfile,
  });

  final List<UserProfile> profiles;
  final UserProfile? activeProfile;
  final LoginUser? user;
  final int? activeProfileId;
  final int? switchingProfileId;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onAdd;
  final ValueChanged<UserProfile> onSelect;
  final ValueChanged<UserProfile> onEdit;
  final ValueChanged<UserProfile> onDelete;
  final bool canAddProfile;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 360,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.tealIcon,
            strokeWidth: 3,
          ),
        ),
      );
    }

    final error = errorMessage?.trim();
    if (error != null && error.isNotEmpty) {
      return ProfileStatePanel(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.profileLoadErrorTitle),
        message: error,
        buttonLabel: context.getText(AppKeys.retry),
        onTap: onRetry,
      );
    }

    if (profiles.isEmpty) {
      return ProfileStatePanel(
        icon: Icons.groups_2_outlined,
        title: context.getText(AppKeys.noProfileTitle),
        message: context.getText(AppKeys.noProfileMessage),
        buttonLabel: canAddProfile ? context.getText(AppKeys.addProfile) : null,
        onTap: canAddProfile ? onAdd : null,
      );
    }

    final sortedProfiles = _activeFirstProfiles;
    final parentProfile = _parentProfile;

    if (parentProfile != null) {
      return ParentProfileManagePanel(
        parentProfile: parentProfile,
        children: _studentProfiles,
        activeProfileId: activeProfileId,
        switchingProfileId: switchingProfileId,
        user: user,
        canAddProfile: canAddProfile,
        onAdd: onAdd,
        onSelect: onSelect,
        onEdit: onEdit,
        onDelete: onDelete,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canAddProfile)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: ProfileAddButton(onTap: onAdd),
            ),
          ),
        Column(
          spacing: 16,
          children: sortedProfiles
              .map(
                (profile) => ProfileCard(
                  profile: profile,
                  isActive: profileStableId(profile) == activeProfileId,
                  isSwitching: profileStableId(profile) == switchingProfileId,
                  onSelect: () => onSelect(profile),
                  onEdit: () => onEdit(profile),
                  onDelete: () => onDelete(profile),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }

  List<UserProfile> get _activeFirstProfiles {
    if (activeProfileId == null) {
      return profiles;
    }

    final activeIndex = profiles.indexWhere(
      (profile) => profileStableId(profile) == activeProfileId,
    );
    if (activeIndex <= 0) {
      return profiles;
    }

    return <UserProfile>[
      profiles[activeIndex],
      ...profiles.take(activeIndex),
      ...profiles.skip(activeIndex + 1),
    ];
  }

  UserProfile? get _parentProfile {
    final activeProfileId = profileStableId(activeProfile);
    if (activeProfileId != null) {
      for (final profile in profiles) {
        if (profileStableId(profile) == activeProfileId &&
            ProfileRole.fromProfile(profile) == ProfileRole.parent) {
          return profile;
        }
      }
    }

    for (final profile in profiles) {
      if (ProfileRole.fromProfile(profile) == ProfileRole.parent) {
        return profile;
      }
    }

    if (activeProfile != null &&
        ProfileRole.fromProfile(activeProfile) == ProfileRole.parent) {
      return activeProfile;
    }

    return null;
  }

  List<UserProfile> get _studentProfiles {
    return profiles
        .where(
          (profile) => ProfileRole.fromProfile(profile) == ProfileRole.student,
        )
        .toList(growable: false);
  }
}
