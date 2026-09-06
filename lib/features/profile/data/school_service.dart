import 'package:numi/features/profile/models/school.dart';

abstract interface class SchoolService {
  Future<List<SchoolModel>> listSchools();
}
