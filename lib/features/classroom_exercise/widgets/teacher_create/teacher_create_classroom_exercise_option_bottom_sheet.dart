import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/widgets/option_bottom_sheet_shell.dart';

class CreateClassroomExerciseOptionBottomSheet<T> extends StatelessWidget {
  const CreateClassroomExerciseOptionBottomSheet({
    super.key,
    required this.options,
    required this.titleKey,
    required this.isSelected,
    required this.titleBuilder,
    this.subtitleBuilder,
  });

  final List<T> options;
  final String titleKey;
  final bool Function(T option) isSelected;
  final String Function(BuildContext context, T option) titleBuilder;
  final String Function(BuildContext context, T option)? subtitleBuilder;

  @override
  Widget build(BuildContext context) {
    return OptionBottomSheetShell(
      children: [
        Text(
          context.getText(titleKey),
          style: GoogleFonts.andika(
            color: AppColors.teal520,
            fontSize: FontSize.xxl,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        OptionBottomSheetList(
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final selected = isSelected(option);
            final subtitle = subtitleBuilder?.call(context, option);
            return Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  titleBuilder(context, option),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: AppColors.textInkDark,
                    fontSize: FontSize.normal,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                subtitle: subtitle == null
                    ? null
                    : Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: AppColors.textCoolMuted,
                          fontSize: FontSize.xxs,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                trailing: selected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.teal520,
                        size: 22,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
            );
          },
        ),
      ],
    );
  }
}
