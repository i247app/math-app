part of '../parent_home_tab.dart';

extension ParentHomeNavigationActions on ParentHomeContentState {
  Future<void> openGradeRoadmap() async {
    final profileId = profileStableId(widget.activeProfile);
    if (isOpeningGradeRoadmap || profileId == null || profileId <= 0) {
      return;
    }

    isOpeningGradeRoadmap = true;
    HapticFeedback.lightImpact();
    try {
      await widget.onOpenGradeRoadmap?.call(context);
      if (mounted) {
        await loadHome(forceRefresh: true);
      }
    } finally {
      isOpeningGradeRoadmap = false;
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
    try {
      await widget.onResumeAssessment?.call(context, exam);
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

  void _openExamReview(GeneratedExam exam) {
    final examId =
        exam.userExamId ?? exam.examId ?? exam.userAiExamId ?? exam.id;
    if (examId == null || examId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    widget.onOpenExamReview?.call(context, exam);
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
