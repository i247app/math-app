import 'package:numi/features/dashboard/controllers/role_tab_cubit.dart';
import 'package:numi/features/profile/models/profile_role.dart';

class TeacherRoleTabCubit extends RoleTabCubit {
  TeacherRoleTabCubit() : super(role: ProfileRole.teacher);
}
