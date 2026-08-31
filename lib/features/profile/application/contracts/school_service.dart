import 'package:numi/features/profile/data/dto/school_models.dart';

abstract interface class SchoolService {
  Future<List<SchoolModel>> listSchools();
}
