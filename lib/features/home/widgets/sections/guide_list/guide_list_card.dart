import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_shadows.dart';
import 'package:numi/features/home/widgets/sections/guide_list/guide_item_data.dart';
import 'package:numi/features/home/widgets/sections/guide_list/guide_list_item.dart';

class GuideListCard extends StatelessWidget {
  const GuideListCard({
    super.key,
    required this.items,
    required this.onItemTap,
    this.spacing = 10,
    this.useCardShadow = false,
  });

  final List<GuideItemData> items;
  final ValueChanged<String> onItemTap;
  final double spacing;
  final bool useCardShadow;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.border),
        boxShadow: useCardShadow
            ? AppShadows.card(colors)
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        spacing: spacing,
        children: [
          for (final item in items)
            GuideListItem(data: item, onTap: () => onItemTap(item.id)),
        ],
      ),
    );
  }
}
