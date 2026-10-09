import 'package:numi/features/dashboard/controllers/role_tab_cubit.dart';
import 'package:numi/features/profile/models/profile_role.dart';

class StudentRoleTabCubit extends RoleTabCubit {
  StudentRoleTabCubit() : super(role: ProfileRole.student);
}
