import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

class CreateClassroomExerciseSubmitButton extends StatelessWidget {
  const CreateClassroomExerciseSubmitButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal520,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  Text(
                    context.getText(AppKeys.teacherCreate).toUpperCase(),
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w700,
                      height: 16 / 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/teacher-homework-create-arrow.svg',
                    width: 14,
                    height: 14,
                  ),
                ],
              ),
      ),
    );
  }
}
