import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_filter.dart';

class HistoryTypeTabButton extends StatelessWidget {
  const HistoryTypeTabButton({
    super.key,
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final HistoryFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.coralTab : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            context.getText(filter.labelKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textWarmMuted,
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
