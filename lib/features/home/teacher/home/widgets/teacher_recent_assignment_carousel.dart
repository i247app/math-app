import 'package:flutter/material.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/home/shared/widgets/home_horizontal_carousel.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_recent_assignment_card.dart';

class TeacherRecentAssignmentCarousel extends StatelessWidget {
  const TeacherRecentAssignmentCarousel({
    super.key,
    required this.scale,
    required this.assignments,
    required this.onOpen,
  });

  final double scale;
  final List<ClassroomExercise> assignments;
  final ValueChanged<ClassroomExercise> onOpen;

  @override
  Widget build(BuildContext context) {
    return HomeHorizontalCarousel<ClassroomExercise>(
      items: assignments,
      itemWidth: 178 * scale,
      height: 164 * scale,
      gap: 14 * scale,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, assignment) => TeacherRecentAssignmentCard(
        scale: scale,
        assignment: assignment,
        onTap: () => onOpen(assignment),
      ),
    );
  }
}
