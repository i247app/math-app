import 'package:flutter/material.dart';

import 'package:numi_flutter/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_teacher_avatar_initial.dart';

class StudentClassTeacherAvatar extends StatelessWidget {
  const StudentClassTeacherAvatar({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final initial = studentClassTeacherInitial(name);
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFAA2A6C).withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl == null
            ? StudentClassTeacherAvatarInitial(initial: initial)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    StudentClassTeacherAvatarInitial(initial: initial),
              ),
      ),
    );
  }
}
