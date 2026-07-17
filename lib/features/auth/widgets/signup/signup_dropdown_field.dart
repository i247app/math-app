import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/models/signup_gender.dart';
import 'package:numi/features/auth/widgets/signup/signup_gender_choice.dart';

class SignupDropdownField extends StatelessWidget {
  const SignupDropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  final SignupGender? value;
  final String hintText;
  final List<SignupGenderChoice> items;
  final ValueChanged<SignupGender?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: colors.textPrimary,
      fontSize: FontSize.normal,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );
    final hintStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: colors.inputHint,
      fontSize: FontSize.normal,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );

    return SizedBox(
      height: 58,
      child: DropdownButtonFormField<SignupGender>(
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
              (item) => DropdownMenuItem<SignupGender>(
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
