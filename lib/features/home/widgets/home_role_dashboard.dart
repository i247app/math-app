part of '../home_screen.dart';

class HomeRoleDashboard extends StatefulWidget {
  const HomeRoleDashboard({
    super.key,
    required this.activeTab,
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
    required this.onAddProfileFromReview,
    required this.onProfileSaved,
    required this.openAddProfileRequestId,
    required this.onCompleteTeacherProfile,
    required this.onOpenClassroomTab,
    required this.onOpenReviewTab,
    required this.onOpenProfileMenu,
    required this.onParentAssessmentStateChanged,
    required this.parentHomeEntrance,
    required this.bottomPadding,
    required this.headerHeight,
    required this.scale,
  });

  final int activeTab;
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
  final VoidCallback onAddProfileFromReview;
  final VoidCallback onProfileSaved;
  final int openAddProfileRequestId;
  final Future<void> Function() onCompleteTeacherProfile;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenReviewTab;
  final VoidCallback onOpenProfileMenu;
  final ValueChanged<bool> onParentAssessmentStateChanged;
  final Animation<double> parentHomeEntrance;
  final double bottomPadding;
  final double headerHeight;
  final double scale;

  @override
  State<HomeRoleDashboard> createState() => HomeRoleDashboardState();
}

class HomeRoleDashboardState extends State<HomeRoleDashboard> {
  late final Set<int> _visitedTabs = <int>{widget.activeTab};
  late final Set<int> _activatedTabs = <int>{widget.activeTab};
  final Map<int, int> _activationTicks = <int, int>{};

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
        _activationTicks[tab] = 1;
      });
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void didUpdateWidget(covariant HomeRoleDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTab != widget.activeTab) {
      _visitedTabs.add(widget.activeTab);
      final isFirstActivation = _activatedTabs.add(widget.activeTab);
      if (isFirstActivation) {
        _activationTicks[widget.activeTab] ??= 1;
      } else {
        _activationTicks[widget.activeTab] =
            (_activationTicks[widget.activeTab] ?? 0) + 1;
      }
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
                child: _buildTab(context, tab),
              ),
            ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, int tab) {
    final args = HomeDashboardArgs(
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
      onAddProfileFromReview: widget.onAddProfileFromReview,
      onProfileSaved: widget.onProfileSaved,
      openAddProfileRequestId: widget.openAddProfileRequestId,
      onCompleteTeacherProfile: widget.onCompleteTeacherProfile,
      onOpenClassroomTab: widget.onOpenClassroomTab,
      onOpenReviewTab: widget.onOpenReviewTab,
      onOpenProfileMenu: widget.onOpenProfileMenu,
      onParentAssessmentStateChanged: widget.onParentAssessmentStateChanged,
      parentHomeEntrance: widget.parentHomeEntrance,
      activeRefreshTick: _activationTicks[tab] ?? 0,
      bottomPadding: widget.bottomPadding,
      headerHeight: tab == 0 ? widget.headerHeight : 0,
      scale: widget.scale,
    );

    return switch (widget.activeRole) {
      ProfileRole.parent => ParentDashboard(args: args),
      ProfileRole.student => StudentDashboard(args: args),
      ProfileRole.teacher => TeacherDashboard(args: args),
    };
  }
}
