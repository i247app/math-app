import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/constants/home_visual_constants.dart';
import 'package:numi/features/home/parent/home/widgets/parent_profile_dialog_action.dart';

class ParentSelectStudentDialog extends StatelessWidget {
  const ParentSelectStudentDialog({super.key});

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
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 155,
                      height: 155,
                      decoration: BoxDecoration(
                        color: colors.brandStrong.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.brandStrong.withValues(alpha: 0.14),
                            blurRadius: 26,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      parentNoStudentMascotAsset,
                      width: 176,
                      height: 162,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  context.getText(AppKeys.parentNoStudentTitle),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: FontSize.xxxl,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.getText(AppKeys.parentSelectStudentMessage),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(ParentProfileDialogAction.choose),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.brandStrong,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.getText(AppKeys.parentSwitchStudentAction),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(ParentProfileDialogAction.create),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.brandStrong,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      context.getText(AppKeys.parentCreateStudent),
                      style: TextStyle(
                        color: colors.brandStrong,
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
