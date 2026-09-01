import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentRoomUtilitiesSection extends StatelessWidget {
  const ParentRoomUtilitiesSection({
    super.key,
    required this.onMessageTap,
    required this.onMembersTap,
    required this.onUtilityTap,
  });

  final VoidCallback onMessageTap;
  final VoidCallback onMembersTap;
  final VoidCallback onUtilityTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text(
          context.getText(AppKeys.parentRoomUtilitiesTitle),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: FontSize.xl,
            fontWeight: FontWeight.w600,
          ),
        ),
        GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          clipBehavior: Clip.none,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 0.86,
          children: [
            _ParentRoomUtilityTile(
              key: const ValueKey('parent-room-utility-message'),
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFF238C8C),
              iconBackground: const Color(0xFFE5F7F5),
              label: context.getText(AppKeys.parentRoomUtilityMessages),
              onTap: onMessageTap,
            ),
            _ParentRoomUtilityTile(
              key: const ValueKey('parent-room-utility-homework'),
              icon: Icons.assignment_outlined,
              iconColor: const Color(0xFF3785B5),
              iconBackground: const Color(0xFFE7F4FB),
              label: context.getText(AppKeys.parentRoomUtilityHomework),
              onTap: onUtilityTap,
            ),
            _ParentRoomUtilityTile(
              key: const ValueKey('parent-room-utility-test'),
              iconAsset: 'assets/icons/exam-icon.svg',
              iconColor: const Color(0xFFF0A72B),
              iconBackground: const Color(0xFFFFF5DE),
              label: context.getText(AppKeys.parentRoomUtilityTests),
              onTap: onUtilityTap,
            ),
            _ParentRoomUtilityTile(
              key: const ValueKey('parent-room-utility-document'),
              iconAsset: 'assets/icons/folder-icon.svg',
              iconColor: const Color(0xFFE9AF16),
              iconBackground: const Color(0xFFFFFAE8),
              label: context.getText(AppKeys.parentRoomUtilityDocuments),
              onTap: onUtilityTap,
            ),
            _ParentRoomUtilityTile(
              key: const ValueKey('parent-room-utility-progress'),
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xFF9A4CAD),
              iconBackground: const Color(0xFFF8ECFA),
              label: context.getText(AppKeys.parentRoomUtilityProgress),
              onTap: onUtilityTap,
            ),
            _ParentRoomUtilityTile(
              key: const ValueKey('parent-room-utility-members'),
              icon: Icons.groups_2_outlined,
              iconColor: const Color(0xFF1E9D91),
              iconBackground: const Color(0xFFE4F7F4),
              label: context.getText(AppKeys.parentRoomUtilityMembers),
              onTap: onMembersTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _ParentRoomUtilityTile extends StatelessWidget {
  const _ParentRoomUtilityTile({
    super.key,
    this.icon,
    this.iconAsset,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.onTap,
  }) : assert(icon != null || iconAsset != null);

  final IconData? icon;
  final String? iconAsset;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(20);

    return Semantics(
      button: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: colors.elevatedSurface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Ink(
              decoration: BoxDecoration(
                color: colors.elevatedSurface,
                borderRadius: radius,
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.45),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: iconAsset == null
                        ? Icon(icon, color: iconColor, size: 25)
                        : Center(
                            child: SvgPicture.asset(
                              iconAsset!,
                              width: 26,
                              height: 24,
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: FontSize.compact,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
