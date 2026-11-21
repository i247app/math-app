import 'package:material_ui/material_ui.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class GradeBackground extends StatelessWidget {
  const GradeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return ColoredBox(color: colors.pageBackground);
  }
}
