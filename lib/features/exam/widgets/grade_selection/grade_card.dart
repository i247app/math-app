import 'package:flutter/material.dart';

import 'package:numi/features/exam/widgets/grade_selection/grade_option.dart';
import 'package:numi/core/theme/app_colors.dart';

class GradeCard extends StatelessWidget {
  const GradeCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });

  final GradeOption option;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final iconAsset = option.iconAsset;

    return Semantics(
      key: ValueKey('grade-card-$iconAsset'),
      label: option.label,
      selected: isSelected,
      button: true,
      enabled: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.orange600 : Colors.transparent,
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.orange600.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: isSelected ? 14 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: iconAsset == null
                ? Center(
                    child: Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : Center(
                    key: ValueKey('grade-icon-$iconAsset'),
                    child: Image.asset(
                      iconAsset,
                      key: ValueKey('grade-icon-image-$iconAsset'),
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      cacheWidth: 360,
                      filterQuality: FilterQuality.high,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) =>
                          _GradeIconFallback(
                            key: ValueKey('grade-icon-fallback-$iconAsset'),
                            label: option.label,
                          ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (option.isKindergarten) {
      return const Color(0xFFFFEAF1);
    }

    return switch (option.number) {
      '1' => const Color(0xFFEEF9DD),
      '2' => const Color(0xFFFFF1D5),
      '3' => const Color(0xFFDDF6F2),
      '4' => const Color(0xFFDDF3F8),
      '5' => const Color(0xFFFBEAF8),
      _ => Colors.white,
    };
  }
}

class _GradeIconFallback extends StatelessWidget {
  const _GradeIconFallback({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
