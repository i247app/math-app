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
    required this.onUtilityTap,
  });

  final VoidCallback onMessageTap;
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
              asset: 'assets/icons/message-icon.svg',
              label: context.getText(AppKeys.parentRoomUtilityMessages),
              onTap: onMessageTap,
            ),
            _ParentRoomUtilityTile(
              key: const ValueKey('parent-room-utility-homework'),
              asset: 'assets/icons/homework-icon.svg',
              label: context.getText(AppKeys.parentRoomUtilityHomework),
              onTap: onUtilityTap,
            ),
            _ParentRoomUtilityTile(
              key: const ValueKey('parent-room-utility-test'),
              asset: 'assets/icons/test-icon.svg',
              label: context.getText(AppKeys.parentRoomUtilityTests),
              onTap: onUtilityTap,
            ),
            _ParentRoomUtilityTile(
              key: const ValueKey('parent-room-utility-document'),
              asset: 'assets/icons/document-icon.svg',
              label: context.getText(AppKeys.parentRoomUtilityDocuments),
              onTap: onUtilityTap,
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
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
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
                  SvgPicture.asset(asset, width: 34, height: 34),
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
