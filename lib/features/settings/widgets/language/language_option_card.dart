import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:numi/core/theme/font_size.dart';

class LanguageOptionCard extends StatelessWidget {
  const LanguageOptionCard({
    super.key,
    required this.flag,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.pink : AppColors.borderWarm;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFF2F8)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: selected ? 0.18 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            spacing: 16,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFE4F1)
                      : const Color(0xFFEFF7F8),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: FontSize.xxxl, height: 1),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected ? AppColors.pink : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pink, width: 2.4),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
