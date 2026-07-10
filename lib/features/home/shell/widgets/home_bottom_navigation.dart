import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/otp_auth_api.dart';
import 'package:numi/features/home/widgets/home_visual_constants.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/widgets/profile_avatar_image.dart';

class HomeBottomNavigation extends StatefulWidget {
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
  State<HomeBottomNavigation> createState() => _HomeBottomNavigationState();
}

class _HomeBottomNavigationState extends State<HomeBottomNavigation> {
  int? _pendingActiveIndex;

  int get _activeIndex => _pendingActiveIndex ?? widget.activeIndex;

  @override
  void didUpdateWidget(covariant HomeBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pendingActiveIndex == widget.activeIndex ||
        oldWidget.activeRole != widget.activeRole) {
      _pendingActiveIndex = null;
    }
  }

  void _selectTab(int index) {
    if (index == _activeIndex) {
      return;
    }

    // Paint the selected navigation item before the target tab has a chance
    // to build or begin loading. This preserves instant touch feedback even
    // when a tab's first frame is expensive.
    setState(() => _pendingActiveIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pendingActiveIndex != index) {
        return;
      }
      widget.onTabSelected(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final items = switch (widget.activeRole) {
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
        HomeNavItemData(
          null,
          context.getText(AppKeys.navSettings),
          widget.user,
        ),
      ],
      ProfileRole.student => [
        HomeNavItemData(
          null,
          context.getText(AppKeys.navHome),
          null,
          assetPath: studentHomeNavHomeAsset,
        ),
        HomeNavItemData(
          null,
          context.getText(AppKeys.navClassroom),
          null,
          assetPath: studentHomeNavClassAsset,
        ),
        HomeNavItemData(
          null,
          context.getText(AppKeys.navReview),
          null,
          assetPath: studentHomeNavReportAsset,
        ),
        HomeNavItemData(
          null,
          context.getText(AppKeys.navHistory),
          null,
          assetPath: studentHomeNavMessageAsset,
        ),
        HomeNavItemData(
          null,
          context.getText(AppKeys.navSettings),
          null,
          assetPath: studentHomeNavSettingsAsset,
        ),
      ],
      ProfileRole.parent => [
        HomeNavItemData(
          null,
          context.getText(AppKeys.navHome),
          null,
          assetPath: parentHomeNavHomeAsset,
        ),
        HomeNavItemData(
          null,
          context.getText(AppKeys.navAssessment),
          null,
          assetPath: parentHomeNavAssessmentAsset,
        ),
        HomeNavItemData(
          null,
          context.getText(AppKeys.navRoom),
          null,
          assetPath: parentHomeNavRoomAsset,
        ),
        HomeNavItemData(
          null,
          context.getText(AppKeys.navGames),
          null,
          assetPath: parentHomeNavGameAsset,
        ),
        HomeNavItemData(
          null,
          context.getText(AppKeys.navSettings),
          null,
          assetPath: parentHomeNavSettingsAsset,
        ),
      ],
    };

    final radius = BorderRadius.vertical(
      top: Radius.circular(48 * widget.scale),
    );

    return Container(
      height: widget.height,
      padding: EdgeInsets.fromLTRB(
        20 * widget.scale,
        12 * widget.scale,
        20 * widget.scale,
        widget.bottomInset + 12 * widget.scale,
      ),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: radius,
        border: Border(
          top: BorderSide(
            color: colors.shadow.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 20 * widget.scale,
            offset: Offset(0, -6 * widget.scale),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          return Expanded(
            child: HomeAnimatedNavItem(
              data: items[index],
              active: _activeIndex == index,
              teacherStyle: widget.activeRole == ProfileRole.teacher,
              scale: widget.scale,
              onTap: () => _selectTab(index),
            ),
          );
        }),
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
    final colors = context.themeColors;
    final activeColor = colors.brandStrong;
    final inactiveColor = colors.textSecondary.withValues(alpha: 0.68);
    final foregroundColor = active
        ? Theme.of(context).colorScheme.onPrimary
        : inactiveColor;

    return Semantics(
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
                        color: colors.brand.withValues(alpha: 0.20),
                        blurRadius: 15 * scale,
                        offset: Offset(0, 10 * scale),
                      ),
                      BoxShadow(
                        color: colors.brand.withValues(alpha: 0.20),
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
                  child: Center(child: _buildIcon(foregroundColor)),
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
                      color: foregroundColor,
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
    );
  }

  Widget _buildIcon(Color color) {
    final user = data.user;
    if (user != null) {
      return HomeUserAvatarWidget(user: user, size: 20 * scale, color: color);
    }

    final assetPath = data.assetPath;
    if (assetPath != null) {
      return SvgPicture.asset(
        assetPath,
        width: 20 * scale,
        height: 20 * scale,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return Icon(data.icon, color: color, size: 20 * scale);
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
  const HomeNavItemData(this.icon, this.label, this.user, {this.assetPath});

  final IconData? icon;
  final String label;
  final LoginUser? user;
  final String? assetPath;
}
