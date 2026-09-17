import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/exam/models/exam.dart';

class ParentChildSummary {
  const ParentChildSummary({
    required this.profile,
    this.classroom,
    this.classrooms = const <ClassroomModel>[],
    this.assessments = const <GeneratedExam>[],
  });

  final StudentProfile profile;
  final ClassroomModel? classroom;
  final List<ClassroomModel> classrooms;
  final List<GeneratedExam> assessments;
}
