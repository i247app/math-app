import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/features/settings/settings_style.dart';

class LanguageBackButton extends StatelessWidget {
  const LanguageBackButton({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 44 * scale;

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).maybePop();
        },
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: settingsLanguageNavy,
            size: 26 * scale,
          ),
        ),
      ),
    );
  }
}
