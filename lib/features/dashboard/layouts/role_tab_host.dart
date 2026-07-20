import 'package:flutter/material.dart';

import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/dashboard/navigation/parent_tab_host.dart';
import 'package:numi/features/dashboard/navigation/student_tab_host.dart';
import 'package:numi/features/dashboard/navigation/teacher_tab_host.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';

class RoleTabHost extends StatefulWidget {
  const RoleTabHost({
    super.key,
    required this.activeTab,
    required this.selectionRevision,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.activeRole,
    required this.profileLoadError,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.initialGrades,
    required this.gradeService,
    required this.classroomService,
    required this.assignmentService,
    required this.quizService,
    required this.onLogout,
    required this.onAddProfileFromPractice,
    required this.onProfileSaved,
    required this.openAddProfileRequestId,
    required this.onCompleteTeacherProfile,
    required this.onOpenClassroomTab,
    required this.onOpenPracticeTab,
    required this.onOpenHistoryTab,
    required this.onOpenProfileMenu,
    required this.onParentAssessmentStateChanged,
    required this.parentHomeEntrance,
    required this.profileResetSignal,
    required this.bottomPadding,
    this.homeHeader,
  });

  final int activeTab;
  final int selectionRevision;
  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final ProfileRole activeRole;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final ClassroomService classroomService;
  final ClassroomExerciseService assignmentService;
  final QuizService quizService;
  final VoidCallback onLogout;
  final VoidCallback onAddProfileFromPractice;
  final VoidCallback onProfileSaved;
  final int openAddProfileRequestId;
  final Future<void> Function() onCompleteTeacherProfile;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenPracticeTab;
  final VoidCallback onOpenHistoryTab;
  final VoidCallback onOpenProfileMenu;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final Animation<double> parentHomeEntrance;
  final int profileResetSignal;
  final double bottomPadding;
  final Widget? homeHeader;

  @override
  State<RoleTabHost> createState() => RoleTabHostState();
}

class RoleTabHostState extends State<RoleTabHost> {
  late final Set<int> _visitedTabs = <int>{widget.activeTab};
  final Map<int, int> _activationTicks = <int, int>{};
  final Map<int, Widget> _tabChildren = <int, Widget>{};
  late int _lastProfileResetSignal = widget.profileResetSignal;

  @override
  void initState() {
    super.initState();
    _activationTicks[widget.activeTab] = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) => _prewarmTabs());
  }

  Future<void> _prewarmTabs() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    const tabOrder = <int>[1, 2, 3, 4, 0];
    for (final tab in tabOrder) {
      if (!mounted) {
        return;
      }
      if (tab == widget.activeTab || _visitedTabs.contains(tab)) {
        continue;
      }

      setState(() {
        _visitedTabs.add(tab);
        _activationTicks[tab] = 0;
      });
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void didUpdateWidget(covariant RoleTabHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTab != widget.activeTab) {
      _visitedTabs.add(widget.activeTab);
      // Only the outgoing and incoming tabs need new [isActive] args. Keeping
      // the other widget instances identical lets Flutter skip their build
      // work while the Offstage wrappers change selection.
      _tabChildren.remove(oldWidget.activeTab);
      _tabChildren.remove(widget.activeTab);
    }

    if (widget.profileResetSignal != _lastProfileResetSignal) {
      _lastProfileResetSignal = widget.profileResetSignal;
      for (final tab in _activationTicks.keys.toList()) {
        _activationTicks[tab] = (_activationTicks[tab] ?? 0) + 1;
      }
      _tabChildren.clear();
      return;
    }

    if (_requiresAllTabsRebuild(oldWidget, widget)) {
      _tabChildren.clear();
    } else if (oldWidget.homeHeader != widget.homeHeader) {
      // The header only belongs to the Home tab and can change when the
      // profile menu opens or closes.
      _tabChildren.remove(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxTabIndex = 4;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var tab = 0; tab <= maxTabIndex; tab++)
          if (_visitedTabs.contains(tab))
            Offstage(
              key: ValueKey('home-tab-$tab'),
              offstage: tab != widget.activeTab,
              child: TickerMode(
                enabled: tab == widget.activeTab,
                child: KeyedSubtree(
                  key: ValueKey('home-dashboard-content-$tab'),
                  child: _tabChildren.putIfAbsent(
                    tab,
                    () => _buildTab(context, tab),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, int tab) {
    final args = DashboardTabArgs(
      activeTab: tab,
      isActive: tab == widget.activeTab,
      user: widget.user,
      profiles: widget.profiles,
      activeProfile: widget.activeProfile,
      profileLoadError: widget.profileLoadError,
      onRefreshProfiles: widget.onRefreshProfiles,
      onActivateProfile: widget.onActivateProfile,
      initialGrades: widget.initialGrades,
      gradeService: widget.gradeService,
      classroomService: widget.classroomService,
      assignmentService: widget.assignmentService,
      quizService: widget.quizService,
      onLogout: widget.onLogout,
      onAddProfileFromPractice: widget.onAddProfileFromPractice,
      onProfileSaved: widget.onProfileSaved,
      openAddProfileRequestId: widget.openAddProfileRequestId,
      onCompleteTeacherProfile: widget.onCompleteTeacherProfile,
      onOpenClassroomTab: widget.onOpenClassroomTab,
      onOpenPracticeTab: widget.onOpenPracticeTab,
      onOpenHistoryTab: widget.onOpenHistoryTab,
      onOpenProfileMenu: widget.onOpenProfileMenu,
      onParentAssessmentStateChanged: widget.onParentAssessmentStateChanged,
      parentHomeEntrance: widget.parentHomeEntrance,
      activeRefreshTick: _activationTicks[tab] ?? 0,
      bottomPadding: widget.bottomPadding,
      homeHeader: tab == 0 ? widget.homeHeader : null,
    );

    return switch (widget.activeRole) {
      ProfileRole.parent => ParentTabHost(args: args),
      ProfileRole.student => StudentTabHost(args: args),
      ProfileRole.teacher => TeacherTabHost(args: args),
    };
  }

  static bool _requiresAllTabsRebuild(
    RoleTabHost previous,
    RoleTabHost current,
  ) {
    return previous.activeRole != current.activeRole ||
        previous.user != current.user ||
        previous.profiles != current.profiles ||
        previous.activeProfile != current.activeProfile ||
        previous.profileLoadError != current.profileLoadError ||
        previous.initialGrades != current.initialGrades ||
        previous.bottomPadding != current.bottomPadding;
  }
}
