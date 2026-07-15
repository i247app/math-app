import 'package:flutter/material.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/home/widgets/home_horizontal_carousel.dart';
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
    return HomeHorizontalCarousel<ClassroomModel>(
      items: classrooms,
      itemWidth: 166 * scale,
      height: 176 * scale,
      gap: 16 * scale,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, classroom) => TeacherClassCard(
        scale: scale,
        classroom: classroom,
        onTap: () => onOpen(classroom),
      ),
    );
  }
}
