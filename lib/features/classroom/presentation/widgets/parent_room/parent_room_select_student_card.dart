import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class ParentRoomSelectStudentCard extends StatelessWidget {
  const ParentRoomSelectStudentCard({
    super.key,
    required this.onChooseProfile,
    required this.onCreateProfile,
  });

  final VoidCallback onChooseProfile;
  final VoidCallback onCreateProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      key: const ValueKey('room-select-student'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 38, 28, 28),
      color: colors.elevatedSurface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            parentNoStudentMascotAsset,
            width: 220,
            height: 210,
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
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              context.getText(AppKeys.parentSelectStudentMessage),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: FontSize.normal,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 228),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: onChooseProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: colors.accent.withValues(alpha: 0.32),
                  ),
                  child: Text(
                    context.getText(AppKeys.parentSwitchStudentAction),
                    style: TextStyle(
                      color: colors.onAccent,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 228),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: onCreateProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.brandStrong,
                    side: BorderSide(color: colors.brandStrong),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
            ),
          ),
        ],
      ),
    );
  }
}
