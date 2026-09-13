import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentAssessmentActiveCard extends StatelessWidget {
  const ParentAssessmentActiveCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(20);

    return Material(
      key: const ValueKey('parent-assessment-active-card'),
      color: colors.warningSurface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: colors.warningSurface,
            borderRadius: radius,
            border: Border.all(
              color: colors.accentStrong.withValues(alpha: 0.36),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.accentStrong.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 92,
                child: Image.asset(
                  'assets/images/assessment-active-mascot.png',
                  fit: BoxFit.contain,
                  cacheWidth: 240,
                  cacheHeight: 240,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.accentStrong.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 13,
                              color: colors.accentStrong,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                context.getText(
                                  AppKeys.parentAssessmentActiveBadge,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.accentStrong,
                                  fontSize: FontSize.xxs,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.getText(AppKeys.parentAssessmentActiveTitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: FontSize.compact,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.getText(AppKeys.parentAssessmentActiveSubtitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: FontSize.xxs,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 34,
                        child: FilledButton(
                          key: const ValueKey(
                            'parent-assessment-active-continue',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.accentStrong,
                            foregroundColor: colors.onAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: onTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.getText(
                                  AppKeys.parentAssessmentContinue,
                                ),
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: FontSize.xxs,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 23,
                color: colors.accentStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
