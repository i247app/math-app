import 'package:flutter/material.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_class_card.dart';

class TeacherClassCarousel extends StatelessWidget {
  const TeacherClassCarousel({
    super.key,
    required this.scale,
    required this.classrooms,
    required this.onOpen,
  });

  final double scale;
  final List<ClassroomModel> classrooms;
  final ValueChanged<ClassroomModel> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176 * scale,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: classrooms.length,
        separatorBuilder: (_, _) => SizedBox(width: 16 * scale),
        itemBuilder: (context, index) {
          final classroom = classrooms[index];
          return SizedBox(
            width: 166 * scale,
            child: TeacherClassCard(
              scale: scale,
              classroom: classroom,
              onTap: () => onOpen(classroom),
            ),
          );
        },
      ),
    );
  }
}
