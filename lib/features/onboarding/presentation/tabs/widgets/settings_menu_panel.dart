part of '../setting_tab.dart';

class _SettingsMenuPanel extends StatelessWidget {
  const _SettingsMenuPanel({
    super.key,
    required this.avatarUrl,
    required this.avatarPath,
    required this.username,
    required this.scale,
    required this.currentLanguage,
    required this.onAccountTap,
    required this.onProfileTap,
    required this.onLanguageChanged,
    required this.onLogoutTap,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final String username;
  final double scale;
  final AppLanguage currentLanguage;
  final VoidCallback onAccountTap;
  final VoidCallback onProfileTap;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4 * scale),
        _SettingsAvatar(
          avatarUrl: avatarUrl,
          avatarPath: avatarPath,
          scale: scale,
        ),
        SizedBox(height: 14 * scale),
        Text(
          username,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: _deepInk,
            fontSize: 24 * scale,
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
}

class _SettingsAvatar extends StatelessWidget {
  const _SettingsAvatar({
    required this.avatarUrl,
    required this.avatarPath,
    required this.scale,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final path = avatarPath?.trim();
    final size = 92 * scale;

    Widget avatarChild;
    if (path != null && path.isNotEmpty) {
      avatarChild = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _AccountDefaultAvatar(scale: scale),
      );
    } else if (url != null && url.isNotEmpty) {
      avatarChild = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _AccountDefaultAvatar(scale: scale),
      );
    } else {
      avatarChild = Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Image.asset(
          'assets/images/numi-mascot.png',
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      width: size + 20 * scale,
      height: size + 20 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(4 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE8601C),
                  width: 3.2 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8601C).withValues(alpha: 0.15),
                    blurRadius: 14 * scale,
                    offset: Offset(0, 5 * scale),
                  ),
                ],
              ),
              child: ClipOval(child: avatarChild),
            ),
          ),
          Positioned(
            right: 8 * scale,
            bottom: 14 * scale,
            child: Container(
              width: 22 * scale,
              height: 22 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF55E66E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Language card with inline dropdown pill
class _SettingsLanguageCard extends StatelessWidget {
  const _SettingsLanguageCard({
    required this.currentLanguage,
    required this.scale,
    required this.onLanguageChanged,
  });

  final AppLanguage currentLanguage;
  final double scale;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16 * scale);

    return Container(
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
                fontSize: 15 * scale,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
          _LanguagePill(
            currentLanguage: currentLanguage,
            scale: scale,
            onLanguageChanged: onLanguageChanged,
          ),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.currentLanguage,
    required this.scale,
    required this.onLanguageChanged,
  });

  final AppLanguage currentLanguage;
  final double scale;
  final ValueChanged<AppLanguage> onLanguageChanged;

  String _flagFor(AppLanguage lang) {
    return switch (lang) {
      AppLanguage.vi => '🇻🇳',
      AppLanguage.en => '🇬🇧',
    };
  }

  @override
  Widget build(BuildContext context) {
    final flag = _flagFor(currentLanguage);
    final label = currentLanguage.displayName;

    return PopupMenuButton<AppLanguage>(
      tooltip: '',
      onSelected: (lang) {
        HapticFeedback.selectionClick();
        onLanguageChanged(lang);
      },
      itemBuilder: (context) {
        return AppLanguage.values.map((lang) {
          final isSelected = lang == currentLanguage;
          return PopupMenuItem<AppLanguage>(
            value: lang,
            child: Row(
              children: [
                Text(
                  _flagFor(lang),
                  style: TextStyle(fontSize: 16 * scale),
                ),
                SizedBox(width: 8 * scale),
                Text(
                  lang.displayName,
                  style: GoogleFonts.andika(
                    fontSize: 14 * scale,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? _teal : _deepInk,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(Icons.check_rounded, color: _teal, size: 18 * scale),
                ],
              ],
            ),
          );
        }).toList();
      },
      offset: Offset(0, 44 * scale),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Container(
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
              flag,
              style: TextStyle(fontSize: 14 * scale),
            ),
            SizedBox(width: 5 * scale),
            Text(
              label,
              style: GoogleFonts.andika(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF006762),
                letterSpacing: 0,
              ),
            ),
          ],
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
                        fontSize: 15 * scale,
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
                        fontSize: 12 * scale,
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
