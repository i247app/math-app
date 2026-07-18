import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';

class HistoryIncompleteBadge extends StatelessWidget {
  const HistoryIncompleteBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Text(
        context.getText(AppKeys.incomplete),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.orangeMuted,
          fontSize: FontSize.caption * 0.77,
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
