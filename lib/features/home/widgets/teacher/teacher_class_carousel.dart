import 'package:flutter/material.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/shared/widgets/app_horizontal_carousel.dart';
import 'package:numi/features/home/widgets/teacher/teacher_class_card.dart';

class TeacherClassCarousel extends StatelessWidget {
  const TeacherClassCarousel({
    super.key,
    required this.classrooms,
    required this.onOpen,
  });
  final List<ClassroomModel> classrooms;
  final ValueChanged<ClassroomModel> onOpen;

  @override
  Widget build(BuildContext context) {
    return AppHorizontalCarousel<ClassroomModel>(
      items: classrooms,
      itemWidth: 166,
      height: 176,
      gap: 16,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, classroom) => TeacherClassCard(
        classroom: classroom,
        onTap: () => onOpen(classroom),
      ),
    );
  }
}
