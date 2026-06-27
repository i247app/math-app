part of '../home_screen.dart';

class HomeHeaderBar extends StatelessWidget {
  const HomeHeaderBar({
    super.key,
    required this.height,
    required this.topInset,
    required this.horizontalPadding,
    required this.name,
    required this.profile,
    required this.role,
    required this.canSwitchProfile,
    required this.isProfileMenuOpen,
    required this.parentStreakCount,
    required this.onProfileTap,
  });

  final double height;
  final double topInset;
  final double horizontalPadding;
  final String name;
  final StudentProfile? profile;
  final ProfileRole role;
  final bool canSwitchProfile;
  final bool isProfileMenuOpen;
  final int parentStreakCount;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final contentHeight = height - topInset;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topInset + contentHeight * 0.10,
            horizontalPadding,
            contentHeight * 0.10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: canSwitchProfile,
                  child: InkWell(
                    onTap: onProfileTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HomeProfileAvatar(
                          size: contentHeight * 0.58,
                          avatarKey: profile?.avatarKey,
                          avatarUrl: profile?.avatarUrl,
                          showStatus: role != ProfileRole.parent,
                          borderColor: role == ProfileRole.parent
                              ? const Color(0xFFE7DAC8)
                              : null,
                        ),
                        SizedBox(width: contentHeight * 0.14),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _homeRoleLabel(context, role),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: FontSize.small,
                                  fontWeight: FontWeight.w400,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      role == ProfileRole.parent
                                          ? name
                                          : '$name👋',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: FontSize.small,
                                          fontWeight: FontWeight.w600,
                                          height: 1.05),
                                    ),
                                  ),
                                  if (canSwitchProfile) ...[
                                    SizedBox(width: contentHeight * 0.06),
                                    AnimatedRotation(
                                      turns: isProfileMenuOpen ? 0.5 : 0,
                                      duration:
                                          const Duration(milliseconds: 180),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: contentHeight * 0.18,
                                        color: const Color(0xFF8294B0),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (role == ProfileRole.parent) ...[
                HomeParentFireBadge(
                  count: parentStreakCount,
                  height: contentHeight * 0.45,
                ),
                SizedBox(width: contentHeight * 0.12),
              ],
              HomeNotificationButton(size: contentHeight * 0.45),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeParentFireBadge extends StatelessWidget {
  const HomeParentFireBadge({
    super.key,
    required this.count,
    required this.height,
  });

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: height * 1.5),
      padding: EdgeInsets.symmetric(horizontal: height * 0.30),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EC),
        borderRadius: BorderRadius.circular(height),
        border: Border.all(color: const Color(0xFFFFCBAF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: const Color(0xFFFF650B),
            size: height * 0.66,
          ),
          Text(
            '$count',
            style: TextStyle(
              color: const Color(0xFFFF650B),
              fontSize: FontSize.caption * (height / 30),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeProfileAvatar extends StatelessWidget {
  const HomeProfileAvatar({
    super.key,
    required this.size,
    this.avatarKey,
    this.avatarUrl,
    this.borderColor,
    this.showStatus = true,
  });

  final double size;
  final String? avatarKey;
  final String? avatarUrl;
  final Color? borderColor;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _teal.withValues(alpha: 0.05),
                spreadRadius: size * 0.08,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.11),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ProfileAvatarImage(
            size: size,
            avatarKey: avatarKey,
            avatarUrl: avatarUrl,
            borderColor: borderColor?.withValues(alpha: 0.9),
            borderWidth: borderColor == null ? 0 : 1.5,
          ),
        ),
        if (showStatus)
          Positioned(
            right: -size * 0.05,
            bottom: -size * 0.05,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: _mintBackground, width: size * 0.05),
              ),
            ),
          ),
      ],
    );
  }
}

class HomeNotificationButton extends StatelessWidget {
  const HomeNotificationButton({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 2,
      borderRadius: BorderRadius.circular(size * 0.36),
      child: InkWell(
        onTap: HapticFeedback.selectionClick,
        borderRadius: BorderRadius.circular(size * 0.36),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SvgPicture.asset(
              _studentHomeBell,
              width: size * 0.40,
              height: size * 0.50,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
