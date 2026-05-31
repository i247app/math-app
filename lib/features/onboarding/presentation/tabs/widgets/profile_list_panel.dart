part of '../setting_tab.dart';

class _ProfilePlaceholderPanel extends StatelessWidget {
  const _ProfilePlaceholderPanel({
    super.key,
    required this.profiles,
    required this.activeProfileId,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onAdd,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.scale,
  });

  final List<StudentProfile> profiles;
  final int? activeProfileId;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onAdd;
  final ValueChanged<StudentProfile> onSelect;
  final ValueChanged<StudentProfile> onEdit;
  final ValueChanged<StudentProfile> onDelete;
  final double scale;

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
        buttonLabel: context.getText(AppKeys.addProfile),
        scale: scale,
        onTap: onAdd,
      );
    }

    final sortedProfiles = _activeFirstProfiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _ProfileAddButton(scale: scale, onTap: onAdd),
        ),
        SizedBox(height: 10 * scale),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: _deepInk,
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 10 * scale),
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
                icon: _roleIcon(role),
                iconColor: accent,
                label: context.getText(AppKeys.profileRole),
                value: _localizedRole(context, role),
                scale: scale,
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

IconData _roleIcon(ProfileRole role) {
  return switch (role) {
    ProfileRole.teacher => Icons.co_present_rounded,
    ProfileRole.parent => Icons.family_restroom_rounded,
    ProfileRole.student => Icons.person_rounded,
  };
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

  Future<void> _copyProfileId(BuildContext context, int id) async {
    await Clipboard.setData(ClipboardData(text: _displayProfileId(id)));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.profileIdCopied)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = profile.id;
    if (id == null) {
      return const SizedBox.shrink();
    }

    final color = isActive ? const Color(0xFF604950) : _muted;

    return Row(
      children: [
        Flexible(
          child: Text(
            'ID: ${_displayProfileId(id)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: color,
              fontSize: 14 * scale,
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
            onTap: () => _copyProfileId(context, id),
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

String _displayProfileId(int id) => '$id';

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
            fontSize: 14 * scale,
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
              fontSize: 14 * scale,
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
  final String buttonLabel;
  final double scale;
  final VoidCallback onTap;

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
              fontSize: 22 * scale,
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
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
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
                  buttonLabel,
                  style: GoogleFonts.andika(
                    color: Colors.white,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
