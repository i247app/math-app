import 'package:flutter/material.dart';

import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/home/widgets/teacher/shared/class_default_image.dart';

class ClassThumb extends StatelessWidget {
  const ClassThumb({super.key, required this.classroom});

  final ClassroomModel classroom;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        classroom.imageUrl ?? classroom.avatarUrl ?? classroom.fileUrl;
    return Container(
      width: 84,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl?.trim().isNotEmpty == true
          ? Image.network(
              imageUrl!.trim(),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ClassDefaultImage(),
            )
          : const ClassDefaultImage(),
    );
  }
}
