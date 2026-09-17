import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/settings/widgets/account/account_field_shell.dart';
import 'package:numi/features/settings/widgets/account/plain_account_text_field.dart';

class AccountPhoneField extends StatelessWidget {
  const AccountPhoneField({
    super.key,
    required this.label,
    required this.controller,
    required this.isEditing,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return AccountFieldShell(
      label: label,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 28,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.vietnamRed,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFE14D),
                size: 13,
              ),
            ),
          ),
          Text(
            '+84',
            style: GoogleFonts.andika(
              color: AppColors.textPrimary,
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          Container(
            width: 1,
            height: 35,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            color: const Color(0xFFDCE5E3),
          ),
          Expanded(
            child: PlainAccountTextField(
              controller: controller,
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              hintText: hintText,
              textStyle: GoogleFonts.andika(
                color: Colors.black,
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
