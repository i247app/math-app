import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
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
    final textStyle = GoogleFonts.andika(
      color: AppColors.ink,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );
    final hintStyle = GoogleFonts.andika(
      color: const Color(0xFF7E9088),
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );

    return SizedBox(
      height: 58,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF339395),
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
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE7E7E7), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE7E7E7), width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE7E7E7), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF339395), width: 2),
          ),
        ),
      ),
    );
  }
}
