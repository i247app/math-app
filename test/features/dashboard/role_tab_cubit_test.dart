import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/dashboard/controllers/role_tab_cubit.dart';
import 'package:numi/features/dashboard/controllers/parent_role_tab_cubit.dart';
import 'package:numi/features/dashboard/controllers/student_role_tab_cubit.dart';

void main() {
  group('RoleTabCubit characterization', () {
    test('parent and student can select the Learning tab', () async {
      final parent = ParentRoleTabCubit()..selectTab(5);
      final student = StudentRoleTabCubit()..selectTab(5);

      expect(parent.state.activeTab, 5);
      expect(student.state.activeTab, 5);

      await parent.close();
      await student.close();
    });
    test('tracks tab selection history and revision', () async {
      final cubit = _TestRoleTabCubit();

      cubit.selectTab(3);

      expect(cubit.state.activeTab, 3);
      expect(cubit.state.previousTab, 0);
      expect(cubit.state.selectionRevision, 1);
      await cubit.close();
    });

    test('ignores selections outside the configured tab range', () async {
      final cubit = _TestRoleTabCubit();

      cubit.selectTab(-1);
      cubit.selectTab(5);

      expect(cubit.state.activeTab, 0);
      expect(cubit.state.selectionRevision, 0);
      await cubit.close();
    });

    test('records a same-tab reentry as a new selection', () async {
      final cubit = _TestRoleTabCubit();

      cubit.selectTab(0);

      expect(cubit.state.activeTab, 0);
      expect(cubit.state.previousTab, 0);
      expect(cubit.state.selectionRevision, 1);
      await cubit.close();
    });
  });
}

class _TestRoleTabCubit extends RoleTabCubit {
  _TestRoleTabCubit() : super(maxTabIndex: 4);
}
