part of '../setting_tab.dart';

class _SettingsMenuPanel extends StatelessWidget {
  const _SettingsMenuPanel({
    super.key,
    required this.avatarUrl,
    required this.avatarPath,
    required this.username,
    required this.scale,
    required this.onAccountTap,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final String username;
  final double scale;
  final VoidCallback onAccountTap;
  final VoidCallback onProfileTap;
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
          style: TextStyle(
            color: _deepInk,
            fontFamily: 'Nunito',
            fontSize: 26 * scale,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 34 * scale),
        _SettingsActionCard(
          icon: Icons.account_circle_outlined,
          iconColor: const Color(0xFFC21873),
          iconBackground: const Color(0xFFFFF0F7),
          title: 'Tài Khoản',
          subtitle: 'Quản lý thông tin tài khoản',
          scale: scale,
          onTap: onAccountTap,
        ),
        SizedBox(height: 12 * scale),
        _SettingsActionCard(
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF008A52),
          iconBackground: const Color(0xFFD6FFE3),
          title: 'Hồ Sơ',
          subtitle: 'Xem và chỉnh sửa hồ sơ',
          scale: scale,
          onTap: onProfileTap,
        ),
        SizedBox(height: 12 * scale),
        _SettingsActionCard(
          icon: Icons.logout_rounded,
          iconColor: _orange,
          iconBackground: const Color(0xFFFFD8D8),
          title: 'Logout',
          subtitle: 'Đăng xuất khỏi tài khoản',
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
    final size = 118 * scale;

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
        padding: EdgeInsets.all(20 * scale),
        child: Image.asset(
          'assets/images/welcome_numi_character.png',
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      width: size + 22 * scale,
      height: size + 22 * scale,
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
                  color: const Color(0xFFFF61AE),
                  width: 4 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF61AE).withValues(alpha: 0.18),
                    blurRadius: 16 * scale,
                    offset: Offset(0, 7 * scale),
                  ),
                ],
              ),
              child: ClipOval(child: avatarChild),
            ),
          ),
          Positioned(
            right: 6 * scale,
            bottom: 16 * scale,
            child: Container(
              width: 26 * scale,
              height: 26 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF55E66E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3 * scale),
              ),
            ),
          ),
        ],
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
    final radius = BorderRadius.circular(24 * scale);

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 82 * scale,
          padding: EdgeInsets.symmetric(horizontal: 17 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(color: _cardBorder, width: 1.1 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46 * scale,
                height: 46 * scale,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24 * scale),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDestructive ? _orange : _deepInk,
                        fontFamily: 'Nunito',
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 7 * scale),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF604950),
                        fontFamily: 'Nunito',
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFD5A8BA),
                size: 28 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
