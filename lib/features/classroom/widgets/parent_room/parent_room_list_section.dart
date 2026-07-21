import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentRoomListSection extends StatelessWidget {
  const ParentRoomListSection({
    super.key,
    required this.title,
    required this.child,
    required this.onViewAll,
  });

  final String title;
  final Widget child;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.brandStrong,
                          fontSize: FontSize.large,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: colors.brandStrong,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                label: Text(
                  context.getText(AppKeys.viewAll),
                  style: const TextStyle(
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                icon: const Icon(Icons.chevron_right_rounded, size: 18),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.only(top: 10), child: child),
        ],
      ),
    );
  }
}
