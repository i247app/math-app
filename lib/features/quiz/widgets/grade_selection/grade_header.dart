import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class GradeHeader extends StatelessWidget {
  const GradeHeader({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 70 * scale,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          color: colors.elevatedSurface.withValues(alpha: 0.78),
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              HapticFeedback.selectionClick();
              Navigator.of(context).maybePop();
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: colors.brandStrong,
              size: 28 * scale,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: 42 * scale,
              height: 42 * scale,
            ),
            tooltip: context.getText(AppKeys.back),
          ),
        ),
      ),
    );
  }
}
