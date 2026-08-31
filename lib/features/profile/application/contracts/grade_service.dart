import 'package:numi/features/profile/domain/models/grade.dart';

abstract interface class GradeService {
  Future<List<GradeModel>> listGrades({required int userId});
}
