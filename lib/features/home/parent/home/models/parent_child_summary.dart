import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/quiz_models.dart';

class ParentChildSummary {
  const ParentChildSummary({
    required this.profile,
    this.classroom,
    this.assessments = const <GeneratedQuiz>[],
  });

  final StudentProfile profile;
  final ClassroomModel? classroom;
  final List<GeneratedQuiz> assessments;
}
