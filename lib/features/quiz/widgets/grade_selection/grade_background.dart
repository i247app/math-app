import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class GradeBackground extends StatelessWidget {
  const GradeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.pageBackgroundTop,
            colors.pageBackground,
            colors.pageBackgroundTop,
          ],
          stops: const [0, 0.80, 1],
        ),
      ),
    );
  }
}
