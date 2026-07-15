import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class DashboardBackground extends StatelessWidget {
  const DashboardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.pageBackground,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 44,
            offset: const Offset(0, 28),
          ),
        ],
      ),
    );
  }
}
