import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/widgets/list/parent_profile_manage_panel.dart';
import 'package:numi/features/profile/widgets/list/profile_add_button.dart';
import 'package:numi/features/profile/widgets/list/profile_card.dart';
import 'package:numi/features/profile/widgets/list/profile_state_panel.dart';

class ProfilePlaceholderPanel extends StatelessWidget {
  const ProfilePlaceholderPanel({
    super.key,
    required this.profiles,
    required this.activeProfile,
    required this.user,
    required this.activeProfileId,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onAdd,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.scale,
    required this.canAddProfile,
  });

  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final LoginUser? user;
  final int? activeProfileId;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onAdd;
  final ValueChanged<StudentProfile> onSelect;
  final ValueChanged<StudentProfile> onEdit;
  final ValueChanged<StudentProfile> onDelete;
  final double scale;
  final bool canAddProfile;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 360 * scale,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.tealIcon,
            strokeWidth: 3 * scale,
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
        scale: scale,
        onTap: onRetry,
      );
    }

    if (profiles.isEmpty) {
      return ProfileStatePanel(
        icon: Icons.groups_2_outlined,
        title: context.getText(AppKeys.noProfileTitle),
        message: context.getText(AppKeys.noProfileMessage),
        buttonLabel: canAddProfile ? context.getText(AppKeys.addProfile) : null,
        scale: scale,
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
        user: user,
        scale: scale,
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
        if (canAddProfile) ...[
          Align(
            alignment: Alignment.centerRight,
            child: ProfileAddButton(scale: scale, onTap: onAdd),
          ),
          SizedBox(height: 10 * scale),
        ],
        for (var index = 0; index < sortedProfiles.length; index++) ...[
          ProfileCard(
            profile: sortedProfiles[index],
            isActive:
                ActiveProfileSession.profileStableId(sortedProfiles[index]) ==
                activeProfileId,
            scale: scale,
            onSelect: () => onSelect(sortedProfiles[index]),
            onEdit: () => onEdit(sortedProfiles[index]),
            onDelete: () => onDelete(sortedProfiles[index]),
          ),
          if (index != sortedProfiles.length - 1) SizedBox(height: 16 * scale),
        ],
      ],
    );
  }

  List<StudentProfile> get _activeFirstProfiles {
    if (activeProfileId == null) {
      return profiles;
    }

    final activeIndex = profiles.indexWhere(
      (profile) =>
          ActiveProfileSession.profileStableId(profile) == activeProfileId,
    );
    if (activeIndex <= 0) {
      return profiles;
    }

    return <StudentProfile>[
      profiles[activeIndex],
      ...profiles.take(activeIndex),
      ...profiles.skip(activeIndex + 1),
    ];
  }

  StudentProfile? get _parentProfile {
    final activeProfileId = ActiveProfileSession.profileStableId(activeProfile);
    if (activeProfileId != null) {
      for (final profile in profiles) {
        if (ActiveProfileSession.profileStableId(profile) == activeProfileId &&
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

  List<StudentProfile> get _studentProfiles {
    return profiles
        .where(
          (profile) => ProfileRole.fromProfile(profile) == ProfileRole.student,
        )
        .toList(growable: false);
  }
}
