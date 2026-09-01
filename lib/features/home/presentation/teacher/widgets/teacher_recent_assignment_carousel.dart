import 'package:flutter/material.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/shared/widgets/app_horizontal_carousel.dart';
import 'package:numi/features/home/presentation/teacher/widgets/teacher_recent_assignment_card.dart';

class TeacherRecentAssignmentCarousel extends StatelessWidget {
  const TeacherRecentAssignmentCarousel({
    super.key,
    required this.assignments,
    required this.onOpen,
  });
  final List<ClassroomExercise> assignments;
  final ValueChanged<ClassroomExercise> onOpen;

  @override
  Widget build(BuildContext context) {
    return AppHorizontalCarousel<ClassroomExercise>(
      items: assignments,
      itemWidth: 178,
      height: 164,
      gap: 14,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, assignment) => TeacherRecentAssignmentCard(
        assignment: assignment,
        onTap: () => onOpen(assignment),
      ),
    );
  }
}
