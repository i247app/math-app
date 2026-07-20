import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_coral_create_button.dart';

class TeacherNoClassPanel extends StatelessWidget {
  const TeacherNoClassPanel({
    super.key,
    required this.isProfileComplete,
    required this.onCreate,
  });
  final bool isProfileComplete;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 383,
      decoration: const BoxDecoration(color: Color(0xFF308B8D)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 22,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Image.asset(
                'assets/images/numi-mascot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          TeacherCoralCreateButton(
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
