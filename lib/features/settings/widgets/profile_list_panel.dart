part of '../setting_tab.dart';

class _ProfilePlaceholderPanel extends StatelessWidget {
  const _ProfilePlaceholderPanel({
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
            color: _teal,
            strokeWidth: 3 * scale,
          ),
        ),
      );
    }

    final error = errorMessage?.trim();
    if (error != null && error.isNotEmpty) {
      return _ProfileStatePanel(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.profileLoadErrorTitle),
        message: error,
        buttonLabel: context.getText(AppKeys.retry),
        scale: scale,
        onTap: onRetry,
      );
    }

    if (profiles.isEmpty) {
      return _ProfileStatePanel(
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
      return _ParentProfileManagePanel(
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
            child: _ProfileAddButton(scale: scale, onTap: onAdd),
          ),
          SizedBox(height: 10 * scale),
        ],
        for (var index = 0; index < sortedProfiles.length; index++) ...[
          _ProfileCard(
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
    if (activeProfile != null &&
        ProfileRole.fromProfile(activeProfile) == ProfileRole.parent) {
      return activeProfile;
    }

    for (final profile in profiles) {
      if (ProfileRole.fromProfile(profile) == ProfileRole.parent) {
        return profile;
      }
    }

    return null;
  }

  List<StudentProfile> get _studentProfiles {
    return profiles
        .where((profile) =>
            ProfileRole.fromProfile(profile) == ProfileRole.student)
        .toList(growable: false);
  }
}

class _ParentProfileManagePanel extends StatelessWidget {
  const _ParentProfileManagePanel({
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
            color: _deepInk,
            fontSize: FontSize.large * scale,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 12 * scale),
        _ParentInfoCard(
          profile: parentProfile,
          user: user,
          isActive: ActiveProfileSession.profileStableId(parentProfile) ==
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
                  color: _deepInk,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            if (canAddProfile) _ProfileAddButton(scale: scale, onTap: onAdd),
          ],
        ),
        SizedBox(height: 12 * scale),
        if (sortedChildren.isEmpty)
          _ProfileStatePanel(
            icon: Icons.groups_2_outlined,
            title: context.getText(AppKeys.noProfileTitle),
            message: context.getText(AppKeys.noProfileMessage),
            buttonLabel:
                canAddProfile ? context.getText(AppKeys.addProfile) : null,
            scale: scale,
            onTap: canAddProfile ? onAdd : null,
          )
        else
          for (var index = 0; index < sortedChildren.length; index++) ...[
            _ParentChildProfileCard(
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

class _ParentInfoCard extends StatelessWidget {
  const _ParentInfoCard({
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
          border:
              Border.all(color: const Color(0xFF008080), width: 1.3 * scale),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ParentProfileAvatar(profile: profile, scale: scale),
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
                                color: _deepInk,
                                fontSize: FontSize.large * scale,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            _ManagedProfileRolePill(
                              role: ProfileRole.parent,
                              scale: scale,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      _ParentIconButton(
                        assetPath:
                            'assets/images/parent_profile_manage_edit.svg',
                        backgroundColor: const Color(0xFFE6F5F5),
                        size: 34 * scale,
                        iconSize: 19 * scale,
                        onTap: onEdit,
                      ),
                      SizedBox(width: 8 * scale),
                      _ProfileRadio(isActive: isActive, scale: scale),
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

class _ParentProfileAvatar extends StatelessWidget {
  const _ParentProfileAvatar({
    required this.profile,
    required this.scale,
  });

  final StudentProfile profile;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 80 * scale;

    return ProfileAvatarImage(
      size: size,
      avatarKey: profile.avatarKey,
      avatarUrl: profile.avatarUrl,
      backgroundColor: const Color(0xFFE6F5F5),
      foregroundColor: const Color(0xFF008080),
      borderColor: const Color(0xFF008080),
      borderWidth: 3 * scale,
    );
  }
}

class _ManagedProfileRolePill extends StatelessWidget {
  const _ManagedProfileRolePill({
    required this.role,
    required this.scale,
  });

  final ProfileRole role;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 5 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEEE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _localizedRole(context, role),
        style: GoogleFonts.andika(
          color: const Color(0xFF008080),
          fontSize: FontSize.caption * scale,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _ParentChildProfileCard extends StatelessWidget {
  const _ParentChildProfileCard({
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
    final radius = BorderRadius.circular(16 * scale);
    final borderColor =
        isActive ? const Color(0xFF008080) : const Color(0xFFE5E7EB);
    final textColor = isActive ? _deepInk : const Color(0xFF6B7280);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onSelect,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(
              color: borderColor,
              width: isActive ? 1.4 * scale : 1 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5E7775).withValues(alpha: 0.06),
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
                            ? const Color(0xFF008080)
                            : const Color(0xFFE5E7EB),
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
                                _ProfileCard._displayProfileName(
                                    context, profile),
                                softWrap: true,
                                style: GoogleFonts.andika(
                                  color: textColor,
                                  fontSize: FontSize.large * scale,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              _ManagedProfileRolePill(
                                role: ProfileRole.student,
                                scale: scale,
                              ),
                              SizedBox(height: 8 * scale),
                              _ParentProfileCodeLine(
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
                  _ParentProfileInfoLine(
                    assetPath: 'assets/images/parent_profile_manage_grade.svg',
                    label: context.getText(AppKeys.grade),
                    value: _ProfileCard._displayGrade(context, profile),
                    isActive: isActive,
                    scale: scale,
                  ),
                  SizedBox(height: 12 * scale),
                  _ParentProfileInfoLine(
                    assetPath:
                        'assets/images/parent_profile_manage_program.svg',
                    label: context.getText(AppKeys.learningProgram),
                    value: _ProfileCard._displayProgram(context, profile),
                    isActive: isActive,
                    scale: scale,
                  ),
                  SizedBox(height: 14 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ParentIconButton(
                        assetPath:
                            'assets/images/parent_profile_manage_edit.svg',
                        backgroundColor: const Color(0xFFE6F5F5),
                        size: 42 * scale,
                        iconSize: 20 * scale,
                        onTap: onEdit,
                      ),
                      SizedBox(width: 12 * scale),
                      _ParentIconButton(
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
                child: _ProfileRadio(isActive: isActive, scale: scale),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentProfileCodeLine extends StatelessWidget {
  const _ParentProfileCodeLine({
    required this.profile,
    required this.isActive,
    required this.scale,
  });

  final StudentProfile profile;
  final bool isActive;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final profileCode = profile.profileCode?.trim();
    if (profileCode == null || profileCode.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            '${context.getText(AppKeys.profileCodeLabel)}: $profileCode',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color:
                  isActive ? const Color(0xFF604950) : const Color(0xFF6B7280),
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        _ParentCodeActionButton(
          profileCode: profileCode,
          scale: scale,
        ),
      ],
    );
  }
}

class _ParentCodeActionButton extends StatelessWidget {
  const _ParentCodeActionButton({
    required this.profileCode,
    required this.scale,
  });

  final String profileCode;
  final double scale;

  Future<void> _copyProfileCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profileCode));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.getText(AppKeys.profileCodeCopied))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(8 * scale),
      child: InkWell(
        onTap: () => _copyProfileCode(context),
        borderRadius: BorderRadius.circular(8 * scale),
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 5 * scale),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/parent_profile_manage_copy.svg',
                width: 15 * scale,
                height: 15 * scale,
              ),
              SizedBox(width: 6 * scale),
              SvgPicture.asset(
                'assets/images/parent_profile_manage_qr.svg',
                width: 15 * scale,
                height: 15 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentProfileInfoLine extends StatelessWidget {
  const _ParentProfileInfoLine({
    required this.assetPath,
    required this.label,
    required this.value,
    required this.isActive,
    required this.scale,
  });

  final String assetPath;
  final String label;
  final String value;
  final bool isActive;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF008080) : const Color(0xFF6B7280);

    return Row(
      children: [
        SizedBox(
          width: 18 * scale,
          height: 18 * scale,
          child: SvgPicture.asset(assetPath),
        ),
        SizedBox(width: 8 * scale),
        Text(
          '$label : ',
          style: GoogleFonts.andika(
            color: color,
            fontSize: FontSize.small * scale,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: color,
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParentIconButton extends StatelessWidget {
  const _ParentIconButton({
    required this.assetPath,
    required this.backgroundColor,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final String assetPath;
  final Color backgroundColor;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10 * (size / 42)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10 * (size / 42)),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SvgPicture.asset(
              assetPath,
              width: iconSize,
              height: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAddButton extends StatelessWidget {
  const _ProfileAddButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF8A3D),
      elevation: 4,
      shadowColor: const Color(0xFFFF8A3D).withValues(alpha: 0.20),
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: SizedBox(
          width: 48 * scale,
          height: 34 * scale,
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 24 * scale,
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
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
    final accent = isActive ? _teal : _muted;
    final radius = BorderRadius.circular(18 * scale);
    final role = ProfileRole.fromProfile(profile);
    final isTeacher = role == ProfileRole.teacher;

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onSelect,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.fromLTRB(
              18 * scale, 16 * scale, 16 * scale, 16 * scale),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: radius,
            border: Border.all(
              color: isActive
                  ? _teal
                  : const Color(0xFFC8D0CC).withValues(alpha: 0.92),
              width: isActive ? 1.6 * scale : 1.3 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5E7775).withValues(alpha: 0.08),
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
                  _ProfileAvatar(
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
                          _displayProfileName(context, profile),
                          softWrap: true,
                          style: GoogleFonts.andika(
                            color: _deepInk,
                            fontSize: FontSize.large * scale,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 5 * scale),
                        _ManagedProfileRolePill(
                          role: role,
                          scale: scale,
                        ),
                        SizedBox(height: 9 * scale),
                        _ProfileIdLine(
                          profile: profile,
                          isActive: isActive,
                          scale: scale,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  _ProfileRadio(isActive: isActive, scale: scale),
                ],
              ),
              SizedBox(height: 14 * scale),
              _ProfileInfoLine(
                icon:
                    isTeacher ? Icons.apartment_rounded : Icons.school_outlined,
                iconColor: accent,
                label: isTeacher
                    ? context.getText(AppKeys.school)
                    : context.getText(AppKeys.grade),
                value: isTeacher
                    ? _displaySchool(context, profile)
                    : _displayGrade(context, profile),
                scale: scale,
              ),
              if (!isTeacher) ...[
                SizedBox(height: 12 * scale),
                _ProfileInfoLine(
                  icon: Icons.book_outlined,
                  iconColor: accent,
                  label: context.getText(AppKeys.program),
                  value: _displayProgram(context, profile),
                  scale: scale,
                ),
              ],
              SizedBox(height: 14 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ProfileIconButton(
                    icon: Icons.edit_rounded,
                    foregroundColor: _teal,
                    backgroundColor: const Color(0xFFECF6FA),
                    scale: scale,
                    onTap: onEdit,
                  ),
                  SizedBox(width: 12 * scale),
                  _ProfileIconButton(
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

  static String _displayProfileName(
      BuildContext context, StudentProfile profile) {
    final name = profile.name?.trim();
    return name == null || name.isEmpty
        ? context.getText(AppKeys.belovedChild)
        : name;
  }

  static String _displayGrade(BuildContext context, StudentProfile profile) {
    final grade = profile.grade?.label?.trim();
    return grade == null || grade.isEmpty
        ? context.getText(AppKeys.notSelected)
        : grade;
  }

  static String _displayProgram(BuildContext context, StudentProfile profile) {
    final program = profile.program?.label?.trim();
    return program == null || program.isEmpty
        ? context.getText(AppKeys.notSelected)
        : program;
  }

  static String _displaySchool(BuildContext context, StudentProfile profile) {
    final school = profile.school?.name?.trim();
    return school == null || school.isEmpty
        ? context.getText(AppKeys.notSelected)
        : school;
  }
}

String _localizedRole(BuildContext context, ProfileRole role) {
  return switch (role) {
    ProfileRole.teacher => context.getText(AppKeys.roleTeacher),
    ProfileRole.parent => context.getText(AppKeys.roleParent),
    ProfileRole.student => context.getText(AppKeys.roleStudent),
  };
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.avatarKey,
    required this.avatarUrl,
    required this.isActive,
    required this.scale,
  });

  final String? avatarKey;
  final String? avatarUrl;
  final bool isActive;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 72 * scale;

    return ProfileAvatarImage(
      size: size,
      avatarKey: avatarKey,
      avatarUrl: avatarUrl,
      borderColor: isActive ? _teal : const Color(0xFFC8D0CC),
      borderWidth: 4 * scale,
    );
  }
}

class _ProfileRadio extends StatelessWidget {
  const _ProfileRadio({
    required this.isActive,
    required this.scale,
  });

  final bool isActive;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 28 * scale;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? _teal : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black,
          width: 3 * scale,
        ),
      ),
    );
  }
}

class _ProfileIdLine extends StatelessWidget {
  const _ProfileIdLine({
    required this.profile,
    required this.isActive,
    required this.scale,
  });

  final StudentProfile profile;
  final bool isActive;
  final double scale;

  Future<void> _copyProfileCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.profileCodeCopied)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileCode = profile.profileCode?.trim();
    if (profileCode == null || profileCode.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = isActive ? const Color(0xFF604950) : _muted;

    return Row(
      children: [
        Flexible(
          child: Text(
            '${context.getText(AppKeys.profileCodeLabel)}: $profileCode',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: color,
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        Material(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(8 * scale),
          child: InkWell(
            onTap: () => _copyProfileCode(context, profileCode),
            borderRadius: BorderRadius.circular(8 * scale),
            child: SizedBox(
              height: 24 * scale,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      color: const Color(0xFF5E6A70),
                      size: 15 * scale,
                    ),
                    SizedBox(width: 7 * scale),
                    Icon(
                      Icons.qr_code_2_rounded,
                      color: const Color(0xFF5E6A70),
                      size: 15 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoLine extends StatelessWidget {
  const _ProfileInfoLine({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.scale,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18 * scale),
        SizedBox(width: 8 * scale),
        Text(
          '$label : ',
          style: GoogleFonts.andika(
            color: iconColor,
            fontSize: FontSize.small * scale,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: iconColor,
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileIconButton extends StatelessWidget {
  const _ProfileIconButton({
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10 * scale),
        child: SizedBox(
          width: 42 * scale,
          height: 42 * scale,
          child: Icon(icon, color: foregroundColor, size: 23 * scale),
        ),
      ),
    );
  }
}

class _ProfileStatePanel extends StatelessWidget {
  const _ProfileStatePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 360 * scale),
      padding: EdgeInsets.all(28 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _teal, size: 54 * scale),
          SizedBox(height: 18 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: _deepInk,
              fontSize: FontSize.title * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: _muted,
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
          if (buttonLabel != null && onTap != null) ...[
            SizedBox(height: 20 * scale),
            Material(
              color: _navy,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 22 * scale,
                    vertical: 12 * scale,
                  ),
                  child: Text(
                    buttonLabel!,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.small * scale,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
