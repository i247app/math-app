import 'package:flutter/material.dart';

import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/features/home/teacher/shared/widgets/class_default_image.dart';

class ClassThumb extends StatelessWidget {
  const ClassThumb({super.key, required this.classroom, required this.scale});

  final ClassroomModel classroom;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        classroom.imageUrl ?? classroom.avatarUrl ?? classroom.fileUrl;
    return Container(
      width: 84 * scale,
      height: 60 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl?.trim().isNotEmpty == true
          ? Image.network(
              imageUrl!.trim(),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ClassDefaultImage(scale: scale),
            )
          : ClassDefaultImage(scale: scale),
    );
  }
}
