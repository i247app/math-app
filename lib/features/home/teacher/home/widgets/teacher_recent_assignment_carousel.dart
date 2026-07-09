import 'package:flutter/material.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
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
    return SizedBox(
      height: 164 * scale,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: assignments.length,
        separatorBuilder: (_, _) => SizedBox(width: 14 * scale),
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return SizedBox(
            width: 178 * scale,
            child: TeacherRecentAssignmentCard(
              scale: scale,
              assignment: assignment,
              onTap: () => onOpen(assignment),
            ),
          );
        },
      ),
    );
  }
}
