import 'package:flutter_test/flutter_test.dart';

import 'package:numi/features/dashboard/navigation/dashboard_tab_order.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/features/dashboard/controllers/teacher_role_tab_cubit.dart';
import 'package:numi/features/dashboard/controllers/parent_role_tab_cubit.dart';
import 'package:numi/features/dashboard/controllers/student_role_tab_cubit.dart';

void main() {
  test(
    'role changes preserve shared destinations and map equivalent flows',
    () {
      for (final role in ProfileRole.values) {
        for (final tab in [DashboardTabId.home, DashboardTabId.settings]) {
          expect(
            dashboardTabAfterRoleChange(currentTab: tab, toRole: role),
            tab,
          );
        }
      }
      for (final role in [ProfileRole.parent, ProfileRole.student]) {
        expect(
          dashboardTabAfterRoleChange(
            currentTab: DashboardTabId.classroom,
            toRole: role,
          ),
          DashboardTabId.room,
        );
        expect(
          dashboardTabAfterRoleChange(
            currentTab: DashboardTabId.study,
            toRole: role,
          ),
          DashboardTabId.learning,
        );
        expect(
          dashboardTabAfterRoleChange(
            currentTab: DashboardTabId.members,
            toRole: role,
          ),
          DashboardTabId.home,
        );
        for (final tab in supportedDashboardTabs(role)) {
          expect(
            dashboardTabAfterRoleChange(currentTab: tab, toRole: role),
            tab,
          );
        }
      }
      expect(
        dashboardTabAfterRoleChange(
          currentTab: DashboardTabId.room,
          toRole: ProfileRole.teacher,
        ),
        DashboardTabId.classroom,
      );
      expect(
        dashboardTabAfterRoleChange(
          currentTab: DashboardTabId.learning,
          toRole: ProfileRole.teacher,
        ),
        DashboardTabId.study,
      );
      for (final tab in [DashboardTabId.assessment, DashboardTabId.games]) {
        expect(
          dashboardTabAfterRoleChange(
            currentTab: tab,
            toRole: ProfileRole.teacher,
          ),
          DashboardTabId.home,
        );
      }
    },
  );

  group('RoleTabCubit characterization', () {
    test('parent and student can select the Learning tab', () async {
      final parent = ParentRoleTabCubit()..selectTab(DashboardTabId.learning);
      final student = StudentRoleTabCubit()..selectTab(DashboardTabId.learning);

      expect(parent.state.activeTab, DashboardTabId.learning);
      expect(student.state.activeTab, DashboardTabId.learning);

      await parent.close();
      await student.close();
    });
    test('tracks tab selection history and revision', () async {
      final cubit = TeacherRoleTabCubit();

      cubit.selectTab(DashboardTabId.members);

      expect(cubit.state.activeTab, DashboardTabId.members);
      expect(cubit.state.previousTab, DashboardTabId.home);
      expect(cubit.state.selectionRevision, 1);
      await cubit.close();
    });

    test('ignores selections outside the profile role', () async {
      final cubit = TeacherRoleTabCubit();

      cubit.selectTab(DashboardTabId.room);
      cubit.selectTab(DashboardTabId.learning);

      expect(cubit.state.activeTab, DashboardTabId.home);
      expect(cubit.state.selectionRevision, 0);
      await cubit.close();
    });

    test('records a same-tab reentry as a new selection', () async {
      final cubit = TeacherRoleTabCubit();

      cubit.selectTab(DashboardTabId.home);

      expect(cubit.state.activeTab, DashboardTabId.home);
      expect(cubit.state.previousTab, DashboardTabId.home);
      expect(cubit.state.selectionRevision, 1);
      await cubit.close();
    });
  });
}
