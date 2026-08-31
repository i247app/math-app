import 'package:numi/features/profile/domain/models/school.dart';

abstract interface class SchoolService {
  Future<List<SchoolModel>> listSchools();
}
