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
  final String? activeProfileId;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _ProfileAddButton(scale: scale, onTap: onAdd),
        ),
        SizedBox(height: 10 * scale),
        for (var index = 0; index < profiles.length; index++) ...[
          _ProfileCard(
            profile: profiles[index],
            isActive: ActiveProfileSession.profileStableId(profiles[index]) ==
                activeProfileId,
            scale: scale,
            onSelect: () => onSelect(profiles[index]),
            onEdit: () => onEdit(profiles[index]),
            onDelete: () => onDelete(profiles[index]),
          ),
          if (index != profiles.length - 1) SizedBox(height: 22 * scale),
        ],
      ],
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
      color: const Color(0xFFB72D83),
      elevation: 4,
      shadowColor: const Color(0xFFB72D83).withValues(alpha: 0.20),
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
    final accent = isActive ? _teal : const Color(0xFF9CAAA5);
    final radius = BorderRadius.circular(18 * scale);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onSelect,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.fromLTRB(
              20 * scale, 18 * scale, 16 * scale, 18 * scale),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isActive ? 0.96 : 0.84),
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
                  const Spacer(),
                  _ProfileRadio(isActive: isActive, scale: scale),
                ],
              ),
              SizedBox(height: 18 * scale),
              Text(
                _displayProfileName(context, profile),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: isActive ? _deepInk : const Color(0xFF9CAAA5),
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 17 * scale),
              _ProfileIdLine(
                  profile: profile, isActive: isActive, scale: scale),
              SizedBox(height: 14 * scale),
              _ProfileInfoLine(
                icon: Icons.school_outlined,
                iconColor: accent,
                label: context.getText(AppKeys.grade),
                value: _displayGrade(context, profile),
                scale: scale,
              ),
              SizedBox(height: 14 * scale),
              _ProfileInfoLine(
                icon: Icons.book_outlined,
                iconColor: accent,
                label: context.getText(AppKeys.program),
                value: _displayProgram(context, profile),
                scale: scale,
              ),
              SizedBox(height: 18 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ProfileIconButton(
                    icon: Icons.edit_rounded,
                    foregroundColor: isActive ? _teal : const Color(0xFF9CAAA5),
                    backgroundColor: const Color(0xFFECF6FA),
                    scale: scale,
                    onTap: onEdit,
                  ),
                  SizedBox(width: 12 * scale),
                  _ProfileIconButton(
                    icon: Icons.delete_outline_rounded,
                    foregroundColor:
                        isActive ? const Color(0xFFE83434) : Colors.white,
                    backgroundColor: isActive
                        ? const Color(0xFFFFD8D8)
                        : const Color(0xFFFFCACA),
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
    final size = 84 * scale;

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

  @override
  Widget build(BuildContext context) {
    final id = profile.id?.trim();
    if (id == null || id.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = isActive ? const Color(0xFF604950) : const Color(0xFF9CAAA5);

    return Row(
      children: [
        Flexible(
          child: Text(
            'ID: $id',
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
        Container(
          height: 24 * scale,
          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFE9ECEF),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
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
