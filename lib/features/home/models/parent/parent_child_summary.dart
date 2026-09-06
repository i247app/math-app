import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/quiz/models/quiz.dart';

class ParentChildSummary {
  const ParentChildSummary({
    required this.profile,
    this.classroom,
    this.classrooms = const <ClassroomModel>[],
    this.assessments = const <GeneratedQuiz>[],
  });

  final StudentProfile profile;
  final ClassroomModel? classroom;
  final List<ClassroomModel> classrooms;
  final List<GeneratedQuiz> assessments;
}
