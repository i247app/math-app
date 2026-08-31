import 'package:numi/features/profile/data/dto/grade_models.dart';

abstract interface class GradeService {
  Future<List<GradeModel>> listGrades({required int userId});
}
