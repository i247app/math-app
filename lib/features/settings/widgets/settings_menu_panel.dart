part of '../setting_tab.dart';

class _SettingsMenuPanel extends StatelessWidget {
  const _SettingsMenuPanel({
    super.key,
    required this.activeProfile,
    required this.fallbackAvatarUrl,
    required this.fallbackAvatarPath,
    required this.username,
    required this.scale,
    required this.currentLanguage,
    required this.hasPasscode,
    required this.isLoadingPasscode,
    required this.onAccountTap,
    required this.onProfileTap,
    required this.onPasscodeTap,
    required this.onLanguageChanged,
    required this.onLogoutTap,
  });

  final StudentProfile? activeProfile;
  final String? fallbackAvatarUrl;
  final String? fallbackAvatarPath;
  final String username;
  final double scale;
  final AppLanguage currentLanguage;
  final bool hasPasscode;
  final bool isLoadingPasscode;
  final VoidCallback onAccountTap;
  final VoidCallback onProfileTap;
  final VoidCallback onPasscodeTap;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4 * scale),
        _SettingsAvatar(
          activeProfile: activeProfile,
          fallbackAvatarUrl: fallbackAvatarUrl,
          fallbackAvatarPath: fallbackAvatarPath,
          scale: scale,
          onSwitchTap: onProfileTap,
        ),
        SizedBox(height: 14 * scale),
        Text(
          _displayName(context),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: _deepInk,
            fontSize: FontSize.title * scale,
            fontWeight: FontWeight.w700,
            height: 1.05,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 32 * scale),
        _SettingsActionCard(
          icon: Icons.account_circle_outlined,
          iconColor: const Color(0xFFC21873),
          iconBackground: const Color(0xFFFFF0F7),
          title: context.getText(AppKeys.accountMenuTitle),
          subtitle: context.getText(AppKeys.accountMenuSubtitle),
          scale: scale,
          onTap: onAccountTap,
        ),
        SizedBox(height: 12 * scale),
        _SettingsActionCard(
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF008A52),
          iconBackground: const Color(0xFFD6FFE3),
          title: context.getText(AppKeys.profileMenuTitle),
          subtitle: context.getText(AppKeys.profileMenuSubtitle),
          scale: scale,
          onTap: onProfileTap,
        ),
        SizedBox(height: 12 * scale),
        _SettingsActionCard(
          icon: Icons.lock_outline_rounded,
          iconColor: const Color(0xFF327F84),
          iconBackground: const Color(0xFFE5F7F8),
          title: context.getText(AppKeys.passcodeMenuTitle),
          subtitle: isLoadingPasscode
              ? context.getText(AppKeys.loading)
              : context.getText(
                  hasPasscode
                      ? AppKeys.passcodeMenuSubtitleManage
                      : AppKeys.passcodeMenuSubtitleSet,
                ),
          scale: scale,
          onTap: onPasscodeTap,
        ),
        SizedBox(height: 12 * scale),
        _SettingsLanguageCard(
          currentLanguage: currentLanguage,
          scale: scale,
          onLanguageChanged: onLanguageChanged,
        ),
        SizedBox(height: 12 * scale),
        _SettingsActionCard(
          icon: Icons.logout_rounded,
          iconColor: _orange,
          iconBackground: const Color(0xFFFFEAEA),
          title: context.getText(AppKeys.logout),
          subtitle: context.getText(AppKeys.logoutSubtitle),
          isDestructive: true,
          scale: scale,
          onTap: () {
            HapticFeedback.selectionClick();
            onLogoutTap();
          },
        ),
      ],
    );
  }

  String _displayName(BuildContext context) {
    final name = activeProfile?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return username;
  }
}

enum _PasscodeSettingsAction {
  change,
  remove,
}

class _PasscodeSettingsSheet extends StatelessWidget {
  const _PasscodeSettingsSheet({
    required this.scale,
    required this.onChange,
    required this.onRemove,
  });

  final double scale;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.all(16 * scale),
        padding: EdgeInsets.all(18 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18 * scale,
              offset: Offset(0, 8 * scale),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SettingsActionCard(
              icon: Icons.edit_outlined,
              iconColor: const Color(0xFF327F84),
              iconBackground: const Color(0xFFE5F7F8),
              title: context.getText(AppKeys.passcodeChange),
              subtitle: context.getText(AppKeys.passcodeMenuSubtitleManage),
              scale: scale,
              onTap: onChange,
            ),
            SizedBox(height: 12 * scale),
            _SettingsActionCard(
              icon: Icons.lock_open_rounded,
              iconColor: _orange,
              iconBackground: const Color(0xFFFFEAEA),
              title: context.getText(AppKeys.passcodeRemove),
              subtitle: context.getText(AppKeys.passcodeRemove),
              isDestructive: true,
              scale: scale,
              onTap: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsAvatar extends StatelessWidget {
  const _SettingsAvatar({
    required this.activeProfile,
    required this.fallbackAvatarUrl,
    required this.fallbackAvatarPath,
    required this.scale,
    required this.onSwitchTap,
  });

  final StudentProfile? activeProfile;
  final String? fallbackAvatarUrl;
  final String? fallbackAvatarPath;
  final double scale;
  final VoidCallback onSwitchTap;

  @override
  Widget build(BuildContext context) {
    final size = 92 * scale;

    return SizedBox(
      width: size + 20 * scale,
      height: size + 20 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8601C).withValues(alpha: 0.15),
                    blurRadius: 14 * scale,
                    offset: Offset(0, 5 * scale),
                  ),
                ],
              ),
              child: ProfileAvatarImage(
                size: size,
                avatarKey: activeProfile?.avatarKey,
                avatarUrl: activeProfile?.avatarUrl ?? fallbackAvatarUrl,
                avatarPath: activeProfile == null ? fallbackAvatarPath : null,
                borderColor: const Color(0xFFE8601C),
                borderWidth: 3.2 * scale,
                padding: EdgeInsets.all(4 * scale),
              ),
            ),
          ),
          Positioned(
            right: 8 * scale,
            bottom: 14 * scale,
            child: Semantics(
              button: true,
              label: context.getText(AppKeys.profileMenuTitle),
              child: Material(
                color: _teal,
                elevation: 5,
                shadowColor: _teal.withValues(alpha: 0.22),
                shape: CircleBorder(
                  side: BorderSide(color: Colors.white, width: 2.5 * scale),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSwitchTap,
                  child: SizedBox(
                    width: 30 * scale,
                    height: 30 * scale,
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 18 * scale,
                    ),
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

class _SettingsLanguageCard extends StatelessWidget {
  const _SettingsLanguageCard({
    required this.currentLanguage,
    required this.scale,
    required this.onLanguageChanged,
  });

  final AppLanguage currentLanguage;
  final double scale;
  final ValueChanged<AppLanguage> onLanguageChanged;

  Future<void> _showLanguageSheet(BuildContext context) async {
    HapticFeedback.selectionClick();
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (sheetContext) {
        return _LanguageBottomSheet(
          currentLanguage: currentLanguage,
          scale: scale,
        );
      },
    );

    if (selected == null || selected == currentLanguage) {
      return;
    }
    onLanguageChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16 * scale);

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: radius,
      child: InkWell(
        onTap: () => _showLanguageSheet(context),
        borderRadius: radius,
        child: Container(
          height: 72 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10 * scale,
                offset: Offset(0, 3 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42 * scale,
                height: 42 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF3F8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language_rounded,
                  color: const Color(0xFF5B7AA0),
                  size: 22 * scale,
                ),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Text(
                  context.getText(AppKeys.language),
                  style: GoogleFonts.andika(
                    color: _deepInk,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _LanguagePill(
                currentLanguage: currentLanguage,
                scale: scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.currentLanguage,
    required this.scale,
  });

  final AppLanguage currentLanguage;
  final double scale;

  static String _flagFor(AppLanguage lang) {
    return switch (lang) {
      AppLanguage.vi => '🇻🇳',
      AppLanguage.en => '🇬🇧',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 7 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: const Color(0xFF006762),
          width: 1.5 * scale,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _flagFor(currentLanguage),
            style: TextStyle(fontSize: FontSize.small * scale),
          ),
          SizedBox(width: 5 * scale),
          Text(
            currentLanguage.displayName,
            style: GoogleFonts.andika(
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF006762),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageBottomSheet extends StatelessWidget {
  const _LanguageBottomSheet({
    required this.currentLanguage,
    required this.scale,
  });

  final AppLanguage currentLanguage;
  final double scale;

  static String _flagFor(AppLanguage lang) {
    return switch (lang) {
      AppLanguage.vi => '🇻🇳',
      AppLanguage.en => '🇬🇧',
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16 * scale,
          0,
          16 * scale,
          math.max(14 * scale, bottomInset + 10 * scale),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 24 * scale,
                offset: Offset(0, 12 * scale),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              18 * scale,
              12 * scale,
              18 * scale,
              18 * scale,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42 * scale,
                  height: 5 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E2E0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(height: 18 * scale),
                Text(
                  context.getText(AppKeys.languageTitle),
                  style: GoogleFonts.andika(
                    color: _deepInk,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 18 * scale),
                for (final language in AppLanguage.values) ...[
                  _LanguageSheetOption(
                    flag: _flagFor(language),
                    label: switch (language) {
                      AppLanguage.vi =>
                        context.getText(AppKeys.languageVietnamese),
                      AppLanguage.en =>
                        context.getText(AppKeys.languageEnglish),
                    },
                    selected: language == currentLanguage,
                    scale: scale,
                    onTap: () => Navigator.of(context).pop(language),
                  ),
                  if (language != AppLanguage.values.last)
                    SizedBox(height: 10 * scale),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageSheetOption extends StatelessWidget {
  const _LanguageSheetOption({
    required this.flag,
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18 * scale);

    return Material(
      color: selected ? const Color(0xFFFFF2F8) : const Color(0xFFF7FBFB),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 14 * scale,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color:
                  selected ? const Color(0xFFC1277D) : const Color(0xFFDCE6E3),
              width: selected ? 2 * scale : 1.2 * scale,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: TextStyle(fontSize: FontSize.title * scale)),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _deepInk,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Container(
                width: 30 * scale,
                height: 30 * scale,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFC1277D) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC1277D),
                    width: 2 * scale,
                  ),
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20 * scale,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.scale,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final double scale;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16 * scale);

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 72 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10 * scale,
                offset: Offset(0, 3 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42 * scale,
                height: 42 * scale,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22 * scale),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: isDestructive ? _orange : _deepInk,
                        fontSize: FontSize.normal * scale,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 5 * scale),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: const Color(0xFF8A9BA8),
                        fontSize: FontSize.caption * scale,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFB8C8D0),
                size: 26 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
