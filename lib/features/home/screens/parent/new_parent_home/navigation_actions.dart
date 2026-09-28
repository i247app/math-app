part of '../new_parent_home_tab.dart';

extension ParentHomeNavigationActions on NewParentHomeContentState {
  Future<void> openGradeRoadmap() async {
    final profileId = profileStableId(widget.activeProfile);
    if (isOpeningGradeRoadmap || profileId == null || profileId <= 0) {
      return;
    }

    isOpeningGradeRoadmap = true;
    HapticFeedback.lightImpact();
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => GradeRoadmapScreen(
            profileId: profileId,
            examService: widget.examService,
            user: widget.user,
            initialGrades: widget.initialGrades,
            gradeService: widget.gradeService,
          ),
        ),
      );
      if (mounted) {
        await loadHome(forceRefresh: true);
      }
    } finally {
      isOpeningGradeRoadmap = false;
    }
  }

  Future<void> openAssessment() async {
    HapticFeedback.lightImpact();
    await widget.onOpenAssessment?.call(context);
    if (mounted) {
      await loadHome();
    }
  }

  Future<void> openInitialAssessment() async {
    if (isOpeningInitialAssessment) return;
    isOpeningInitialAssessment = true;
    HapticFeedback.lightImpact();
    try {
      await (widget.onOpenInitialAssessment ?? widget.onOpenAssessment)?.call(
        context,
      );
      if (mounted) {
        await loadHome();
      }
    } finally {
      isOpeningInitialAssessment = false;
    }
  }

  Future<void> openActiveAssessment() async {
    final exam = activeAssessment;
    final profileId = profileStableId(widget.activeProfile);
    if (isOpeningActiveAssessment ||
        exam == null ||
        exam.questions.isEmpty ||
        profileId == null ||
        profileId <= 0) {
      return;
    }

    HapticFeedback.selectionClick();
    _updateState(() => isOpeningActiveAssessment = true);
    final homeRoute = ModalRoute.of(context);
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ExamAttemptScreen(
            examService: widget.examService,
            initialExam: exam,
            examType: exam.examType ?? examTypeAssessment,
            gradeLabel: AssessmentFlowPolicy.gradeLabel(exam.grade ?? 0),
            profileId: profileId,
            allowQuestionNavigation: false,
            showQuestionNavigation: false,
            isResumedAssessment: true,
            onResultBack: () {
              if (!mounted) return;
              final navigator = Navigator.of(context);
              if (homeRoute == null) {
                navigator.popUntil((route) => route.isFirst);
              } else {
                navigator.popUntil((route) => identical(route, homeRoute));
              }
            },
          ),
        ),
      );
      if (mounted) {
        await loadHome(forceRefresh: true);
      }
    } finally {
      if (mounted) {
        _updateState(() => isOpeningActiveAssessment = false);
      }
    }
  }

  void openParentAssessmentResult(GeneratedExam exam) {
    _openExamReview(exam);
  }

  void openCompletionResult(HomeLayoutRecentCompletion completion) {
    _openExamReview(examFromRecentCompletion(completion));
  }

  void _openExamReview(GeneratedExam exam) {
    final examId =
        exam.userExamId ?? exam.examId ?? exam.userAiExamId ?? exam.id;
    if (examId == null || examId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    widget.onOpenExamReview?.call(context, exam);
  }

  Future<void> showClassroomMessage() async {
    HapticFeedback.selectionClick();
    if (widget.useActiveStudentProfileData) {
      widget.onOpenClassroomTab();
      return;
    }

    if (_children.isEmpty) {
      await _showMissingStudentDialog();
      return;
    }

    final action = await showDialog<ParentProfileDialogAction>(
      context: context,
      barrierColor: context.themeColors.shadow.withValues(alpha: 0.48),
      builder: (_) => const ParentSelectStudentDialog(),
    );
    if (!mounted) {
      return;
    }
    switch (action) {
      case ParentProfileDialogAction.choose:
        widget.onOpenProfileMenu();
        return;
      case ParentProfileDialogAction.create:
        await _openCreateStudentProfile();
        return;
      case null:
        return;
    }
  }

  void _scheduleMissingStudentDialogIfNeeded() {
    if (widget.useActiveStudentProfileData ||
        _hasOfferedMissingStudentProfile ||
        !widget.showChildProfileDialogOnStart ||
        !widget.isActive ||
        !hasLoadedHome ||
        _children.isNotEmpty) {
      return;
    }

    _hasOfferedMissingStudentProfile = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive || _children.isNotEmpty) {
        return;
      }
      widget.onChildProfileDialogShown?.call();
      _showMissingStudentDialog();
    });
  }

  Future<void> _showMissingStudentDialog() async {
    if (_isMissingStudentDialogVisible || !mounted) {
      return;
    }

    _isMissingStudentDialogVisible = true;
    try {
      final shouldCreate = await showDialog<bool>(
        context: context,
        barrierColor: context.themeColors.scrim.withValues(alpha: 0.58),
        builder: (_) => const HomeMissingStudentDialog(),
      );
      if (shouldCreate == true && mounted) {
        await _openCreateStudentProfile();
      }
    } finally {
      _isMissingStudentDialogVisible = false;
    }
  }

  Future<void> _openCreateStudentProfile() async {
    HapticFeedback.selectionClick();
    await widget.onCreateStudentProfile?.call(context);
    await widget.onRefreshProfiles();
  }
}
