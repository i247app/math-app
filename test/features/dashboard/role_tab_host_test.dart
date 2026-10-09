import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_factory.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_order.dart';
import 'package:numi/features/dashboard/widgets/layouts/role_tab_host.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/exam/data/exam_service.dart';

void main() {
  testWidgets('swipes follow visible destinations and stop at the edge', (
    tester,
  ) async {
    var activeTab = DashboardTabId.home;
    final selected = <DashboardTabId>[];
    final factory = _TabFactory();
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (_, setState) => RoleTabHost(
            args: _args(activeTab),
            tabFactory: factory,
            activeRole: ProfileRole.parent,
            profileResetSignal: 0,
            onSwipeToTab: (tab) => setState(() {
              activeTab = tab;
              selected.add(tab);
            }),
            onSwipePositionChanged: (_) {},
            onSwipeInteractionEnded: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final next in [
      DashboardTabId.learning,
      DashboardTabId.games,
      DashboardTabId.settings,
    ]) {
      await tester.drag(find.byType(RoleTabHost), const Offset(-350, 0));
      await tester.pumpAndSettle();
      expect(activeTab, next);
      expect(find.text(next.name), findsOneWidget);
    }
    await tester.drag(find.byType(RoleTabHost), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(selected, [
      DashboardTabId.learning,
      DashboardTabId.games,
      DashboardTabId.settings,
    ]);
    expect(factory.tabs, isNot(contains(DashboardTabId.assessment)));
    expect(factory.tabs, isNot(contains(DashboardTabId.room)));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a short slow swipe returns to the current tab', (tester) async {
    var selections = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: RoleTabHost(
          args: _args(DashboardTabId.learning),
          tabFactory: _TabFactory(),
          activeRole: ProfileRole.student,
          profileResetSignal: 0,
          onSwipeToTab: (_) => selections++,
          onSwipePositionChanged: (_) {},
          onSwipeInteractionEnded: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.timedDrag(
      find.byType(RoleTabHost),
      const Offset(-60, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(selections, 0);
    expect(find.text('learning'), findsOneWidget);
    expect(find.text('games'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'switching role during a swipe resets the old transition and cache',
    (tester) async {
      var role = ProfileRole.parent;
      var activeTab = DashboardTabId.learning;
      late StateSetter update;
      final factory = _TabFactory();
      final positions = <double?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, setState) {
              update = setState;
              return RoleTabHost(
                args: _args(activeTab),
                tabFactory: factory,
                activeRole: role,
                profileResetSignal: 0,
                onSwipeToTab: (_) {},
                onSwipePositionChanged: positions.add,
                onSwipeInteractionEnded: () {},
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(RoleTabHost)),
      );
      await gesture.moveBy(const Offset(-90, 0));
      await tester.pump();
      update(() {
        activeTab = dashboardTabAfterRoleChange(
          currentTab: activeTab,
          toRole: ProfileRole.teacher,
        );
        role = ProfileRole.teacher;
      });
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('study'), findsOneWidget);
      expect(find.text('learning'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 1));
      expect(factory.invalidTabs, isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    },
  );
}

class _TabFactory implements DashboardTabFactory {
  final tabs = <DashboardTabId>[];
  final invalidTabs = <DashboardTabId>[];
  @override
  Widget buildTab({
    required BuildContext context,
    required ProfileRole role,
    required DashboardTabArgs args,
  }) {
    tabs.add(args.activeTab);
    if (!supportedDashboardTabs(role).contains(args.activeTab)) {
      invalidTabs.add(args.activeTab);
    }
    return Center(child: Text(args.activeTab.name));
  }
}

DashboardTabArgs _args(DashboardTabId tab) => DashboardTabArgs(
  activeTab: tab,
  isActive: true,
  activeRefreshTick: 0,
  session: const DashboardSessionData(
    user: null,
    profiles: [],
    activeProfile: null,
    profileLoadError: null,
    initialGrades: [],
  ),
  services: const DashboardTabServices(
    gradeService: _UnusedServices(),
    classroomService: _UnusedServices(),
    assignmentService: _UnusedServices(),
    examService: _UnusedServices(),
  ),
  actions: const DashboardTabActions(
    onRefreshProfiles: _asyncNoop,
    onActivateProfile: _activate,
    onLogout: _noop,
    onProfileSaved: _noop,
    onCompleteTeacherProfile: _asyncNoop,
    onOpenClassroomTab: _noop,
    onOpenGamesTab: _noop,
    onOpenExercisesTab: _noop,
    onOpenProfileMenu: _noop,
    onParentAssessmentStateChanged: _assessmentChanged,
    onNotificationTap: _noop,
  ),
  presentation: const DashboardTabPresentation(
    openAddProfileRequestId: 0,
    bottomPadding: 0,
    hasUnreadNotifications: false,
    showChildProfileDialogOnStart: false,
  ),
);
void _noop() {}
Future<void> _asyncNoop() async {}
Future<void> _activate(UserProfile _) async {}
void _assessmentChanged(bool _) {}

class _UnusedServices
    implements
        GradeService,
        ClassroomService,
        ClassroomExerciseService,
        ExamService {
  const _UnusedServices();
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
