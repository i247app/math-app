import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_coral_create_button.dart';

class TeacherNoClassPanel extends StatelessWidget {
  const TeacherNoClassPanel({
    super.key,
    required this.scale,
    required this.isProfileComplete,
    required this.onCreate,
  });

  final double scale;
  final bool isProfileComplete;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 383 * scale,
      decoration: const BoxDecoration(color: Color(0xFF308B8D)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 220 * scale,
            height: 220 * scale,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38 * scale),
            ),
            child: Padding(
              padding: EdgeInsets.all(28 * scale),
              child: Image.asset(
                'assets/images/numi-mascot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 22 * scale),
          TeacherCoralCreateButton(
            scale: scale,
            label: context.getText(
              isProfileComplete
                  ? AppKeys.teacherCreateNewClass
                  : AppKeys.teacherCompleteProfile,
            ),
            onTap: onCreate,
          ),
        ],
      ),
    );
  }
}
