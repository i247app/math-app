import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/widgets/list/parent_child_profile_card.dart';
import 'package:numi/features/profile/widgets/list/parent_info_card.dart';
import 'package:numi/features/profile/widgets/list/profile_add_button.dart';
import 'package:numi/features/profile/widgets/list/profile_state_panel.dart';

class ParentProfileManagePanel extends StatelessWidget {
  const ParentProfileManagePanel({
    super.key,
    required this.parentProfile,
    required this.children,
    required this.activeProfileId,
    required this.user,
    required this.scale,
    required this.onAdd,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.canAddProfile,
  });

  final StudentProfile parentProfile;
  final List<StudentProfile> children;
  final int? activeProfileId;
  final LoginUser? user;
  final double scale;
  final VoidCallback onAdd;
  final ValueChanged<StudentProfile> onSelect;
  final ValueChanged<StudentProfile> onEdit;
  final ValueChanged<StudentProfile> onDelete;
  final bool canAddProfile;

  @override
  Widget build(BuildContext context) {
    final sortedChildren = _activeChildFirst;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.getText(AppKeys.parentInfoTitle),
          style: GoogleFonts.andika(
            color: AppColors.textPrimary,
            fontSize: FontSize.large * scale,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 12 * scale),
        ParentInfoCard(
          profile: parentProfile,
          user: user,
          isActive:
              ActiveProfileSession.profileStableId(parentProfile) ==
              activeProfileId,
          scale: scale,
          onSelect: () => onSelect(parentProfile),
          onEdit: () => onEdit(parentProfile),
        ),
        SizedBox(height: 24 * scale),
        Row(
          children: [
            Expanded(
              child: Text(
                context.formatText(
                  AppKeys.parentChildrenCount,
                  <String, Object?>{'count': children.length},
                ),
                style: GoogleFonts.andika(
                  color: AppColors.textPrimary,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            if (canAddProfile) ProfileAddButton(scale: scale, onTap: onAdd),
          ],
        ),
        SizedBox(height: 12 * scale),
        if (sortedChildren.isEmpty)
          ProfileStatePanel(
            icon: Icons.groups_2_outlined,
            title: context.getText(AppKeys.noProfileTitle),
            message: context.getText(AppKeys.noProfileMessage),
            buttonLabel: canAddProfile
                ? context.getText(AppKeys.addProfile)
                : null,
            scale: scale,
            onTap: canAddProfile ? onAdd : null,
          )
        else
          for (var index = 0; index < sortedChildren.length; index++) ...[
            ParentChildProfileCard(
              profile: sortedChildren[index],
              isActive:
                  ActiveProfileSession.profileStableId(sortedChildren[index]) ==
                  activeProfileId,
              scale: scale,
              onSelect: () => onSelect(sortedChildren[index]),
              onEdit: () => onEdit(sortedChildren[index]),
              onDelete: () => onDelete(sortedChildren[index]),
            ),
            if (index != sortedChildren.length - 1)
              SizedBox(height: 16 * scale),
          ],
      ],
    );
  }

  List<StudentProfile> get _activeChildFirst {
    if (activeProfileId == null) {
      return children;
    }

    final activeIndex = children.indexWhere(
      (profile) =>
          ActiveProfileSession.profileStableId(profile) == activeProfileId,
    );
    if (activeIndex <= 0) {
      return children;
    }

    return <StudentProfile>[
      children[activeIndex],
      ...children.take(activeIndex),
      ...children.skip(activeIndex + 1),
    ];
  }
}
