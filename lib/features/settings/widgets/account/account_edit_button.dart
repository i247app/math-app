import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class AccountEditButton extends StatelessWidget {
  const AccountEditButton({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      ignoring: !enabled,
      child: Material(
        color: isDark ? colors.elevatedSurface : const Color(0xFFF7FBFD),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? colors.brandStrong : AppColors.tealIcon,
                width: 1.2,
              ),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: isDark ? colors.brandStrong : AppColors.tealIcon,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}
