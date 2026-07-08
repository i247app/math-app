import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          FocusManager.instance.primaryFocus?.unfocus();
          HapticFeedback.selectionClick();
          Navigator.of(context).maybePop();
        },
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.navy,
            size: 26 * scale,
          ),
        ),
      ),
    );
  }
}
