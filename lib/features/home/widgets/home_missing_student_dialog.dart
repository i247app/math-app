import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class HomeMissingStudentDialog extends StatelessWidget {
  const HomeMissingStudentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: 303,
            padding: const EdgeInsets.fromLTRB(25, 28, 25, 22),
            decoration: BoxDecoration(
              color: colors.elevatedSurface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: colors.border.withValues(alpha: 0.7)),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.58),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    parentNoStudentMascotAsset,
                    width: 220,
                    height: 194,
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      context.getText(AppKeys.parentNoStudentTitle),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: FontSize.xxxl,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      context.getText(AppKeys.parentNoStudentMessage),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: FontSize.normal,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.accent,
                          foregroundColor: colors.onAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.getText(AppKeys.parentCreateStudentNow),
                          style: TextStyle(
                            color: colors.onAccent,
                            fontSize: FontSize.large,
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.brandStrong,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          context.getText(AppKeys.parentCreateStudentLater),
                          style: TextStyle(
                            color: colors.brandStrong,
                            fontSize: FontSize.large,
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
