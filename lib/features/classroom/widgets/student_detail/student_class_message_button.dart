import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentClassMessageButton extends StatelessWidget {
  const StudentClassMessageButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD9E2FF).withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SvgPicture.asset(
              'assets/images/student_class_message.svg',
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }
}
