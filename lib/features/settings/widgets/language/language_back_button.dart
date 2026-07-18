import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LanguageBackButton extends StatelessWidget {
  const LanguageBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          HapticFeedback.selectionClick();
          Navigator.of(context).maybePop();
        },
        borderRadius: BorderRadius.circular(22),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.navy,
            size: 26,
          ),
        ),
      ),
    );
  }
}
