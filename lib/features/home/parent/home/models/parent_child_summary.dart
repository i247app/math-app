import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';

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
