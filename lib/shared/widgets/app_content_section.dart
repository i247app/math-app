import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';

class AppContentSection extends StatelessWidget {
  const AppContentSection({
    super.key,
    required this.title,
    required this.child,
    this.onViewAll,
  });

  final String title;
  final Widget child;
  final VoidCallback? onViewAll;

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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontSize: FontSize.xl,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onViewAll != null)
                TextButton.icon(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.info,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  label: Text(
                    context.getText(AppKeys.viewAll),
                    style: context.textStyles.labelMedium?.copyWith(
                      fontSize: FontSize.caption,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  icon: const Icon(Icons.chevron_right_rounded, size: 18),
                  iconAlignment: IconAlignment.end,
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
