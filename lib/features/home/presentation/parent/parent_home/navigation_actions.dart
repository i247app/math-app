part of '../parent_home_tab.dart';

extension ParentHomeNavigationActions on ParentHomeContentState {
  Future<void> openAssessment() async {
    HapticFeedback.lightImpact();
    await widget.onOpenAssessment?.call(context);
    if (mounted) {
      await loadHome();
    }
  }

  void openParentAssessmentResult(GeneratedQuiz quiz) {
    _openQuizReview(quiz);
  }

  void openCompletionResult(HomeLayoutRecentCompletion completion) {
    _openQuizReview(quizFromRecentCompletion(completion));
  }

  void _openQuizReview(GeneratedQuiz quiz) {
    final quizId = quiz.quizId ?? quiz.id;
    if (quizId == null || quizId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    widget.onOpenQuizReview?.call(context, quiz);
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
