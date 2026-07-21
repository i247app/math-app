import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/widgets/profile_avatar_image.dart';

class DashboardBottomNavigation extends StatefulWidget {
  const DashboardBottomNavigation({
    super.key,
    required this.bottomInset,
    required this.activeIndex,
    required this.activeRole,
    required this.user,
    required this.onTabSelected,
  });

  final double bottomInset;
  final int activeIndex;
  final ProfileRole activeRole;
  final LoginUser? user;
  final ValueChanged<int> onTabSelected;

  @override
  State<DashboardBottomNavigation> createState() =>
      _DashboardBottomNavigationState();
}

class _DashboardBottomNavigationState extends State<DashboardBottomNavigation> {
  int? _pendingActiveIndex;

  int get _activeIndex => _pendingActiveIndex ?? widget.activeIndex;

  @override
  void didUpdateWidget(covariant DashboardBottomNavigation oldWidget) {
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
        DashboardNavItemData(
          Icons.home_filled,
          context.getText(AppKeys.navHome),
          null,
        ),
        DashboardNavItemData(
          Icons.bar_chart_rounded,
          context.getText(AppKeys.navClassroom),
          null,
        ),
        DashboardNavItemData(
          Icons.menu_book_rounded,
          context.getText(AppKeys.navStudy),
          null,
        ),
        DashboardNavItemData(
          Icons.chat_bubble_outline_rounded,
          context.getText(AppKeys.navMembers),
          null,
        ),
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navSettings),
          widget.user,
        ),
      ],
      ProfileRole.student => [
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navHome),
          null,
          assetPath: studentHomeNavHomeAsset,
        ),
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navClassroom),
          null,
          assetPath: studentHomeNavClassAsset,
        ),
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navReview),
          null,
          assetPath: studentHomeNavReportAsset,
        ),
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navHistory),
          null,
          assetPath: studentHomeNavMessageAsset,
        ),
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navSettings),
          null,
          assetPath: studentHomeNavSettingsAsset,
        ),
      ],
      ProfileRole.parent => [
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navHome),
          null,
          assetPath: parentHomeNavHomeAsset,
        ),
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navAssessment),
          null,
          assetPath: parentHomeNavAssessmentAsset,
        ),
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navRoom),
          null,
          assetPath: parentHomeNavRoomAsset,
        ),
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navGames),
          null,
          assetPath: parentHomeNavGameAsset,
        ),
        DashboardNavItemData(
          null,
          context.getText(AppKeys.navSettings),
          null,
          assetPath: parentHomeNavSettingsAsset,
        ),
      ],
    };

    const radius = BorderRadius.vertical(top: Radius.circular(48));

    return Container(
      height: 88 + widget.bottomInset,
      padding: EdgeInsets.fromLTRB(20, 12, 20, widget.bottomInset + 12),
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
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          return Expanded(
            child: DashboardAnimatedNavItem(
              data: items[index],
              active: _activeIndex == index,
              teacherStyle: widget.activeRole == ProfileRole.teacher,
              onTap: () => _selectTab(index),
            ),
          );
        }),
      ),
    );
  }
}

class DashboardAnimatedNavItem extends StatelessWidget {
  const DashboardAnimatedNavItem({
    super.key,
    required this.data,
    required this.active,
    required this.teacherStyle,
    required this.onTap,
  });

  final DashboardNavItemData data;
  final bool active;
  final bool teacherStyle;
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
          borderRadius: BorderRadius.circular(48),
          child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
            decoration: BoxDecoration(
              color: active ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(48),
              boxShadow: active && !teacherStyle
                  ? [
                      BoxShadow(
                        color: colors.brand.withValues(alpha: 0.20),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: colors.brand.withValues(alpha: 0.20),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                SizedBox.square(
                  dimension: 22,
                  child: Center(child: _buildIcon(foregroundColor)),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.label,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.andika(
                        color: foregroundColor,
                        fontSize: FontSize.caption * 0.77,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0.5,
                      ),
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
      return DashboardUserAvatarWidget(user: user, size: 20, color: color);
    }

    final assetPath = data.assetPath;
    if (assetPath != null) {
      return SvgPicture.asset(
        assetPath,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return Icon(data.icon, color: color, size: 20);
  }
}

class DashboardUserAvatarWidget extends StatelessWidget {
  const DashboardUserAvatarWidget({
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

class DashboardNavItemData {
  const DashboardNavItemData(
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
