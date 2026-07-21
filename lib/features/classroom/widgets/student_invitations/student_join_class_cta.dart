import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class StudentJoinClassCta extends StatelessWidget {
  const StudentJoinClassCta({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFAA2A6C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          spacing: 7,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              studentParentHomeJoinIconAsset,
              width: 20,
              height: 20,
            ),
            Text(
              context.getText(AppKeys.studentJoinClassroomUpper),
              style: const TextStyle(
                color: Colors.white,
                fontSize: FontSize.small,
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
