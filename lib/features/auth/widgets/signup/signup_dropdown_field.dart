import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/theme/app_theme_colors.dart';
import 'package:numi_flutter/features/auth/widgets/signup/signup_gender_choice.dart';

class SignupDropdownField extends StatelessWidget {
  const SignupDropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hintText;
  final List<SignupGenderChoice> items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textStyle = GoogleFonts.andika(
      color: colors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );
    final hintStyle = GoogleFonts.andika(
      color: colors.inputHint,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );

    return SizedBox(
      height: 58,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colors.brandStrong,
        ),
        hint: Text(hintText, style: hintStyle),
        disabledHint: Text(hintText, style: hintStyle),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.value,
                child: Text(context.getText(item.labelKey), style: textStyle),
              ),
            )
            .toList(),
        onChanged: onChanged,
        style: textStyle,
        decoration: InputDecoration(
          filled: true,
          fillColor: colors.inputSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.border, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.brandStrong, width: 2),
          ),
        ),
      ),
    );
  }
}
