part of '../home_screen.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.height,
    required this.bottomInset,
    required this.scale,
    required this.activeIndex,
    required this.activeRole,
    required this.user,
    required this.onTabSelected,
  });

  final double height;
  final double bottomInset;
  final double scale;
  final int activeIndex;
  final ProfileRole activeRole;
  final LoginUser? user;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final items = switch (activeRole) {
      ProfileRole.teacher => [
          HomeNavItemData(
            Icons.home_filled,
            context.getText(AppKeys.navHome),
            null,
          ),
          HomeNavItemData(
            Icons.bar_chart_rounded,
            context.getText(AppKeys.navClassroom),
            null,
          ),
          HomeNavItemData(
            Icons.menu_book_rounded,
            context.getText(AppKeys.navStudy),
            null,
          ),
          HomeNavItemData(
            Icons.chat_bubble_outline_rounded,
            context.getText(AppKeys.navMembers),
            null,
          ),
          HomeNavItemData(null, context.getText(AppKeys.navSettings), user),
        ],
      ProfileRole.student => [
          HomeNavItemData(
            null,
            context.getText(AppKeys.navHome),
            null,
            assetPath: _studentHomeNavHome,
          ),
          HomeNavItemData(
            null,
            context.getText(AppKeys.navClassroom),
            null,
            assetPath: _studentHomeNavClass,
          ),
          HomeNavItemData(
            null,
            context.getText(AppKeys.navReview),
            null,
            assetPath: _studentHomeNavReport,
          ),
          HomeNavItemData(
            null,
            context.getText(AppKeys.navHistory),
            null,
            assetPath: _studentHomeNavMessage,
          ),
          HomeNavItemData(
            null,
            context.getText(AppKeys.navSettings),
            null,
            assetPath: _studentHomeNavSettings,
          ),
        ],
      ProfileRole.parent => [
          HomeNavItemData(
            Icons.home_filled,
            context.getText(AppKeys.navHome),
            null,
          ),
          HomeNavItemData(
            Icons.assignment_turned_in_outlined,
            context.getText(AppKeys.navAssessment),
            null,
          ),
          HomeNavItemData(
            Icons.meeting_room_outlined,
            context.getText(AppKeys.navRoom),
            null,
          ),
          HomeNavItemData(
            Icons.sports_esports_rounded,
            context.getText(AppKeys.navGames),
            null,
          ),
          HomeNavItemData(null, context.getText(AppKeys.navSettings), user),
        ],
    };

    final radius = BorderRadius.vertical(
      top: Radius.circular(48 * scale),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30 * scale,
            offset: Offset(0, -8 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: height,
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              12 * scale,
              20 * scale,
              bottomInset + 12 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: radius,
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                return Expanded(
                  child: HomeAnimatedNavItem(
                    data: items[index],
                    active: activeIndex == index,
                    teacherStyle: activeRole == ProfileRole.teacher,
                    scale: scale,
                    onTap: () => onTabSelected(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeAnimatedNavItem extends StatelessWidget {
  const HomeAnimatedNavItem({
    super.key,
    required this.data,
    required this.active,
    required this.teacherStyle,
    required this.scale,
    required this.onTap,
  });

  final HomeNavItemData data;
  final bool active;
  final bool teacherStyle;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF38898B);
    final inactiveColor = const Color(0xFF515F54).withValues(alpha: 0.68);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(end: active ? 1 : 0),
      builder: (context, value, child) {
        final color = Color.lerp(inactiveColor, Colors.white, value)!;
        return AnimatedScale(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          scale: active ? 1 : 0.98,
          child: Semantics(
            selected: active,
            button: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(48 * scale),
                child: Container(
                  height: 60 * scale,
                  margin: EdgeInsets.symmetric(horizontal: 2 * scale),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale,
                    vertical: 9 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: active ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(48 * scale),
                    boxShadow: active && !teacherStyle
                        ? [
                            BoxShadow(
                              color: _teal.withValues(alpha: 0.20),
                              blurRadius: 15 * scale,
                              offset: Offset(0, 10 * scale),
                            ),
                            BoxShadow(
                              color: _teal.withValues(alpha: 0.20),
                              blurRadius: 6 * scale,
                              offset: Offset(0, 4 * scale),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox.square(
                        dimension: 22 * scale,
                        child: Center(
                          child: data.user != null
                              ? HomeUserAvatarWidget(
                                  user: data.user!,
                                  size: 20 * scale,
                                  color: color,
                                )
                              : data.assetPath != null
                                  ? SvgPicture.asset(
                                      data.assetPath!,
                                      width: 20 * scale,
                                      height: 20 * scale,
                                      colorFilter: ColorFilter.mode(
                                        color,
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : Icon(
                                      data.icon,
                                      color: color,
                                      size: 20 * scale,
                                    ),
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          data.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.andika(
                            color: color,
                            fontSize: FontSize.caption * 0.77 * scale,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomeUserAvatarWidget extends StatelessWidget {
  const HomeUserAvatarWidget({
    super.key,
    required this.user,
    required this.size,
    required this.color,
  });

  final LoginUser user;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarImage(
      size: size,
      avatarUrl: user.avatarUrl,
      foregroundColor: color,
      borderColor: color,
      borderWidth: 1.5,
      iconScale: 0.58,
    );
  }
}

class HomeNavItemData {
  const HomeNavItemData(
    this.icon,
    this.label,
    this.user, {
    this.assetPath,
  });

  final IconData? icon;
  final String label;
  final LoginUser? user;
  final String? assetPath;
}
