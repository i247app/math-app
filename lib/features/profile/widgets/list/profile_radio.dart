import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class ProfileRadio extends StatelessWidget {
  const ProfileRadio({
    super.key,
    required this.isActive,
    this.isLoading = false,
  });

  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const size = 28.0;
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return SizedBox.square(
        dimension: size,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: CircularProgressIndicator(
            color: isDark ? colors.brandStrong : AppColors.tealIcon,
            strokeWidth: 2.6,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? colors.brandStrong : AppColors.tealIcon)
            : (isDark ? colors.surface : Colors.white),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? colors.brandStrong : Colors.black,
          width: 3,
        ),
      ),
    );
  }
}
