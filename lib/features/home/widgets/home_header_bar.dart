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
    if (role == ProfileRole.parent) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: height,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding * 0.82,
              topInset + contentHeight * 0.10,
              horizontalPadding * 0.72,
              contentHeight * 0.10,
            ),
            color: Colors.white.withValues(alpha: 0.96),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: canSwitchProfile,
                    child: InkWell(
                      onTap: onProfileTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        children: [
                          ProfileAvatarImage(
                            size: contentHeight * 0.74,
                            avatarKey: profile?.avatarKey,
                            avatarUrl: profile?.avatarUrl,
                            borderColor:
                                const Color(0xFFE7DAC8).withValues(alpha: 0.9),
                            borderWidth: 1.5,
                          ),
                          SizedBox(width: contentHeight * 0.16),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _homeRoleLabel(context, role),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF6782AA),
                                    fontSize: FontSize.small,
                                    fontWeight: FontWeight.w400,
                                    // letterSpacing: 0.8,
                                    // height: 1,
                                  ),
                                ),
                                SizedBox(height: contentHeight * 0.06),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF002B6A),
                                          fontSize: FontSize.small,
                                          fontWeight: FontWeight.w600,
                                          // height: 1,
                                        ),
                                      ),
                                    ),
                                    if (canSwitchProfile) ...[
                                      SizedBox(width: contentHeight * 0.04),
                                      AnimatedRotation(
                                        turns: isProfileMenuOpen ? 0.5 : 0,
                                        duration:
                                            const Duration(milliseconds: 180),
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: contentHeight * 0.26,
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
                HomeParentFireBadge(
                  count: parentStreakCount,
                  height: contentHeight * 0.48,
                ),
                SizedBox(width: contentHeight * 0.12),
                HomeNotificationButton(size: contentHeight * 0.58),
              ],
            ),
          ),
        ),
      );
    }

    final startPadding = role == ProfileRole.student
        ? horizontalPadding * 0.82
        : horizontalPadding;
    final endPadding = role == ProfileRole.student
        ? horizontalPadding * 0.72
        : horizontalPadding;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          padding: EdgeInsets.fromLTRB(
            startPadding,
            topInset + contentHeight * 0.20,
            endPadding,
            contentHeight * 0.21,
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
                        HomeProfileAvatarWithStatus(
                          size: contentHeight * 0.45,
                          avatarKey: profile?.avatarKey,
                          avatarUrl: profile?.avatarUrl,
                        ),
                        SizedBox(width: contentHeight * 0.14),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '$name👋',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: FontSize.small,
                                          fontWeight: FontWeight.w600),
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

class HomeProfileAvatarWithStatus extends StatelessWidget {
  const HomeProfileAvatarWithStatus({
    super.key,
    required this.size,
    this.avatarKey,
    this.avatarUrl,
  });

  final double size;
  final String? avatarKey;
  final String? avatarUrl;

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
          ),
        ),
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
