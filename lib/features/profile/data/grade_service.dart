import 'package:numi/features/profile/models/grade.dart';

abstract interface class GradeService {
  Future<List<GradeModel>> listGrades({required int userId});
}
